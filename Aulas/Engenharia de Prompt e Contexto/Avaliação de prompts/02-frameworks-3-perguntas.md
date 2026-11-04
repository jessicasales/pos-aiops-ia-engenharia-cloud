# Framework das 3 perguntas

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 02 — Frameworks 3 perguntas (23:48) |
| **Assunto** | Estrutura base de avaliação: por quê (objetivo), como (métrica) e quem (avaliador) |
| **Data** | 04/11/2026 00:20 |
| **Tags** | por-que-como-quem, objetivo, metrica, avaliador, piramide-de-teste, llm-as-judge, pairwise |

## Resumo da aula

Antes de ferramenta, você precisa de **critérios e método**. Toda avaliação de prompt passa por **três perguntas-chave**: **por quê** (objetivo), **como** (métrica) e **quem** (avaliador). Pular qualquer uma = achismo.

## Conceitos principais

### 1. Por quê (objetivo)

Complete: *"Estou avaliando o prompt X em busca do resultado Y."* Objetivos comuns: correção factual, segurança, aderência ao formato, **custo**, **latência**, e comparação entre versões (**pairwise**). Define a dimensão da avaliação.

### 2. Como (métrica)

| Métrica | Natureza |
|---|---|
| **Objetiva** | Determinística (regex, schema, string) — exata |
| **Subjetiva** | Exige interpretação (qualidade de um post-mortem) — humana |
| **Sistêmica** | Custo, latência, tokens — viabilidade |
| **Comparativa** | Pairwise (compara outputs de 2 prompts) |

### 3. Quem (avaliador) — a pirâmide

| Avaliador | Prós | Contras |
|---|---|---|
| **Código determinístico** | Rápido, barato, escalável; 1ª linha de corte | Não pega nuance/interpretação |
| **LLM as judge** | Escala com interpretação | Precisa calibrar (é um prompt também) |
| **Humano** | Mais confiável | Lento (5-15 min/avaliação), não escala |

Pipeline recomendada: **código** (corte rápido e barato) → **LLM juiz** (escala com interpretação, calibrado por humano) → **humano** (estratégico) → **pairwise** (quando compara prompts).

## Comandos e configurações

Aula conceitual; exemplo de estrutura: *"bom em segurança, medido por schema validation + revisão humana, avaliado por código ou profissional"*.

## Pegadinhas

- O objetivo (por quê) muda toda a baseline — comece sempre por ele.
- Determinístico como **primeira linha de corte** (como o teste unitário): falhou, nem segue adiante.

## Dúvidas para revisar

- Para cada prompt crítico, quais são meus por quê / como / quem?
- Onde colocar o corte determinístico antes do LLM/humano?
