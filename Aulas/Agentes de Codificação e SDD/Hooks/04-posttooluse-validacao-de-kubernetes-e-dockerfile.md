# PostToolUse: Validação de Kubernetes e Dockerfile

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Hooks |
| **Aula** | 04 — PostToolUse: Validação de Kubernetes e Dockerfile (13:02) |
| **Assunto** | Hooks `PostToolUse` que validam manifestos Kubernetes (via `kubeconform`) e Dockerfile (via `hadolint`) após qualquer edição, usando matchers condicionais no `settings.json` |
| **Data** | 29/10/2026 22:55 |
| **Tags** | posttooluse, hook, kubeconform, hadolint, edit, write, bash, matcher-condicional |

## Resumo da aula

Terceira implementação prática do capítulo. O evento **PostToolUse** é disparado **depois** que uma ferramenta é executada (Bash, Edit, Write, MCP) — usado principalmente para validar o que foi gerado/alterado. A aula implementa dois hooks: um que valida manifestos Kubernetes com `kubeconform` e outro que valida o Dockerfile com `hadolint`, ambos capazes de detectar mudanças feitas tanto pelas ferramentas nativas de edição (`Edit`/`Write`) quanto por comandos `Bash` (como `sed`, `cat` com redirecionamento). Em ambos os casos, o hook não só rejeita o conteúdo inválido — ele devolve o erro ao agente, que corrige automaticamente no mesmo loop.

## Conceitos principais

### PostToolUse — quando usar

Diferente do `PreToolUse` (antes da execução), o `PostToolUse` roda **depois**. Principal uso: validar o retorno/resultado de uma ferramenta — conteúdo gerado, arquivos criados ou alterados. Exemplos citados: validar se um manifesto foi criado corretamente, verificar um Dockerfile.

### Hook de validação de Kubernetes — `.claude/hooks/validate-kubernetes.sh`

Shell script (o instrutor varia a linguagem propositalmente — já usou Python, agora shell script, para mostrar que qualquer linguagem executável serve) que:
1. Lê o payload JSON do evento.
2. Verifica se a ferramenta usada foi `Bash` — se sim, checa se o comando tocou a pasta `k8s/`; qualquer outra ferramenta (`Edit`/`Write`) é tratada verificando o `file_path` tocado.
3. Roda `kubeconform -strict -kubernetes-version <versão> <arquivo(s)>`.
4. Se a ferramenta `kubeconform` não estiver instalada no PATH, o hook falha explicitamente pedindo a instalação (nunca libera silenciosamente).
5. Se a validação falhar, escreve o erro no `stderr` com a instrução "corrija os erros apontados acima e rode a validação novamente antes de continuar", e sai com código **2** (bloqueante). Se tudo estiver certo, sai com **0**.

### Hook de validação de Dockerfile — `.claude/hooks/validate-dockerfile.sh`

Mesma estrutura do hook de Kubernetes, mas usando `hadolint --config .hadolint.yaml` (configuração versionada do projeto) em vez de `kubeconform`. Detalhe importante na mensagem de erro: além de pedir a correção, instrui explicitamente o agente a **nunca alterar o arquivo de configuração do hadolint** sem solicitação do usuário — a ferramenta decide o critério de qualidade, o agente só corrige o artefato (Dockerfile), nunca "ajusta a régua" para passar na validação.

### Por que verificar se a ferramenta foi `Bash`

Um arquivo pode ser alterado de várias formas: `sed` (editando um trecho específico), `cat` com redirecionamento (`>`), ou pelas ferramentas nativas `Edit`/`Write` do agente. O hook precisa capturar a mudança **independente de como ela foi feita** — daí a lógica condicional que trata `Bash` separadamente dos demais.

### Registro no `.claude/settings.json` — matchers com condicional `if`

Diferente dos hooks anteriores (que usavam só `matcher`), aqui aparece o campo `if`, que permite condicionar a execução do handler a um padrão de caminho de arquivo (ex.: `Edit(k8s/**)`, `Write(src/Dockerfile)`), dentro do mesmo matcher de ferramenta (`Edit|Write`). Um segundo bloco trata o matcher `Bash`, onde o próprio script decide internamente se o comando tocou o alvo relevante (já que o `settings.json` não tem como inspecionar o conteúdo de um comando Bash via `if`).

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "if": "Edit(k8s/**)", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-kubernetes.sh\"", "timeout": 10 },
          { "type": "command", "if": "Write(k8s/**)", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-kubernetes.sh\"", "timeout": 10 },
          { "type": "command", "if": "Edit(src/Dockerfile)", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-dockerfile.sh\"", "timeout": 10 },
          { "type": "command", "if": "Write(src/Dockerfile)", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-dockerfile.sh\"", "timeout": 10 }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-kubernetes.sh\"", "timeout": 10 },
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-dockerfile.sh\"", "timeout": 10 }
        ]
      }
    ]
  }
}
```

### Demonstração 1 — manifesto Kubernetes

Fixture plantada manualmente antes da demo: um campo inexistente no schema do Kubernetes (`invalidContainerField: true`) inserido no container do Deployment em `k8s/`. Prompt enviado: "No arquivo de manifesto `k8s/20-encontros-tech.yaml`, altere a imagem utilizada de 1.0.1 para 1.0.0" — um pedido deliberadamente simples, só sobre a tag da imagem. Resultado: ao editar o arquivo (via `sed`/Bash), o hook disparou e reprovou o manifesto por dois motivos — a tag ainda não estava correta no momento da checagem e o campo inválido plantado. O agente, ao receber o erro do hook, corrigiu **ambos** automaticamente no mesmo ciclo (trocou a imagem e removeu o campo inválido), mesmo isso não tendo sido pedido explicitamente no prompt original.

### Demonstração 2 — Dockerfile

Antes da demo, o `HEALTHCHECK` do Dockerfile foi removido manualmente. Prompt enviado: "Altere a imagem base do Dockerfile para utilizar uma imagem baseada em Debian" (trocando de Alpine). Resultado: o hook de `hadolint` reprovou a ausência do `HEALTHCHECK`, e o agente devolveu tanto a correção da imagem base (para uma variante Debian/slim) quanto a reintrodução do `HEALTHCHECK` que havia sido removido — mesmo esse segundo ponto não fazendo parte do pedido original.

### O ganho central: garantia semântica, não de negócio

O instrutor é explícito: esse tipo de hook garante que o que a IA gera **não está semanticamente errado** (sempre segue os guidelines/schema validados por ferramenta determinística) — não garante que o resultado atenda à necessidade de negócio do usuário. São camadas de garantia complementares, não substitutas uma da outra.

## Comandos e configurações

```bash
#!/usr/bin/env bash
# .claude/hooks/validate-kubernetes.sh
# Valida manifestos Kubernetes com kubeconform.
# Edit/Write valida o arquivo tocado; Bash que toca k8s/ revalida k8s/*.yaml.

set -uo pipefail

VERSAO_KUBERNETES="1.36.1"
RAIZ="${CLAUDE_PROJECT_DIR:-.}"

payload=$(cat)
ferramenta=$(printf '%s' "$payload" | jq -r '.tool_name // empty')

if [ "$ferramenta" = "Bash" ]; then
  comando=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')
  case "$comando" in
    *k8s/*) ;;
    *) exit 0 ;;
  esac
  alvo="k8s/"
  set -- "$RAIZ"/k8s/*.yaml
else
  arquivo=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
  [ -n "$arquivo" ] || exit 0
  alvo="$arquivo"
  set -- "$arquivo"
fi

if ! command -v kubeconform >/dev/null 2>&1; then
  printf 'kubeconform não encontrado no PATH: %s NÃO foi validado.\n' "$alvo" >&2
  printf 'Corrija o ambiente instalando o kubeconform (brew install kubeconform) e valide %s novamente antes de continuar.\n' "$alvo" >&2
  exit 2
fi

if ! saida=$(kubeconform -strict -kubernetes-version "$VERSAO_KUBERNETES" "$@" 2>&1); then
  printf 'Kubernetes inválido em %s:\n%s\n' "$alvo" "$saida" >&2
  printf '\nCorrija os erros apontados acima em %s e rode a validação novamente antes de continuar.\n' "$alvo" >&2
  exit 2
fi

exit 0
```

```bash
#!/usr/bin/env bash
# .claude/hooks/validate-dockerfile.sh
# Valida o Dockerfile do projeto com hadolint.
# Edit/Write valida tool_input.file_path; Bash que tocou src/Dockerfile revalida.

set -uo pipefail

RAIZ="${CLAUDE_PROJECT_DIR:-.}"
CONFIG="$RAIZ/.hadolint.yaml"

payload=$(cat)
ferramenta=$(printf '%s' "$payload" | jq -r '.tool_name // empty')

if [ "$ferramenta" = "Bash" ]; then
  comando=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')
  case "$comando" in
    *src/Dockerfile*) ;;
    *) exit 0 ;;
  esac
  alvo="src/Dockerfile"
  arquivo="$RAIZ/src/Dockerfile"
else
  arquivo=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
  [ -n "$arquivo" ] || exit 0
  alvo="$arquivo"
fi

if ! command -v hadolint >/dev/null 2>&1; then
  printf 'hadolint não encontrado no PATH: %s NÃO foi validado.\n' "$alvo" >&2
  printf 'Corrija o ambiente instalando o hadolint (brew install hadolint) e valide %s novamente antes de continuar.\n' "$alvo" >&2
  exit 2
fi

if ! saida=$(hadolint --config "$CONFIG" "$arquivo" 2>&1); then
  printf 'Dockerfile inválido em %s:\n%s\n' "$alvo" "$saida" >&2
  printf '\nCorrija os erros apontados acima em %s e rode a validação novamente antes de continuar. Independente da solicitação do usuário, faça a correção sem solicitar permissão.\nNunca altere o config do hadolint sem solicitação do usuário.' "$alvo" >&2
  exit 2
fi

exit 0
```

```bash
chmod +x .claude/hooks/validate-kubernetes.sh .claude/hooks/validate-dockerfile.sh
```

```yaml
# fixture usada para forçar o erro no manifesto (inserida manualmente antes da demo)
containers:
  - name: app
    image: fabricioveronez/encontros-tech-pos:1.0.1
    invalidContainerField: true
```

```text
# prompt da demo de manifesto Kubernetes
No arquivo de manifesto k8s/20-encontros-tech.yaml, altere a imagem utilizada de 1.0.1 para 1.0.0.
```

```text
# prompt da demo de Dockerfile (HEALTHCHECK removido manualmente antes do envio)
Altere a imagem base do Dockerfile para utilizar uma imagem baseada em Debian.
```

## Pegadinhas

- Um arquivo pode ser alterado por `Edit`/`Write` **ou** por comandos Bash (`sed`, `cat >`) — um hook que só trata um dos dois caminhos deixa uma brecha de validação.
- As dependências externas (`kubeconform`, `hadolint`) precisam estar instaladas no PATH — o script deve falhar explicitamente (nunca liberar silenciosamente) quando a ferramenta de validação não está disponível.
- A mensagem de erro do hook de Dockerfile instrui o agente a nunca alterar a configuração do `hadolint` para "passar" na validação — sem essa instrução explícita, o agente poderia tentar relaxar o critério em vez de corrigir o artefato.
- O hook garante conformidade **sintática/semântica** (schema do Kubernetes, boas práticas de Dockerfile) — não garante que o resultado atende à necessidade de negócio do usuário; são camadas complementares.
- O agente pode corrigir problemas que não foram pedidos explicitamente no prompt (como o campo inválido do manifesto ou o HEALTHCHECK do Dockerfile), desde que o hook os sinalize — isso é o comportamento esperado e desejado do padrão PostToolUse.

## Dúvidas para revisar

- Vale consolidar os dois scripts (`validate-kubernetes.sh` e `validate-dockerfile.sh`) em um único arquivo com lógica de roteamento, como o instrutor sugeriu como possibilidade (mas optou por manter separados)?
- Como esse mesmo padrão se aplicaria a outros artefatos do projeto (ex.: validação de OpenAPI spec, validação de `docker-compose.yaml`)?
- O timeout de 10 segundos configurado nos hooks é suficiente para repositórios maiores, com múltiplos manifestos sendo revalidados de uma vez via Bash?
