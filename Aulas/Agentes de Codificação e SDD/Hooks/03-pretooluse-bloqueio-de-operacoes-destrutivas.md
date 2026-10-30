# PreToolUse: Bloqueio de Operações Destrutivas

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Hooks |
| **Aula** | 03 — PreToolUse: Bloqueio de Operações Destrutivas (13:01) |
| **Assunto** | Hook `PreToolUse` que restringe `kubectl delete` (via Bash e via MCP) a recursos namespaced dentro do namespace `encontros-tech`, bloqueando qualquer exclusão fora desse escopo |
| **Data** | 29/10/2026 22:45 |
| **Tags** | pretooluse, hook, kubectl-delete, mcp, bash, namespace, allowlist, permissiondecision |

## Resumo da aula

Segunda implementação prática do capítulo. O evento **PreToolUse** é disparado sempre que o agente vai usar **qualquer** ferramenta (Bash, Read, Write, MCP, etc.), antes da execução — permitindo interceptar, validar ou bloquear a chamada. A aula demonstra um caso de uso central em DevOps: impedir que o agente execute `kubectl delete` fora de um namespace autorizado, mesmo quando o comando chega por duas superfícies diferentes (Bash com `kubectl` na linha de comando, ou chamada direta à tool do MCP de Kubernetes).

## Conceitos principais

### PreToolUse — quando usar em vez de `permissions`

O Claude Code já tem um sistema de `permissions` para liberar/negar ferramentas. Mas quando se quer um controle **mais granular** — por exemplo, permitir `kubectl delete` em geral, mas restringir a um namespace específico — isso exige lógica própria, que é o papel do hook `PreToolUse`. O evento dispara independente de qual ferramenta está sendo chamada (Bash, MCP, etc.) e intercepta o `tool_name` + `tool_input` antes da execução.

### Cenário da demo

Cluster Kubernetes local (criado com Kind) com múltiplos namespaces, incluindo `encontros-tech` (onde roda a aplicação) e `kube-system` (componentes do próprio cluster, como CoreDNS). Objetivo: o agente só pode executar `delete` em recursos **namespaced** dentro do namespace `encontros-tech` — qualquer tentativa de deletar algo em outro namespace (como `kube-system`) deve ser bloqueada.

### O handler — `.claude/hooks/block-kubernetes-delete.py`

Script Python (gerado com IA e revisado/testado pelo instrutor) que trata duas superfícies de ataque pelas quais o agente alcança `kubectl delete`:

1. **MCP de Kubernetes**: a tool de exclusão estruturada (ex.: `mcp__kubernetes_lab__kubectl_delete`), cujos argumentos chegam como um dicionário (`namespace`, `resourceType`, `allNamespaces`, `manifest`, `context`, etc.).
2. **Bash com `kubectl delete`**: uma string de comando de shell que precisa ser **tokenizada** (usando `shlex`) para extrair flags e argumentos posicionais, incluindo o caso de comandos aninhados (`sh -c "kubectl delete ..."`, `bash -c`, `eval`).

Lógica de validação (resumida):
- Nega se `--all-namespaces`/`-A` estiver presente (exclusão em todos os namespaces).
- Nega se houver `-f`/`--filename`/`-k`/`--kustomize` (exclusão por manifesto não comprova o namespace real do recurso).
- Nega se houver flags de identidade (`--kubeconfig`, `--server`, `--token`, `--as`, `--context`) — tentativa de mudar o cluster/contexto de execução.
- Exige que o namespace seja informado **explicitamente** e que seja exatamente `encontros-tech` — qualquer outro valor (ou ausência) é negado.
- Verifica se o **tipo do recurso** está na allowlist de recursos namespaced (`pod`, `deployment`, `service`, `configmap`, `secret`, `statefulset`, `daemonset`, `job`, `cronjob`, `ingress`, `pvc` e suas abreviações) — tipos não listados (ou cluster-scoped) são negados.
- Mesma validação para alvos com `tipo/nome` (ex.: `pod/meu-pod`).

Em qualquer falha interna do hook (exceção não esperada), o script **nega por padrão** — "nenhuma falha do hook pode liberar a exclusão".

### Formato da negação (`PreToolUse`)

Diferente do hook de `UserPromptSubmit` (que usava `exit 2` no `stderr`), o hook de `PreToolUse` usa `exit 0` sempre, e sinaliza a decisão escrevendo um **JSON estruturado no stdout**:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "<motivo>"
  }
}
```

Quando a operação é permitida, o script simplesmente não escreve nada e sai com `0`. A diferença-chave entre os dois tipos de evento: em `UserPromptSubmit`, o exit code decide bloquear/seguir; em `PreToolUse`, o exit code é sempre `0`, e é o **conteúdo do stdout** (presença ou ausência de `permissionDecision: "deny"`) que decide.

### Registro no `.claude/settings.json`

Como a mesma intenção (bloquear delete fora do namespace) chega por duas superfícies diferentes, são necessárias **duas entradas** no array de hooks do evento `PreToolUse`: um matcher para `Bash` (intercepta todo comando de shell) e um matcher exato para a tool de exclusão do MCP (`mcp__kubernetes_lab__kubectl_delete` — o nome exato depende de como o servidor MCP foi registrado no projeto).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-kubernetes-delete.py",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "mcp__kubernetes_lab__kubectl_delete",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-kubernetes-delete.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

Essa configuração **substituiu** (não complementou) o `UserPromptSubmit` da aula anterior, só para isolar e demonstrar o comportamento do `PreToolUse` especificamente.

### Testes realizados

1. "Liste os pods do cluster Kubernetes" — permitido (operação de leitura, sem risco).
2. "Delete o pod `<pod do kube-system, ex: coredns>`" — **bloqueado**: "Operação Kubernetes bloqueada antes da execução: namespace fora da allowlist: kube-system. Somente exclusões de recursos namespaced em encontros-tech são permitidas."
3. "Liste os pods do namespace encontros-tech" + "Delete o pod `<pod do encontros-tech>`" via **CLI/Bash** — permitido, executado com sucesso.
4. Mesma exclusão, mas pedindo explicitamente "Utilize o MCP Kubernetes" — também permitido, confirmando que a validação funciona igualmente pela via MCP.

## Comandos e configurações

<details>
<summary>Handler completo: .claude/hooks/block-kubernetes-delete.py</summary>

```python
#!/usr/bin/env python3

import json
import os
import re
import shlex
import sys

MCP_DELETE_TOOL = "mcp__kubernetes_lab__kubectl_delete"
ALLOWED_NAMESPACE = "encontros-tech"
MAX_NESTED_DEPTH = 3
SHELL_CONTROL_TOKENS = {";", "&&", "||", "|", "&", "(", ")"}
ALLOWED_NAMESPACED_RESOURCES = {
    "pod", "pods", "po",
    "deployment", "deployments", "deploy",
    "service", "services", "svc",
    "configmap", "configmaps", "cm",
    "secret", "secrets",
    "statefulset", "statefulsets", "sts",
    "daemonset", "daemonsets", "ds",
    "job", "jobs",
    "cronjob", "cronjobs",
    "ingress", "ingresses", "ing",
    "persistentvolumeclaim", "persistentvolumeclaims", "pvc",
}
FLAGS_WITH_VALUES = {
    "-n", "--namespace", "-l", "--selector", "--field-selector",
    "--grace-period", "--timeout", "--cascade", "--context",
    "--request-timeout",
}
IDENTITY_FLAGS = (
    "--kubeconfig", "--server", "--token", "--as", "--as-group", "--context",
)

def deny(reason: str) -> None:
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
        ensure_ascii=False,
    )
    sys.stdout.write("\n")

def deny_kubernetes(rejection: str) -> None:
    deny(
        "Operação Kubernetes bloqueada antes da execução: "
        f"{rejection}. Somente exclusões de recursos namespaced "
        f"em {ALLOWED_NAMESPACE} são permitidas."
    )

# ... (funções auxiliares de tokenização e validação de argumentos kubectl/MCP) ...

def main() -> None:
    try:
        tool_name, tool_input = read_payload()
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        deny("Operação bloqueada: o payload do PreToolUse é inválido.")
        return

    if tool_name == MCP_DELETE_TOOL:
        rejection = validate_mcp_delete(tool_input)
        if rejection:
            deny_kubernetes(rejection)
        return

    if tool_name == "Bash":
        command = tool_input.get("command")
        if not isinstance(command, str):
            deny("Operação Bash bloqueada: o campo command é inválido.")
            return
        try:
            rejections = kubectl_delete_rejections(command)
        except ValueError:
            deny("Operação Bash bloqueada: não foi possível interpretar o comando.")
            return
        if rejections:
            deny_kubernetes(rejections[0])
        return

try:
    main()
except Exception:  # nenhuma falha do hook pode liberar a exclusão
    deny("Operação bloqueada: falha interna do hook de proteção.")

raise SystemExit(0)
```

*(script completo e mais longo — inclui tokenização shell com `shlex`, suporte a comandos aninhados `sh -c`/`bash -c`/`eval`, e validação detalhada de flags como `-A`, `-f`, `--kustomize`; disponibilizado como material da aula para cópia direta no projeto.)*

</details>

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-kubernetes-delete.py",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "mcp__kubernetes_lab__kubectl_delete",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-kubernetes-delete.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

```bash
chmod +x .claude/hooks/block-kubernetes-delete.py
```

## Pegadinhas

- O nome exato da tool MCP (`mcp__<nome-do-servidor>__kubectl_delete`) depende de como o servidor MCP foi registrado no projeto — é preciso ajustar a constante `MCP_DELETE_TOOL` para o valor real, senão o matcher do `settings.json` nunca casa com a chamada.
- O mesmo comando de delete pode chegar por **Bash** (string a ser tokenizada) ou por **MCP** (argumentos já estruturados) — tratar só uma das superfícies deixa uma brecha óbvia de bypass.
- Exclusão via manifesto/arquivo (`-f`, `--kustomize`) não comprova o namespace real dos recursos afetados — por isso é bloqueada incondicionalmente, independente do conteúdo do arquivo.
- O formato de resposta do `PreToolUse` é diferente do `UserPromptSubmit`: aqui o exit code é sempre `0`, e a decisão de bloqueio vem de um JSON estruturado no stdout (`permissionDecision: "deny"`) — confundir os dois formatos faz o hook falhar silenciosamente.
- Qualquer exceção não tratada no hook deve resultar em bloqueio (fail-safe), nunca em liberação — um hook de segurança que "quebra e libera" é pior do que não ter hook nenhum.

## Dúvidas para revisar

- Vale estender esse mesmo padrão de allowlist por namespace para outros comandos destrutivos do Kubernetes (`kubectl drain`, `kubectl cordon`, `kubectl scale --replicas=0`)?
- Como esse hook se comportaria com `kubectl apply -f` apontando para um manifesto que faz exclusões implícitas via `kubectl apply --prune`?
- Faz sentido ter um terceiro matcher para outras tools que também possam alcançar o cluster (ex.: um MCP genérico de execução de comandos), além de Bash e do MCP específico do Kubernetes?
