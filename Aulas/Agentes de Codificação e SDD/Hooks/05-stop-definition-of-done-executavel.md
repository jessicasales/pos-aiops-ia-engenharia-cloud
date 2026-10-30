# Stop: Definition of Done Executável

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Hooks |
| **Aula** | 05 — Stop: Definition of Done Executável (10:31) |
| **Assunto** | Hook `Stop` que valida o estado final de toda a infraestrutura (Kubernetes + Dockerfile) sempre que o agente termina naturalmente uma interação, usando `stop_hook_active` para evitar loop infinito |
| **Data** | 29/10/2026 23:05 |
| **Tags** | stop, hook, definition-of-done, stop_hook_active, kubeconform, hadolint, validacao-final |

## Resumo da aula

Última aula prática do capítulo "Hooks". O evento **Stop** é disparado uma única vez, quando o agente termina de executar **toda** a interação (diferente de `PreToolUse`/`PostToolUse`, que disparam a cada chamada de ferramenta dentro do ciclo). É o lugar ideal para implementar uma **Definition of Done executável**: uma validação final que garante que o estado da infraestrutura está correto antes do agente realmente parar — mesmo que a tarefa pedida não tivesse relação direta com o que foi corrigido.

## Conceitos principais

### O evento Stop

Disparado **uma única vez** por interação — quando o agente termina de executar tudo que foi solicitado (seja um prompt simples ou um loop de execução mais longo) e "para". É o par simétrico do evento de início de sessão (Start): este dispara uma vez na abertura, o Stop dispara uma vez no encerramento.

### Uso típico: Definition of Done

Qualquer validação que determina se a tarefa realizada está realmente completa e com a qualidade necessária — testes de unidade, lint, validação de schema, etc. O instrutor recomenda cautela com **testes de integração** aqui: eles tendem a demorar, e como o evento já ocorre no fim da execução, um erro detectado nesse ponto faz o agente voltar a corrigir e reexecutar — ou seja, cada falha é cara em tempo.

### Script de validação — `.claude/hooks/validate-infrastructure.sh`

Diferente dos hooks de `PostToolUse` da aula anterior (que inspecionavam qual ferramenta foi usada e qual arquivo mudou), o hook de `Stop` vai **direto para a validação do estado final** — não importa o que mudou ou como, só importa se o resultado final está correto. Roda `kubeconform -strict` em todos os manifestos (`k8s/*.yaml`) e `hadolint --config .hadolint.yaml` no Dockerfile, consolidando o status das duas checagens.

Mecanismo crítico para evitar loop infinito: o payload do evento inclui o campo `stop_hook_active`. Se a validação falhar **novamente** depois que o hook já devolveu feedback uma vez (`stop_hook_active == true`), o script **não bloqueia de novo** (sai com `0`), apenas avisa que a validação ainda falhou e instrui o agente a revisar o diagnóstico sem tentar contornar a validação ou alterar a configuração do hadolint — evitando que o agente fique preso em um ciclo sem fim de tentativa e erro.

### Registro no `.claude/settings.json` — mais simples que os anteriores

Como `Stop` não é uma chamada de ferramenta, não existe `matcher` de arquivo nem condicional `if` — apenas o comando a executar:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-infrastructure.sh\"",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```

Timeout de 20 segundos — maior que os hooks anteriores, porque são vários comandos em sequência (kubeconform + hadolint); se testes de integração forem adicionados, o timeout precisaria ser ainda maior.

### Demonstração

Antes do teste, o instrutor removeu manualmente o `HEALTHCHECK` do Dockerfile e reinseriu o campo inválido (`invalidContainerField`) no manifesto Kubernetes — **sem pedir nada sobre Docker no prompt**. Prompt enviado: apenas "Altere a imagem no manifesto Kubernetes de 1.0.0 para 1.0.1". O agente fez só a alteração pedida (sem tocar no Dockerfile) e, ao tentar finalizar a interação, o hook `Stop` disparou e reportou **duas falhas** — o campo inválido no manifesto e a ausência do `HEALTHCHECK` no Dockerfile — mesmo nenhuma delas sendo parte do pedido original. O agente reconheceu que "ambos os erros são anteriores à minha edição, só mudei a tag", investigou e corrigiu: ao reintroduzir o `HEALTHCHECK`, uma nova regra do hadolint (`DL3025`) foi disparada por uma forma inadequada de escrever o comando — o agente ajustou novamente e só então a validação final passou, permitindo o encerramento real da interação.

### Particularidade importante: Stop só dispara em encerramento natural

Se o usuário interromper manualmente a execução do agente, o evento `Stop` **não é disparado** — ele só ocorre quando o fluxo termina por conta própria, sem intervenção externa.

### Conclusão do capítulo

Colocar um script de validação no evento `Stop` garante uma checagem final de qualidade depois que o agente "acha" que terminou — é, nas palavras do instrutor, "o ouro" para garantir qualidade no loop de execução. Ressalva: não se deve abusar com validações demoradas, e o critério usado precisa eventualmente convergir para verdadeiro, sob risco do agente entrar em loop de correção sem fim (mitigado pelo `stop_hook_active`).

## Comandos e configurações

```bash
#!/usr/bin/env bash
# .claude/hooks/validate-infrastructure.sh
# Valida a infraestrutura antes de o agente encerrar.

set -uo pipefail

RAIZ="${CLAUDE_PROJECT_DIR:-.}"
cd "$RAIZ"

payload=$(cat)

if saida=$( { \
  status=0; \
  kubeconform -strict -kubernetes-version 1.36.1 -summary k8s/*.yaml || status=1; \
  hadolint --config .hadolint.yaml src/Dockerfile || status=1; \
  exit "$status"; \
} 2>&1); then
  exit 0
fi

ja_em_continuacao=$(printf '%s' "$payload" | jq -r '.stop_hook_active // false')
if [ "$ja_em_continuacao" = "true" ]; then
  printf 'A validação final ainda falhou após o feedback anterior. Revise o diagnóstico antes de retomar.\n%s\nNão altere a configuração do Hadolint nem tente contornar a validação. Resolva o problema antes de continuar.\n' "$saida" >&2
  exit 0
fi

printf 'A validação final da infraestrutura falhou:\n%s\n' "$saida" >&2
exit 2
```

```bash
chmod +x .claude/hooks/validate-infrastructure.sh
```

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/validate-infrastructure.sh\"",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```

```text
# prompt da demo (sem nenhuma menção a Docker/HEALTHCHECK)
Altere a imagem no manifesto Kubernetes de 1.0.0 para 1.0.1.
```

## Pegadinhas

- Testes de integração no hook `Stop` podem ser custosos em tempo — cada falha detectada aqui gera um ciclo completo de correção e reexecução do agente.
- Sem o controle de `stop_hook_active`, um critério de validação que nunca converge (ex.: um erro impossível de corrigir automaticamente) faria o agente entrar em loop infinito de tentativa — o campo existe exatamente para evitar isso, soltando o agente na segunda falha consecutiva em vez de bloquear de novo.
- O evento `Stop` só dispara em encerramento **natural** — interromper a execução manualmente não aciona a validação final, deixando o estado potencialmente inconsistente sem aviso.
- Corrigir um problema pode introduzir outro (como aconteceu com o `DL3025` do hadolint ao reintroduzir o `HEALTHCHECK` de forma inadequada) — a validação final precisa ser reexecutada após cada correção, não assumida como resolvida na primeira tentativa.

## Dúvidas para revisar

- Vale adicionar testes de unidade (rápidos) ao hook de `Stop`, reservando testes de integração para um pipeline de CI separado, dado o custo de tempo mencionado?
- Como esse padrão de `stop_hook_active` se compara, em termos de robustez, a simplesmente limitar um número máximo de tentativas de correção?
- Faz sentido ter hooks de `Stop` diferentes por tipo de projeto/stack no mesmo monorepo, replicando a lógica de hierarquia de regras vista no capítulo "Rules"?
