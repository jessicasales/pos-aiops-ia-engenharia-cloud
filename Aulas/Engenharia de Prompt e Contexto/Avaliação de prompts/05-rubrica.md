# Rubrica

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 05 — Rubrica (13:04) |
| **Assunto** | Documento formal de avaliação: critério, escala, âncora, peso e regra de decisão |
| **Data** | 04/11/2026 00:20 |
| **Tags** | rubrica, criterio, escala, ancora, peso, regra-de-decisao, quality-gate, binario |

## Resumo da aula

A **rubrica** é o documento que formaliza os critérios de avaliação (vinda da área pedagógica — correção de redação). Torna a avaliação **reproduzível, escalável e rastreável**.

## Conceitos principais

### Os 5 componentes

| Componente | O que é |
|---|---|
| **Critério** | A pergunta feita ao output. Deve ser tão claro que o veredito é inevitável (sem interpretação). Ruim: "a análise está elegante?"; Bom: "todos os recursos citados existem no Cloud Provider?" |
| **Escala** | Os níveis do veredito. Binária (passou/não passou/com ressalva) ou numérica (1-5) |
| **Âncora** | A descrição/justificativa de cada nível ("1: não executa; 3: falha em edge case; 5: passa em todos") |
| **Peso** | Importância do critério (crítico/alto/médio/baixo). Crítico pode reprovar sozinho (ex.: senha hardcoded) |
| **Regra de decisão** | Combina pontuações + pesos → aprovação final (como um quality gate de CI, estilo SonarQube) |

### Binário vs. numérico

Prefira **binário** (aprovado/reprovado) — mais assertivo e menos enviesado. Escala numérica só com âncora bem definida. Pouca experiência → comece binário.

## Comandos e configurações

Aula conceitual; exemplo de rubrica fornecido na aula prática (próxima).

## Pegadinhas

- Critério vago exige interpretação → reescreva até o veredito ser inevitável.
- Pontuação numérica sem âncora forte sofre com humor/viés.

## Dúvidas para revisar

- Quais critérios do meu domínio têm peso **crítico** (reprovam sozinhos)?
- Binário ou numérico para cada critério?
