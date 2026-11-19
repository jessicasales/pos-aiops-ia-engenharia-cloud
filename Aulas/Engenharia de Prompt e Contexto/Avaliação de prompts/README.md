# Avaliação de prompts — Engenharia de Prompt e Contexto

Anotações do capítulo **Avaliação de prompts** do módulo **Engenharia de Prompt e Contexto** (curso Pós AIOps e IA na Engenharia de Cloud).

Depois de criar, versionar e refinar prompts, como saber se estão **realmente bons**? Este capítulo troca o achismo por método: critérios, rubricas, LLM como juiz e métricas objetivas — com o **Promptfoo** como ferramenta.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 02:43 | Por que medir; pirâmide de julgamento |
| 02 | [Framework 3 perguntas](02-frameworks-3-perguntas.md) | 23:48 | Por quê / como / quem |
| 03 | [Eval determinístico - Promptfoo](03-eval-deterministico-promptfoo.md) | 35:23 | Regex, schema, latência, custo |
| 04 | [Avaliação humana](04-avaliacao-humana.md) | 15:53 | Vieses e mitigações |
| 05 | [Rubrica](05-rubrica.md) | 13:04 | Critério, escala, âncora, peso, decisão |
| 06 | [Rubrica - prática](06-rubrica-pratica.md) | 10:07 | Template de rubrica |
| 07 | [LLM as Judge](07-llm-as-judge.md) | 19:55 | Juiz LLM, vieses, anatomia do prompt |
| 08 | [LLM as Judge - prática](08-llm-as-judge-pratica.md) | 16:38 | Juiz no Promptfoo + camadas |
| 09 | [Golden Answer](09-golden-answer.md) | 12:14 | Gabarito: factuality vs. closedqa |
| 10 | [Golden Answer - prática](10-golden-answer-pratica.md) | 17:38 | Dockerfile + causa raiz no Promptfoo |
| 11 | [Precision Recall - F1](11-precision-recall-f1.md) | 24:45 | Métricas objetivas em volume |

## A pirâmide de julgamento

| Camada | Avaliador | Custo | Escala |
|---|---|---|---|
| Base | **Determinístico** (regex, schema, latência, custo) | baixo | alta |
| Meio | **LLM as judge** (rubrica, golden answer) | médio | alta (calibrado) |
| Topo | **Humano** (critérios, calibração, auditoria) | alto | baixa |

## As 3 perguntas (sempre)

- **Por quê** → objetivo (factual, segurança, formato, custo, latência).
- **Como** → métrica (objetiva, subjetiva, sistêmica, comparativa).
- **Quem** → avaliador (código, LLM juiz, humano, pairwise).

## Técnicas-chave

- **Rubrica**: critério + escala + âncora + peso + regra de decisão.
- **LLM as judge**: juiz ≠ gerador (self-preference); cuidado com position/verbosity; calibrar.
- **Golden Answer**: `factuality` (tolerante) vs. `model-graded-closedqa` (literal).
- **Precision/Recall/F1**: acurácia esconde extremos; avalie F1 por classe **e** macro.

> Ferramenta: **Promptfoo** (declarativo YAML, CLI em CI, agnóstico, local). As camadas **somam** — determinístico corta barato, o juiz interpreta o resto.
