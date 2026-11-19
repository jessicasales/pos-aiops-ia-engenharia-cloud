# Golden Answer

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 09 — Golden Answer (12:14) |
| **Assunto** | Avaliar comparando o output contra um gabarito; factuality vs. model-graded closedqa |
| **Data** | 04/11/2026 00:20 |
| **Tags** | golden-answer, gabarito, factuality, model-graded-closedqa, subset, equivalencia, contradicao |

## Resumo da aula

No LLM as judge "freestyle", o juiz constrói internamente a resposta ideal. Com o **Golden Answer** você passa também um **gabarito** (resposta de ouro). O juiz **compara o output contra a referência** — julgamento mais estável, rubrica pode ser mais sucinta.

## Conceitos principais

### Dois instrumentos de comparação

| Instrumento | Rigor | Comportamento |
|---|---|---|
| **factuality** | Tolerante ao formato | Aceita variações desde que não **contradiga** o gabarito |
| **model-graded closedqa** | Literal | Exige perfil de resposta mais fechado (mesmas informações) |

### Categorias do factuality

- **Subset**: o output contém parte correta do gabarito → passa.
- **Equivalência**: mesma informação em formato diferente → passa.
- **Superconjunto**: output vai além do gabarito (com info correta) → passa.
- **Contradição**: output contradiz um fato do gabarito → **reprova** (ex.: gabarito usa `USER node`, output roda como root).

## Comandos e configurações

<details>
<summary>Promptfoo com Golden Answer (factuality e closedqa)</summary>

```yaml
# factuality — tolerante
providers:
  - id: anthropic:messages:claude-haiku-4-5-20251001   # gerador
    config: { temperature: 0 }
defaultTest:
  options:
    provider: google:gemini-2.5-flash                  # juiz ≠ gerador
tests:
  - vars:
      stack: file://inputs/input-node-api.md
      reference: file://golden/dockerfile-reference.md
    assert:
      - type: factuality
        value: "{{reference}}"
```

```yaml
# model-graded-closedqa — literal (ex.: diagnóstico de causa raiz)
tests:
  - vars:
      incidente: file://inputs/input-incidente-oomkilled.md
      reference: file://golden/causa-raiz-reference-ok.md
    assert:
      - type: model-graded-closedqa
        value: "{{reference}}"
```

</details>

## Pegadinhas

- Um gabarito **errado** gera falso negativo: o gerador acerta, mas o juiz reprova porque compara contra a referência incorreta.
- Use Golden Answer quando já tiver a resposta de referência; senão, fique no juiz freestyle.

## Dúvidas para revisar

- Para quais prompts eu já tenho gabaritos (Dockerfile padrão, diagnóstico de referência)?
- factuality (tolerante) ou closedqa (literal) para cada caso?
