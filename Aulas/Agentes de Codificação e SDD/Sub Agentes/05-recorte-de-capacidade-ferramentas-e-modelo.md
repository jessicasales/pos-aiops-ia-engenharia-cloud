# Recorte de Capacidade: Ferramentas e Modelo

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 05 — Recorte de Capacidade: Ferramentas e Modelo (27:12) |
| **Assunto** | Restringir ferramentas (`tools` allowlist / `disallowedTools` denylist) e fixar modelo (`model`) por sub-agent, no front matter do Claude Code |
| **Data** | 29/10/2026 19:35 |
| **Tags** | tools, disallowedtools, model, allowlist, denylist, mcp, haiku, sonnet, front-matter |

## Resumo da aula

Até esta aula, os sub-agents `devops-engineer` e `software-developer` herdavam **todas** as ferramentas e o **mesmo modelo** do agente principal (Opus, no caso da demo). A aula mostra como restringir isso de forma granular, no front matter do arquivo do agente, usando três campos: `tools` (allowlist — só o listado fica disponível), `disallowedTools` (denylist — tudo disponível exceto o listado) e `model` (fixa o modelo daquele agente, em vez de herdar). O comportamento é demonstrado com testes reais onde o agente tenta e falha/é bloqueado ao tentar usar uma ferramenta fora do seu recorte.

## Conceitos principais

### Por que restringir capacidade

Dois motivos centrais:
1. **Custo/eficiência**: nem todo sub-agent precisa do modelo mais caro/poderoso. Um agente de busca/scraping ou de operações simples pode rodar com um modelo mais barato (ex.: Haiku), enquanto o orquestrador (agente principal) usa um modelo com mais reasoning (ex.: Opus).
2. **Segurança/escopo**: nem todo sub-agent deveria poder fazer tudo que o agente principal faz. Ex.: não faz sentido o `devops-engineer` escrever em diretórios de código, nem o `software-developer` ter acesso a um cluster Kubernetes via MCP.

Essas configurações variam em sintaxe entre ferramentas (Claude Code, Codex, Cursor), mas o recurso existe em praticamente todas — vale checar a documentação de cada uma.

### `tools` — allowlist

Campo no front matter que lista exatamente quais ferramentas o agente pode usar; qualquer coisa fora da lista fica indisponível.

**Primeiro recorte** (`devops-engineer`, só leitura/busca):
```yaml
---
name: devops-engineer
description: Use este agente para tarefas de infraestrutura, operação, entrega e observabilidade da aplicação...
tools:
  - Read
  - Grep
  - Glob
---
```
Teste: `@devops-engineer analise as configurações de Docker e Kubernetes na aplicação e depois crie um relatório na pasta raiz chamado containers.md`. Resultado: o sub-agent leu/analisou normalmente, mas **não conseguiu gravar o arquivo** (sem `Write` na allowlist) — o conteúdo foi devolvido ao agente principal, que gravou o arquivo por conta própria.

**Segundo recorte** (ampliado — web + MCP de Kubernetes somente leitura + modelo fixo):
```yaml
---
name: devops-engineer
description: ...
tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - mcp__kubernetes__kubectl_get
  - mcp__kubernetes__kubectl_describe
  - mcp__kubernetes__kubectl_logs
  - mcp__kubernetes__explain_resource
  - mcp__kubernetes__list_api_resources
model: haiku
---
```
Nota importante sobre MCP: ferramentas de servidores MCP seguem o padrão `mcp__servidor__ferramenta`. Declarar apenas `mcp__kubernetes` liberaria **o servidor inteiro** (todas as suas ferramentas, incluindo as de escrita/alteração); listar as chamadas uma a uma (`kubectl_get`, `kubectl_describe`, `kubectl_logs`, etc.) mantém o acesso restrito somente a operações de leitura.

Teste: `@devops-engineer analise o cluster Kubernetes usando o MCP de Kubernetes e verifique na internet as boas práticas que um cluster Kubernetes deve ter. E no final, escreva em um arquivo chamado relatorio-cluster.md`. O sub-agent conseguiu consultar o cluster via MCP e pesquisar na web, mas não conseguiu escrever o arquivo — mesma lógica da fronteira de permissão. Em uma das execuções, o próprio Claude Code reportou um "bug" (o sub-agent sem ferramenta de escrita teria tentado contornar a restrição via Bash, e o sistema sinalizou isso como comportamento indevido/alucinação, impedindo a ação) — reforçando que restrições de capacidade precisam ser bem fechadas, incluindo bloquear vias alternativas como Bash quando necessário.

### `model` — fixando o modelo do agente

Campo que define explicitamente qual modelo o agente usa, em vez de herdar o do agente principal. Vantagem: controle de custo — agentes com tarefas simples (busca, scraping, conversão de documento) não precisam de um modelo caro como Opus; um Haiku atende bem e custa muito menos.

### `disallowedTools` — denylist (caminho inverso)

Em vez de listar o que o agente **pode** usar, lista o que ele **não pode** — todo o resto continua disponível. Útil quando se quer bloquear pontos específicos sem restringir tudo.

**Recorte do `software-developer`** (bloqueia só o MCP de Kubernetes, mantendo leitura/edição/terminal; modelo fixado em Sonnet — mais capaz que o do `devops-engineer` de inspeção):
```yaml
---
name: software-developer
description: Use este agente para qualquer tarefa que envolva o código da aplicação...
disallowedTools:
  - mcp__kubernetes
model: sonnet
---
```
Teste: `@software-developer aplique o deploy da aplicação no Kubernetes e analise depois se o deploy funcionou. Me traga as informações no final.` Resultado: o agente confirmou não ter acesso às ferramentas MCP de Kubernetes. Em algumas execuções, ele contornou a restrição usando `kubectl` via Bash (já que só o MCP estava bloqueado, não o Bash em si) — mostrando que é preciso "aparar as frestas" bloqueando também vias alternativas quando o objetivo é um bloqueio completo. Em outra execução (comportamento não determinístico, destacado pelo instrutor), o agente **recusou a tarefa** citando que deploy/infraestrutura é escopo do `devops-engineer` (reforçado pelos limites definidos no próprio System Prompt do agente, criado na aula "Criação de sub-agents") e redirecionou corretamente.

### Onde configurar em outras ferramentas

O instrutor mostra rapidamente a documentação do Codex e menciona o Cursor: ambos também permitem configurar modelo, nível de reasoning e sandbox/permissões por sub-agente/agente personalizado — a sintaxe muda, o conceito é o mesmo.

### Resumo prático de quando usar cada campo

- **`tools`** (allowlist): quando se quer um escopo bem fechado — só o explicitamente listado fica disponível.
- **`disallowedTools`** (denylist): quando se quer bloquear pontos específicos, mantendo o resto do acesso padrão.
- **`model`**: sempre que o custo/reasoning necessário da tarefa daquele agente for diferente do agente principal.

## Comandos e configurações

```yaml
# devops-engineer — allowlist inicial (só leitura/busca)
---
name: devops-engineer
description: Use este agente para tarefas de infraestrutura, operação, entrega e observabilidade da aplicação — empacotamento e execução do serviço, configuração por ambiente e segredos, provisionamento de recursos, pipelines de build/deploy, health checks, logs, métricas e alertas, além de diagnóstico de problemas de ambiente, execução ou performance operacional. Delegue quando a tarefa for sobre como a aplicação roda, é entregue ou é observada, e não sobre o comportamento do código de negócio. Não use para implementar regras de negócio, alterar camadas da aplicação ou escrever testes de código — isso é do software-developer.
tools:
  - Read
  - Grep
  - Glob
---
```

```text
@devops-engineer analise as configurações de Docker e Kubernetes na aplicação e depois crie um relatório na pasta raiz chamado containers.md
```

```yaml
# devops-engineer — allowlist ampliada (web + MCP read-only + modelo fixo)
---
name: devops-engineer
description: Use este agente para tarefas de infraestrutura, operação, entrega e observabilidade da aplicação — empacotamento e execução do serviço, configuração por ambiente e segredos, provisionamento de recursos, pipelines de build/deploy, health checks, logs, métricas e alertas, além de diagnóstico de problemas de ambiente, execução ou performance operacional. Delegue quando a tarefa for sobre como a aplicação roda, é entregue ou é observada, e não sobre o comportamento do código de negócio. Não use para implementar regras de negócio, alterar camadas da aplicação ou escrever testes de código — isso é do software-developer.
tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - mcp__kubernetes__kubectl_get
  - mcp__kubernetes__kubectl_describe
  - mcp__kubernetes__kubectl_logs
  - mcp__kubernetes__explain_resource
  - mcp__kubernetes__list_api_resources
model: haiku
---
```

```text
@devops-engineer analise o cluster Kubernetes usando o MCP de Kubernetes e verifique na internet as boas práticas que um cluster Kubernetes deve ter. E no final, escreva em um arquivo chamado relatorio-cluster.md
```

```yaml
# software-developer — denylist (bloqueia só o MCP de Kubernetes)
---
name: software-developer
description: Use este agente para qualquer tarefa que envolva o código da aplicação — implementar uma funcionalidade nova, alterar ou corrigir comportamento existente, refatorar, ajustar configuração da aplicação, e escrever ou manter os testes correspondentes. Delegue quando a tarefa exigir ler o código, entender como as camadas se conectam e produzir mudanças no repositório. Não use para tarefas que não tocam o código da aplicação (documentação de conteúdo, preparação de aula, pesquisa, decisões de produto).
disallowedTools:
  - mcp__kubernetes
model: sonnet
---
```

```text
@software-developer aplique o deploy da aplicação no Kubernetes e analise depois se o deploy funcionou. Me traga as informações no final.
```

## Pegadinhas

- Declarar apenas `mcp__kubernetes` em `tools` libera **todas** as ferramentas daquele servidor MCP, inclusive as de escrita — para restringir a leitura, é preciso listar cada chamada (`mcp__kubernetes__kubectl_get`, etc.) individualmente.
- Bloquear só o servidor MCP (`disallowedTools: mcp__kubernetes`) não impede o agente de alcançar o mesmo recurso por uma via alternativa (ex.: `kubectl` via Bash) — para um bloqueio completo, é necessário também restringir a ferramenta de terminal.
- O comportamento de contorno/recusa de um agente ao encontrar uma restrição não é 100% determinístico — a mesma tarefa pode, em execuções diferentes, ser contornada via Bash ou corretamente recusada e redirecionada ao agente certo.
- Fixar `model` para um valor mais barato (Haiku) só faz sentido para tarefas de baixo reasoning (busca, scraping, conversão simples) — usar Haiku em tarefas que exigem julgamento mais sofisticado compromete a qualidade do resultado.

## Dúvidas para revisar

- Quais outras ferramentas/MCPs do projeto Encontros Tech mereceriam o mesmo tratamento de allowlist/denylist além de Kubernetes?
- Vale bloquear explicitamente o Bash do `software-developer` em relação a comandos `kubectl`, já que o MCP sozinho não impediu o contorno?
- Em qual ponto do fluxo (System Prompt vs. `tools`/`disallowedTools`) é mais confiável impor um limite de escopo — a aula sugere que ambos se complementam, mas qual pesa mais na prática?
