# Subagentes

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 10 — Subagentes (10:31) |
| **Assunto** | Distribuir tarefas entre agentes especializados, cada um com seu system prompt e janela isolada |
| **Data** | 04/11/2026 00:12 |
| **Tags** | subagentes, multiagente, orquestrador, especializacao, paralelismo, janela-isolada, claude-code |

## Resumo da aula

Em vez de um agente único executando tudo de forma linear, você distribui tarefas menores entre **subagentes** — como uma equipe com papéis diferentes e um **orquestrador** (tech lead). Ganhos: **velocidade** (paralelismo), **especificidade** (cada subagente tem seu system prompt/persona) e **gestão da janela de contexto**.

## Conceitos principais

### Três vantagens

| Vantagem | Como |
|---|---|
| **Especialização** | Cada subagente tem seu **system prompt** (persona/escopo) — ex.: subagente de Kubernetes, de Prometheus, de código |
| **Paralelismo** | Tarefas quebradas rodam ao mesmo tempo |
| **Janela isolada** | Cada subagente tem sua própria janela; o orquestrador recebe só o resultado **limpo/condensado** |

> O subagente define **persona/especialização**, não "qual tarefa" nem "como executar" — é sobre filtrar a área de conhecimento.

### Arquitetura

Usuário → **orquestrador** → quebra em subtarefas → subagentes executam isolados → devolvem resultado → orquestrador consolida. (Subagentes também podem se comunicar entre si em arquiteturas mais complexas.)

### Demo (Claude Code)

Um subagente `log-investigator` lê um arquivo de logs **na própria janela** e devolve só o **resumo** ao agente principal — sem inflar o contexto do orquestrador.

## Prompts da aula

<details>
<summary>Prompt de acionamento do subagente</summary>

```text
Utilize o agente log-investigator e investigue o arquivo log do checkout-service
que está no projeto. Encontre os erros e me traga um resumo.
```

Entrada da demo: logs do `checkout-service` (app + Kubernetes + PostgreSQL) numa falha em cascata — réplica de leitura cai → pods saturam/OOM → timeouts de pagamento e 504 ao usuário.

</details>

## Pegadinhas

- Subagente ≠ Sandbox: subagente isola **janela/persona**; sandbox isola **execução de código**.
- O ganho de contexto vem de o orquestrador receber só o resultado, não o ruído da investigação.

## Dúvidas para revisar

- Quais personas de subagente fazem sentido no meu AIOps (K8s, Prometheus, código)?
- Que tarefas pesadas de leitura eu delegaria a um subagente para poupar o contexto principal?
