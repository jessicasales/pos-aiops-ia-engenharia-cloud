# Introdução

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 01 — Introdução (06:32) |
| **Assunto** | Abertura do módulo: construir agentes autônomos do zero (sem Claude Code/Codex), usando LangChain/LangGraph/DeepAgents, para cenários de AIOps |
| **Data** | 29/10/2026 22:45 |
| **Tags** | aiops, agentes-autonomos, langchain, langgraph, deepagents, triagem-de-alertas |

## Resumo da aula

Abertura do módulo "Construção de Agentes e Fundamentos de AIOps". Até aqui, o curso trabalhou com agentes de forma **assistida** — usando ferramentas prontas (Claude Code, Codex) onde o humano monta o harness (skills, rules, MCP) e acompanha/verifica cada execução. Este módulo muda radicalmente de abordagem: os agentes serão **construídos do zero**, sem nenhuma ferramenta de codificação assistida, usando frameworks de desenvolvimento de agentes — para operar de forma **autônoma**, tomando decisões a partir de eventos/gatilhos, com intervenção humana mínima.

## Conceitos principais

### Agente assistido vs. agente autônomo

- **Assistido** (módulos anteriores): o humano determina a especificação, conduz o fluxo com a IA, e verifica o resultado — "ficar de babá" da IA, ainda que com muito ganho de produtividade.
- **Autônomo** (este módulo): o agente recebe um evento/gatilho e executa todo o processo de decisão — e muitas vezes de ação — sozinho, sem supervisão constante.

### Cenários típicos de agentes autônomos em AIOps

- **Triagem de alertas**: um alerta chega (ex.: do Prometheus), e o agente decide severidade, equipe destino, enriquece com dados do projeto, e resume para a equipe agir mais rápido — sem um humano acionando o agente manualmente a cada alerta.
- **Agente de observabilidade para incidentes**: obtém logs, métricas e eventos, correlaciona as informações para ajudar a detectar causa raiz.
- **Agente de documentação**: cria runbooks e post-mortems automaticamente, preservando o histórico do que aconteceu.

### Frameworks de construção de agentes no mercado

O instrutor cita o ecossistema (LangChain, SDK do Google, framework da Meta, CrewAI, entre outros) e anuncia que o módulo usará o **LangChain** como framework principal — um dos mais utilizados no mercado — explorando três camadas de construção dentro dele:
- **LangChain** (camada base).
- **LangGraph**.
- **DeepAgents**.

### Caminho pedagógico do módulo

O módulo não começa direto no agente autônomo. A progressão planejada:
1. **Automações e scripts determinísticos** (input → output, sem IA) — o que o aluno provavelmente já construiu antes.
2. **Inserir o LLM nesses fluxos** — adicionando um elemento interpretativo/de análise em tempo real, capaz de reagir a imprevistos ou erros durante a execução.
3. **Construção progressiva de agentes**, culminando em agentes autônomos de operação (AIOps).

## Comandos e configurações

Não há comandos nesta aula — é a introdução conceitual do módulo.

## Pegadinhas

Não há pegadinhas específicas nesta aula introdutória.

## Dúvidas para revisar

- Como o LangChain se diferencia na prática do Claude Code/Codex em termos de construção de agente — o que muda ao não ter mais um harness pronto de ferramenta?
- Quais critérios definem quando vale migrar de um fluxo assistido (módulo anterior) para um agente autônomo construído do zero (este módulo)?
- Como as camadas LangChain → LangGraph → DeepAgents se relacionam em complexidade e propósito?
