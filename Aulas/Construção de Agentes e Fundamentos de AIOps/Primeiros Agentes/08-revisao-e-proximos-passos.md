# Revisão e Próximos Passos

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 08 — Revisão e Próximos Passos (02:40) |
| **Assunto** | Fechamento do capítulo "Primeiros Agentes" — recapitulação dos conceitos vistos e gancho para o próximo capítulo, "Ferramentas e Capacidades Publicadas" |
| **Data** | 30/10/2026 01:15 |
| **Tags** | revisao, agente-vs-workflow, tools, mcp, interfaces, spec-driven-development |

## Resumo da aula

Aula curta de encerramento do capítulo "Primeiros Agentes". O instrutor recapitula, em linhas gerais, a diferença definitiva entre agente e workflow trabalhada ao longo do capítulo, lista os recursos que compõem um agente autônomo (modelo/LLM, ferramentas, System Prompt, e — adiantando o próximo capítulo — Skills), reforça a ligação com o conceito de "harness" visto anteriormente no curso (em agentes de codificação), e recomenda a prática deliberada dos fundamentos antes de avançar.

## Conceitos principais

### Síntese da diferença agente vs. workflow

O ponto central reforçado neste capítulo: um **agente** é muito mais imprevisível e não-determinístico em sua execução do que um **workflow** (automação simples conectada a um LLM) — e um agente dispõe de muito mais recursos do que um workflow: o modelo (LLM), as ferramentas (tools/MCP), o System Prompt e, adiante no curso, as Skills.

### O conceito de Harness reaparece

Toda a discussão sobre **harness** de um agente — já trabalhada anteriormente no curso no contexto de agentes de codificação (Claude Code, Codex) — se aplica igualmente aos agentes autônomos construídos com LangChain vistos neste capítulo: modelo, ferramentas, prompt e skills são, em conjunto, o harness do agente.

### O que foi efetivamente demonstrado no capítulo

Panorama do que foi construído, aula a aula: a anatomia de um agente (decisão → implementação), um primeiro chatbot com composição de contexto, conhecimento externo injetado via `TextLoader` (memória de longa duração "engessada"), a primeira `tool` real com `@tool`, a conexão a um MCP Server de terceiros (`mcp-server-kubernetes`) via `MCPAdapter`, e duas camadas de interface — CLI com Typer e interface de chat com Streamlit.

### Gancho para o próximo capítulo: "Ferramentas e Capacidades Publicadas"

O capítulo seguinte vai se aprofundar especificamente em ferramentas: como criar tools próprias, como criar os próprios MCP Servers e usá-los tanto em agentes autônomos quanto em agentes de codificação.

### Recomendação prática de estudo

O instrutor recomenda explicitamente: exercitar os fundamentos vistos, consultar a documentação das ferramentas apresentadas (LangChain, Typer, Streamlit, MCP), e começar a criar agentes de forma simples — sempre apoiado em **Spec Driven Development** (SDD), usando o Open Spec ou qualquer outro framework de especificação equivalente. O ponto mais importante, segundo o instrutor, é ter clareza suficiente para especificar corretamente TRDs e ADRs, de forma que a IA consiga construir exatamente o que se espera.

## Comandos e configurações

Não há código ou comandos nesta aula — é uma aula de revisão e fechamento de capítulo.

## Pegadinhas

- Não há pegadinhas técnicas nesta aula; é puramente uma consolidação conceitual.

## Dúvidas para revisar

- Rever, em conjunto, os projetos práticos construídos no capítulo (04-agente-runbook, 05-agente-runbook-tool, 06-assistente-plataforma, 07-assistente-plataforma-cli, 08-assistente-plataforma-chat) como uma progressão única, identificando o que mudou de um para o outro.
- Praticar a escrita de um TRD/ADR simples para um agente autônomo próprio, antes de avançar para o capítulo de ferramentas e MCP Servers customizados.
- Qual framework de Spec Driven Development (Open Spec ou outro) será usado como base para os próximos exercícios práticos do curso?
