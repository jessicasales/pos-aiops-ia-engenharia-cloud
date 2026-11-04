# Tools

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 06 — Tools (10:40) |
| **Assunto** | A ponte do agente com o mundo externo; curadoria do output para não inflar a janela |
| **Data** | 04/11/2026 00:12 |
| **Tags** | tools, ferramentas, mundo-externo, react, curadoria-de-output, mcp, janela-de-contexto |

## Resumo da aula

Os componentes anteriores vivem "dentro" do agente. A **tool** é a ponte com o **mundo externo**: ler/editar arquivo, rodar `kubectl`, consultar Prometheus, Jira, GitHub. Sem ferramenta, o agente só trabalha com o que já tem na janela. O padrão por trás é o **ReAct** (raciocínio → ação → observação).

## Conceitos principais

### Tool faz curadoria, não só chamada de API

A função da tool não é só buscar/executar, mas **filtrar o retorno**. Se a tool devolve informação demais, ela **infla a janela de contexto** e pode causar Distraction/Poisoning. Ao implementar uma tool, preocupe-se com **o que ela retorna** — faça busca, filtre, e devolva só o necessário.

### Demo

- **Claude.ai** (sem acesso ao FS): pedir para analisar um projeto local → ele não consegue, tende a alucinar.
- **Claude Code** (com tools read/write/bash): executa comandos, lê o README e devolve informação real.

Tools estão muito ligadas a **MCP** (Model Context Protocol) — detalhado no próximo módulo.

## Comandos e configurações

Aula demonstrativa; sem prompt de referência (o foco é o papel e a responsabilidade da tool).

## Pegadinhas

- Conectar a tool não basta — pense no **output**: quantidade de informação que vai para a janela.
- Muitas tools, ou tools "verbosas", poluem o contexto e degradam o agente.

## Dúvidas para revisar

- Quais tools meu agente de AIOps precisa, e o que cada uma deve retornar (filtrado)?
- Como projetar o output das minhas tools para não estourar a janela?
