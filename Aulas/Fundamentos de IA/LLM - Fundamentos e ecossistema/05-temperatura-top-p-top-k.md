# Temperatura, Top-p e Top-k

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | LLM - Fundamentos e ecossistema |
| **Aula** | 05 — Temperatura, Top_p e Top_k (14:34) |
| **Assunto** | Parâmetros que controlam a geração: criatividade vs. determinismo |
| **Data** | 04/11/2026 00:35 |
| **Tags** | temperatura, top-p, top-k, determinismo, criatividade, latencia, alucinacao |

## Resumo da aula

Três parâmetros ajustam **como o modelo escolhe os tokens** na geração: **temperatura**, **top-k** e **top-p**.

## Conceitos principais

| Parâmetro | O que faz | Uso |
|---|---|---|
| **Temperatura** | Concentra (baixa) ou espalha (alta) a distribuição de probabilidade | 0 = determinístico/previsível; 0.7 = balanceado; 1.5-2 = muito aleatório |
| **Top-k** | Limita a um número fixo de tokens mais prováveis | Raro; melhor deixar desabilitado (pode cortar tokens importantes) |
| **Top-p** | Limita por **probabilidade acumulada** (soma até atingir P, ignora o resto) | Ajuste secundário; recomendação comum ~0.9 |

### Recomendações por tarefa

| Tarefa | Temperatura | Top-p |
|---|---|---|
| Código e comandos | 0 – 0.2 | desabilitado |
| Análise técnica | 0.3 – 0.5 | ~0.9 |
| Documentação | ~0.5 – 0.7 | — |
| Criativo (nomes, ideias) | > 1 | — |

> Na prática, o instrutor só mexe na **temperatura**. Ordem de ajuste: temperatura primeiro, top-p depois, top-k raramente.

### Cuidados

- Temperatura alta → mais **alucinação**, caracteres estranhos e **latência maior** (pesos mais distribuídos = resposta mais lenta).
- Cuidado com raciocínio matemático (LLM é probabilístico) e conhecimento desatualizado (modelos pré-treinados; mitigável com busca/base atual).

## Comandos e configurações

Demo: projeto Python (LangChain + Streamlit) com sliders de temperatura/top-k/top-p; temperatura 0 gera respostas quase idênticas; temperatura 2 demora muito e varia bastante. Projeto no repositório do curso.

## Pegadinhas

- Top-k pode cortar tokens relevantes — evite.
- Temperatura 2 é instável e lenta — use com parcimônia.

## Dúvidas para revisar

- Que temperatura padrão eu fixo para geração de código/IaC?
- Vale expor top-p em algum caso específico do meu fluxo?
