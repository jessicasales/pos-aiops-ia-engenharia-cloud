# Precision, Recall e F1

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 11 — Precision Recall - F1 (24:45) |
| **Assunto** | Métricas objetivas sobre volume de dados; matriz de confusão, F1 macro e por classe |
| **Data** | 04/11/2026 00:20 |
| **Tags** | precision, recall, f1, acuracia, matriz-de-confusao, multiclasse, f1-macro, promptfoo |

## Resumo da aula

Avaliar com **acurácia** (% de acertos) sobre um volume de dados **não basta**: 95% de acerto pode esconder que os 5% perdidos eram justamente os **críticos**. Precision, Recall e F1 separam **como** o modelo erra.

## Conceitos principais

### Matriz de confusão

| | Realmente é | Não é |
|---|---|---|
| **Detectou** | TP (verdadeiro positivo ✓) | FP (falso positivo — alarme falso) |
| **Não detectou** | FN (falso negativo — incidente que passou) | TN (verdadeiro negativo ✓) |

### As três métricas

| Métrica | Pergunta | Fórmula | Penaliza |
|---|---|---|---|
| **Precision** | Dos alarmes que dei, quantos eram reais? | TP / (TP + FP) | Falso positivo (ruído) |
| **Recall** | Dos reais, quantos peguei? | TP / (TP + FN) | Falso negativo (deixa passar) |
| **F1** | Equilíbrio entre os dois | 2·TP / (2·TP + FP + FN) | Cai se qualquer um cair |

Precision e Recall têm **contraste**: mexer em um afeta o outro. O F1 (média harmônica) mede o equilíbrio.

### Multiclasse

Com mais de 2 classes (crítico/médio/normal), calcule **F1 por classe** (um-contra-todos) e o **F1 macro** (média). Avalie **macro E por classe**: o macro pode aprovar enquanto a classe **crítica** reprova (não aceite só a média — ela esconde extremos).

## Comandos e configurações

<details>
<summary>Promptfoo: contadores TP/FP/FN + métricas derivadas</summary>

```yaml
defaultTest:
  assert:
    - type: javascript   # TP: era CRITICO e disse CRITICO
      value: "(output.trim().toUpperCase()==='CRITICO' && context.vars.expected==='CRITICO') ? 1 : 0"
      metric: tp_critico
      weight: 1
      threshold: 0       # conta, mas não reprova a linha
    - type: javascript   # FP
      value: "(output.trim().toUpperCase()==='CRITICO' && context.vars.expected!=='CRITICO') ? 1 : 0"
      metric: fp_critico
      weight: 1
      threshold: 0
    - type: javascript   # FN
      value: "(output.trim().toUpperCase()!=='CRITICO' && context.vars.expected==='CRITICO') ? 1 : 0"
      metric: fn_critico
      weight: 1
      threshold: 0
derivedMetrics:
  - name: precision_critico
    value: "tp_critico / (tp_critico + fp_critico)"
  - name: recall_critico
    value: "tp_critico / (tp_critico + fn_critico)"
  - name: f1_critico
    value: "2 * tp_critico / (2 * tp_critico + fp_critico + fn_critico)"
  - name: aprovado_f1_90
    value: "f1_critico >= 0.9 ? 1 : 0"   # SLA de qualidade
```

Detalhe Promptfoo: `weight: 1` faz a métrica somar; `threshold: 0` mantém a linha PASS mesmo quando o assert devolve 0. Dataset em CSV (`log_entry,expected`). Projeto completo no `11_precision_recall_f1.zip`.

</details>

## Pegadinhas

- Acurácia média esconde extremos — avalie macro **e** por classe.
- F1 cai se precision **ou** recall cair — é o número único de qualidade da classe.
- Defina o SLA (ex.: F1 ≥ 0.9) como flag de aprovação, pois o Promptfoo julga linha a linha, não a rodada.

## Dúvidas para revisar

- Qual métrica priorizo: evitar falso positivo (precision) ou falso negativo (recall)?
- Que F1 mínimo (SLA) por classe crítica eu exijo antes de produção?
