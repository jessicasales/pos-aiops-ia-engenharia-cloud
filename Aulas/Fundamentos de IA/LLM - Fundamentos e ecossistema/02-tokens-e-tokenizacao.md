# Tokens e Tokenização

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | LLM - Fundamentos e ecossistema |
| **Aula** | 02 — Tokens e Tokenização (19:44) |
| **Assunto** | Token como menor unidade e base de cobrança; impacto do idioma no custo |
| **Data** | 04/11/2026 00:35 |
| **Tags** | token, tokenizacao, input, output, custo, portugues-vs-ingles, langchain |

## Resumo da aula

**Token** é a menor unidade de texto do LLM (fragmentos de palavras/caracteres). O modelo não processa seu texto direto: ele **tokeniza** o input, trabalha com os tokens e devolve tokens, que viram texto de novo. Token é a **unidade de cobrança** das APIs/ferramentas de IA.

## Conceitos principais

### Fluxo

`texto → tokenização → vetores → LLM → tokens de resposta → decodificação → texto`

Não há regra única de quebra — **cada modelo tokeniza diferente** (GPT, Anthropic, Gemini).

### Custo: input e output

A cobrança é por **token de input** (seu prompt + histórico) e **token de output** (a resposta) — o output costuma pesar mais. Prompt maior e resposta maior = mais caro. Mas prompt curto demais que gera resposta ruim também é "caro" (não atende).

### O idioma importa

**Português gasta mais tokens que inglês** (e idiomas asiáticos ainda mais). Na demo, o output em PT ficou ~25-32% mais caro que em inglês. Além do custo, idiomas além do inglês podem restringir a precisão dependendo do modelo.

> Dica: para economizar, escreva em inglês (ou peça tradução). Na pós, os prompts são em PT por clareza.

## Comandos e configurações

Demo: projeto Python (LangChain + Streamlit) que roda o mesmo prompt em PT/EN em vários modelos (Gemini Pro/Flash, Sonnet/Haiku) e compara tokens de input/output. Projeto no repositório do curso (Dev Container).

## Pegadinhas

- 2 mil "tokens" ≠ 2 mil palavras.
- Mesma família de modelos tende a contar input igual; o output varia.
- Cobrança real tem cache, mas o empilhamento de tokens aumenta o custo.

## Dúvidas para revisar

- Vale padronizar prompts internos em inglês para cortar custo?
- Como estimar o custo de uma tarefa pelo tamanho de input/output esperado?
