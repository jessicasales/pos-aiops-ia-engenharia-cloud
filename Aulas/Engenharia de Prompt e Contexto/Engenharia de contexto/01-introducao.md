# Introdução — Engenharia de contexto

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 01 — Introdução (11:03) |
| **Assunto** | Engenharia de contexto engloba a de prompt; modelos são stateless; componentes do ecossistema |
| **Data** | 04/11/2026 00:12 |
| **Tags** | engenharia-de-contexto, stateless, janela-de-contexto, memoria, componentes, antropic-vs-langchain |

## Resumo da aula

Engenharia de prompt resolve a **instrução**; engenharia de contexto resolve a **informação** — entregar a informação certa, na quantidade certa, no momento certo. Quando saímos do chat pergunta/resposta e vamos para **agentes** que rodam por minutos/horas (leem arquivos, rodam comandos, trocam mensagens), a engenharia de prompt vira **parte** da engenharia de contexto.

Ponto crítico: os modelos são **stateless**. Nada é persistido entre sessões — ao fechar a sessão, a janela de contexto some. Para reusar informação (histórico, preferências, runbooks), você precisa salvar e recuperar de forma deliberada (informação gera custo).

## Conceitos principais

### Componentes do ecossistema (o que o capítulo cobre)

System Prompt, Tools, RAG, compactação e descarte, memória de longo prazo, Scratchpad, State e múltiplos agentes (sandbox). Cada um é usado em momento diferente.

### Vocabulário varia por fonte

| Fonte | Como categoriza |
|---|---|
| LangChain / Lance Martin | Por operação: Write, Select (RAG), Compress, Isolate (sandbox/subagents) |
| Anthropic | Notas estruturadas, Just-in-Time Retrieval, Compactação, Subagents |

O instrutor prefere a abordagem da Anthropic. O importante é **entender os conceitos**, não decorar a nomenclatura (que muda por fabricante/artigo).

## Comandos e configurações

Aula conceitual, sem prompts de demonstração.

## Pegadinhas

- Stateless: não confunda o "chat" com memória persistente — a janela some ao fechar a sessão.
- Não basta jogar todo o histórico num Markdown e restaurar sempre — informação custa tokens.

## Dúvidas para revisar

- Quais informações do meu agente valem memória de longo prazo vs. só a sessão?
- Como mapear cada componente de contexto aos meus casos de AIOps?
