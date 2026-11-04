# LLM as Judge

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 07 — LLM as Judge (19:55) |
| **Assunto** | Usar um LLM como juiz para escalar a avaliação subjetiva; vieses e anatomia do prompt do juiz |
| **Data** | 04/11/2026 00:20 |
| **Tags** | llm-as-judge, juiz, escala, self-preference, position-bias, verbosity, calibracao, pointwise, pairwise |

## Resumo da aula

Meio-termo entre o determinístico (escala, sem interpretação) e o humano (interpreta, não escala): usar um **LLM como juiz**, aplicando a rubrica para dar score com justificativa, em **volume**. Sem um juiz automatizado não há teste de regressão a cada mudança de prompt.

## Conceitos principais

### Duas abordagens

- **Pointwise**: avalia um output (aprova/reprova por critério). 1 chamada por output.
- **Pairwise**: compara 2 outputs e diz qual é melhor. Mais chamadas → mais caro.

### Os 3 vieses do juiz

| Viés | O que é | Mitigação |
|---|---|---|
| **Self-preference** | O juiz favorece outputs do **mesmo modelo/família** | Juiz de **outra família** (gerar com Claude, julgar com Gemini/GPT) |
| **Position bias** | Em pairwise, favorece o **primeiro** output | Alternar a ordem e repetir |
| **Verbosity** | Dá nota maior a respostas **mais longas** | Corrigir via prompt (juiz rigoroso, ignora verbosidade) |

### Anatomia do prompt do juiz (4 blocos, nesta ordem)

1. **Role** (persona/linha de avaliação do juiz)
2. **Rubrica** (critérios, âncoras, pesos)
3. **Input + Output** (o input original dá contexto; o output é o que se avalia)
4. **Formato de saída** (estruturado, p/ tratamento sistêmico)

> Ordem importa: raciocínio antes do score melhora o reasoning. O juiz também precisa ser **calibrado** por humano (matriz de confusão juiz × humano).

## Comandos e configurações

Combine camadas no Promptfoo: asserts **determinísticos** (estáticos) + asserts de **LLM juiz** (`provider` do juiz ≠ gerador, ex.: Gemini). Não substitua o determinístico — **some**.

## Pegadinhas

- Gerar e julgar com a mesma família infla a nota (self-preference).
- O prompt do juiz é um prompt como outro: teste e calibre.

## Dúvidas para revisar

- Qual família uso como juiz para não cair em self-preference?
- Como montar a matriz de confusão juiz × humano para calibrar?
