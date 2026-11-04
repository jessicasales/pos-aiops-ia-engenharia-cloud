# Rubrica — prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 06 — Rubrica - prática (10:07) |
| **Assunto** | Estrutura de rubrica pronta para aplicar na avaliação de outputs |
| **Data** | 04/11/2026 00:20 |
| **Tags** | rubrica, pratica, template, criterios, pesos, checklist |

## Resumo da aula

Demonstração de uma **estrutura de rubrica** pronta (template) para avaliar outputs, materializando os 5 componentes da aula anterior (critério, escala, âncora, peso, regra de decisão). O processo completo de avaliação não é feito do zero por ser longo; o foco é mostrar o **instrumento** para você adaptar.

## Conceitos principais

- A rubrica reúne, para cada critério: a **pergunta** (inevitável), a **escala** (binária/numérica), a **âncora** (descrição de cada nível), o **peso** (crítico/alto/médio/baixo) e a **regra de decisão** final.
- É versionável junto com o prompt (Markdown/YAML) e serve de base para o **LLM as judge** (que recebe a rubrica nos critérios).

## Comandos e configurações

Material da aula traz o template de rubrica (disponível no repositório do curso). Use como ponto de partida e adapte os critérios ao seu domínio.

## Pegadinhas

- A rubrica é um artefato vivo: refine os critérios conforme avalia.
- Critérios com peso crítico definem a aprovação — revise-os com cuidado.

## Dúvidas para revisar

- Qual rubrica inicial para os meus outputs mais comuns (Dockerfile, post-mortem)?
- Como ligar essa rubrica ao prompt do juiz?
