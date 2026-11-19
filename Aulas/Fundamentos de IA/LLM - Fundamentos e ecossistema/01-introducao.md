# Introdução aos LLMs

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | LLM - Fundamentos e ecossistema |
| **Aula** | 01 — Introdução (12:07) |
| **Assunto** | O que é um LLM, parâmetros, modelo vs. ferramenta, treinamento e fine-tuning |
| **Data** | 04/11/2026 00:35 |
| **Tags** | llm, parametros, modelo-vs-ferramenta, pre-treinamento, fine-tuning, previsao-de-palavra, alucinacao |

## Resumo da aula

**LLM** (Large Language Model) = modelo de linguagem alimentado com **grande volume de texto**. Quanto mais informação armazenada (**parâmetros**), maior a capacidade. O modelo não guarda texto como banco de dados — guarda **vetores matemáticos** (pesos) e **prevê a próxima palavra** por probabilidade estatística.

## Conceitos principais

### Modelo ≠ Ferramenta

| Modelo (LLM) | Ferramenta (produto) |
|---|---|
| GPT (OpenAI) | ChatGPT |
| Sonnet/Opus (Anthropic) | Claude.ai |
| Gemini (Google) | Gemini |

Ao desenvolver, você escolhe o **modelo** (por objetivo, custo, capacidade) — não a ferramenta.

### Como o modelo é feito

1. **Pré-treinamento**: consome texto (artigos, livros, código, fóruns) e aprende a **prever a próxima palavra** (erra, ajusta pesos, repete bilhões de vezes).
2. **Modelo base** → armazenado em **parâmetros** (pesos numéricos), não como texto.
3. **Fine-tuning**: refinamento (como um "commit" no modelo, gerando nova versão).

> Na pós não se faz fine-tuning (caro/demorado) — usam-se modelos prontos + **contexto** (diferente de fine-tuning).

## Comandos e configurações

Aula conceitual.

## Pegadinhas

- Alucinação está ligada a prompt **e** à qualidade do treinamento/fine-tuning.
- Contexto (injetar informação) ≠ fine-tuning (reentreinar o modelo).

## Dúvidas para revisar

- Por objetivo/custo, qual modelo escolho para cada tipo de tarefa?
- Quando preciso de contexto (RAG) vs. quando pensaria em fine-tuning?
