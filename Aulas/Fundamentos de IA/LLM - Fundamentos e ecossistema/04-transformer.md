# Arquitetura Transformer

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | LLM - Fundamentos e ecossistema |
| **Aula** | 04 — Transformer (07:37) |
| **Assunto** | Como o LLM gera respostas: tokenização, embedding e geração token a token |
| **Data** | 04/11/2026 00:35 |
| **Tags** | transformer, embedding, vetores, geracao-token-a-token, probabilidade, alucinacao |

## Resumo da aula

A **arquitetura Transformer** é como os LLMs processam a entrada e geram a resposta. Visão simplificada (alto nível): **entrada → tokenização → embedding → análise de contexto → saída**.

## Conceitos principais

### O fluxo

1. **Prompt de entrada** (ex.: "inteligência artificial é").
2. **Tokenização**: quebra em tokens (regra varia por modelo).
3. **Embedding**: cada token vira um **vetor** (lista de valores numéricos, ex.: `0.2, -0.5, 0.8...`).
4. **Geração token a token**: o modelo calcula, por **probabilidade estatística**, qual é o próximo token mais provável, adiciona, e repete até completar a resposta.

### Por que importa

- O modelo **não sabe dizer "não sei"** — ele sempre gera o próximo token mais provável → pode **alucinar**.
- É uma máquina de **probabilidade**, não de raciocínio como o humano.
- Controlar essa geração (afunilar ou ampliar as possibilidades) é o papel de **temperatura, top-k e top-p** (próxima aula).

## Comandos e configurações

Aula conceitual (diagrama); demo dos parâmetros na aula seguinte.

## Pegadinhas

- Dados precisos (estatística, código) pedem geração mais afunilada; texto criativo pede mais abertura.
- A resposta é construída token a token — daí a latência crescer com certas configurações.

## Dúvidas para revisar

- Como a geração token a token explica as alucinações que vejo?
- Quando preciso afunilar (preciso) vs. ampliar (criativo) a geração?
