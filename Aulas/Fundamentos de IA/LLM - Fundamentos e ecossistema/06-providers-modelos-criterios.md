# Providers, modelos e critérios de escolha

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | LLM - Fundamentos e ecossistema |
| **Aula** | 06 — Providers, modelos e critérios de escolha (06:11) |
| **Assunto** | Panorama de providers, LLM vs. SLM e os 4 critérios de escolha |
| **Data** | 04/11/2026 00:35 |
| **Tags** | providers, llm, slm, custo, latencia, qualidade, privacidade |

## Resumo da aula

Não existe "o modelo campeão" — **tudo depende** do que você está fazendo. A aula dá o panorama de providers e os critérios para escolher.

## Conceitos principais

### Providers e modelos

OpenAI (GPT), Anthropic (Claude: Opus/Sonnet/Haiku), Google (Gemini), Meta (Llama), Mistral, DeepSeek (chinês, eficiente em treino e bom em código). Precificação **por token** — compare custo + qualidade testando com seus prompts. O instrutor alterna entre **OpenAI, Anthropic e Google**.

### LLM vs. SLM

| | LLM (Large) | SLM (Small) |
|---|---|---|
| Parâmetros | 50 bi+ | < 10 bi |
| Exemplos | GPT-5, Opus | Gemma, Llama pequeno, Mistral |
| Bom para | arquitetura, ADR, sistemas complexos | análise de logs, resumos, textos simples |

SLMs podem rodar **localmente** e atendem a maioria das tarefas.

### Os 4 critérios de escolha

1. **Custo** — SLMs são mais baratos (e locais).
2. **Latência** — SLMs respondem mais rápido.
3. **Qualidade** — LLMs com reasoning (Opus, GPT-5) respondem melhor, mas custam mais.
4. **Privacidade** — SLM local mantém os dados privados (sem transitar por API).

## Comandos e configurações

Aula conceitual; o instrutor disponibiliza o projeto + links dos providers e tabelas de preço no material do curso.

## Pegadinhas

- Não busque um modelo único — monte um fluxo de decisão por tarefa.
- Dados sensíveis podem pedir SLM local por privacidade.

## Dúvidas para revisar

- Qual meu fluxo de decisão LLM × SLM por tipo de tarefa?
- Onde a privacidade exige modelo local?
