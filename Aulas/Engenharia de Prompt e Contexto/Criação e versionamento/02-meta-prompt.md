# Meta Prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Criação e versionamento |
| **Aula** | 02 — Meta prompt (07:43) |
| **Assunto** | Os três significados de meta prompt (craft, orquestração, otimização automática) e o foco no craft |
| **Data** | 04/11/2026 00:05 |
| **Tags** | meta-prompt, craft, orquestracao, otimizacao-automatica, especificidade, modelo-caro-na-criacao |

## Resumo da aula

"Meta prompt" tem **três significados** na literatura; a aula alinha isso para você não se confundir e foca no primeiro (**craft**).

## Conceitos principais

### Os três significados

| Significado | O que é | Humano no controle? |
|---|---|---|
| **Craft** (foco do capítulo) | Usar IA para **criar prompts**, com o humano decidindo e assinando o prompt final | Sim, do início ao fim |
| **Orquestração** | Um LLM "maestro" gera prompts em runtime para orquestrar outros LLMs (multiagentes) | Não — IA direto |
| **Otimização automática** | A IA gera o prompt de ponta a ponta; você só define métricas e datasets (gerador → avaliador → seletor) | Não |

Termos que aparecem na orquestração/otimização (APE, DSPy, OPRO) ficam para módulos futuros. Referência citada: Suzgun & Kalai (2024).

### Duas premissas antes de criar

1. **Especificidade** — "crie um prompt para analisar log" gera prompt genérico. Deixe claro role, contexto e objetivo.
2. **Modelo caro na criação, barato na execução** — use o melhor modelo (Opus, GPT avançado, Gemini Pro) para **criar** o prompt (reasoning maior = prompt melhor). Na **execução**, teste modelos mais baratos (Sonnet, Haiku, mini). *"Invista na construção, economize na execução."*

## Comandos e configurações

Aula conceitual, sem prompts de demonstração.

## Pegadinhas

- Ao pesquisar "meta prompt" na internet você encontra definições diferentes — a aula usa o **craft**; os outros sentidos (orquestração, otimização) vêm depois.
- Economizar no modelo **na hora de criar** o prompt é falso ganho: o reasoning fraco gera prompt pior.

## Dúvidas para revisar

- Qual modelo premium eu uso para gerar prompts e qual modelo barato para executá-los?
- Quais dos meus casos de uso são craft e quais, futuramente, seriam orquestração de agentes?
