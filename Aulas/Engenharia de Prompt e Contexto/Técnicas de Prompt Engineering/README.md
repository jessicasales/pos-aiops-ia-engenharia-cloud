# Técnicas de Prompt Engineering — Engenharia de Prompt e Contexto

Anotações do capítulo **Técnicas de Prompt Engineering** do módulo **Engenharia de Prompt e Contexto** (curso Pós AIOps e IA na Engenharia de Cloud).

Se o capítulo *Fundamentos* cobriu os **frameworks** (como organizar o input), este capítulo cobre as **técnicas** (como controlar o processamento do modelo). Framework é a planta da casa; técnica é como você constrói. Vão das técnicas fundamentais (zero/few-shot) às de raciocínio (CoT, ToT, SoT, Self-Consistency, Step-Back).

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 04:08 | Framework vs. técnica; o que o capítulo cobre |
| 02 | [Zero-Shot](02-zero-shot.md) | 11:47 | Pedir sem exemplos — tarefas de uso comum |
| 03 | [Few-Shot (e One-Shot)](03-few-shot.md) | 12:32 | Guiar por exemplos (in-context learning); 3–5 exemplos |
| 04 | [Chain of Thoughts (CoT)](04-cot-chain-of-thoughts.md) | 22:04 | Raciocínio passo a passo; reasoning explícito |
| 05 | [Tree of Thoughts (ToT)](05-tot-tree-of-thoughts.md) | 18:48 | Ramificar, avaliar trade-offs e escolher a melhor |
| 06 | [Skeleton of Thoughts (SoT)](06-sot-skeleton-of-thoughts.md) | 15:15 | Gerar o esqueleto e depois expandir |
| 07 | [Self-Consistency](07-self-consistency.md) | 20:57 | Análises independentes → convergências |
| 08 | [Step-Back](08-step-back.md) | 19:48 | Levantar os conceitos fundamentais antes de resolver |

## Resumo rápido das técnicas

| Técnica | Diferencial | Use quando | Custo |
|---|---|---|---|
| Zero-Shot | Sem exemplos | Tarefa comum, output previsível | Baixo |
| Few-Shot | Exemplos no prompt | Estilo/padrão específico a replicar | Médio (input maior) |
| CoT | Raciocínio linear passo a passo | Uma resposta definitiva, múltiplas etapas | Alto |
| ToT | Ramificações, escolhe a melhor | Múltiplas opções válidas ("depende") | Alto |
| SoT | Esqueleto primeiro, depois expande | Respostas longas/estruturadas (docs, runbook) | Alto |
| Self-Consistency | Análises independentes → pontos em comum | Precisa de confiança/convergência | Muito alto |
| Step-Back | Conceitos fundamentais antes da análise | Precisa de base conceitual; combina com CoT/SC | Alto |

## Árvore de decisão (raciocínio)

- Tarefa simples e comum → **Zero-Shot**
- Precisa replicar estilo/padrão → **Few-Shot**
- Precisa raciocinar, **uma** resposta certa → **Chain of Thoughts**
- Precisa raciocinar, **várias** opções válidas → **Tree of Thoughts**
- Precisa estruturar resposta longa → **Skeleton of Thoughts**
- Precisa de confiança (convergência de visões) → **Self-Consistency**
- Precisa levantar conceitos antes → **Step-Back** (combina com as de cima)

> As técnicas de raciocínio consomem muito mais tokens. A escolha é sempre um equilíbrio entre **assertividade e custo**.
