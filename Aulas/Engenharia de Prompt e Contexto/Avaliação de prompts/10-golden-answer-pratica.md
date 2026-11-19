# Golden Answer — prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 10 — Golden Answer - prática (17:38) |
| **Assunto** | Dois projetos Promptfoo: Dockerfile com factuality e causa raiz com model-graded-closedqa |
| **Data** | 04/11/2026 00:20 |
| **Tags** | golden-answer, pratica, promptfoo, factuality, closedqa, dockerfile, causa-raiz, oomkilled |

## Resumo da aula

Dois projetos completos no Promptfoo: (1) **Dockerfile** avaliado com `factuality` contra um gabarito; (2) **causa raiz** de incidente avaliada com `model-graded-closedqa`. Em ambos, **juiz Gemini ≠ gerador Haiku**. Troca-se o `reference` (gabarito bom/divergente) para ver aprovação/reprovação.

## Conceitos principais

- **Projeto 1 (factuality)**: prompt gera Dockerfile a partir de `{{stack}}`; o juiz compara contra `golden/dockerfile-reference-*.md`. Trocando a referência para uma que **exige multistage** que o output não tem, o factuality reprova.
- **Projeto 2 (closedqa)**: prompt diagnostica a causa raiz de um incidente OOMKilled; o juiz compara contra `golden/causa-raiz-reference-ok.md`. Com a referência **divergente** (atribui a memory leak), o juiz dá falso negativo — ilustra o perigo de gabarito errado.

## Comandos e configurações

<details>
<summary>Config factuality (Dockerfile) e closedqa (causa raiz)</summary>

```yaml
# promptfooconfig-dockerfile.yaml
prompts: [ file://prompt-dockerfile.md ]
providers:
  - id: anthropic:messages:claude-haiku-4-5-20251001
    config: { temperature: 0, max_tokens: 1024 }
defaultTest:
  options: { provider: google:gemini-2.5-flash }   # JUIZ ≠ GERADOR
tests:
  - vars:
      stack: file://inputs/input-node-api.md
      reference: file://golden/dockerfile-reference-multistage.md
    assert:
      - type: factuality
        value: "{{reference}}"
```

```yaml
# promptfooconfig-causa-raiz.yaml
prompts: [ file://prompt-causa-raiz.md ]
providers:
  - id: anthropic:messages:claude-haiku-4-5-20251001
    config: { temperature: 0, max_tokens: 1024 }
defaultTest:
  options: { provider: google:gemini-2.5-flash }
tests:
  - vars:
      incidente: file://inputs/input-incidente-oomkilled.md
      reference: file://golden/causa-raiz-reference-ok.md
    assert:
      - type: model-graded-closedqa
        value: "{{reference}}"
```

```bash
promptfoo eval -c promptfooconfig-dockerfile.yaml
promptfoo eval -c promptfooconfig-causa-raiz.yaml
```

Projeto completo no `10_golden_answer_pratica.zip` do material do curso.

</details>

## Pegadinhas

- `factuality` é tolerante (aceita variações sem contradição); `closedqa` é literal.
- Gabarito divergente = falso negativo garantido — valide a referência.

## Dúvidas para revisar

- Quais gabaritos de Dockerfile/diagnóstico eu consolido como golden answers do time?
- factuality ou closedqa conforme a rigidez exigida?
