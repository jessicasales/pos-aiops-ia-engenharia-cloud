# LLM as Judge — prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 08 — LLM as Judge - prática (16:38) |
| **Assunto** | Implementar o LLM juiz no Promptfoo, combinado com asserts determinísticos |
| **Data** | 04/11/2026 00:20 |
| **Tags** | llm-as-judge, pratica, promptfoo, llm-rubric, provider-juiz, camadas |

## Resumo da aula

Implementação prática do juiz no Promptfoo. Mantém-se a **camada determinística** (regex, latência, custo) e adiciona-se a **camada probabilística** (juiz), usando um **provider de juiz diferente do gerador** (ex.: gerar com Haiku, julgar com Gemini) para evitar self-preference.

## Conceitos principais

- O juiz recebe role + rubrica + input/output + formato de saída estruturado.
- As duas camadas **somam**: determinístico corta o óbvio e barato; o juiz interpreta o resto.
- Calibração: nos primeiros ciclos, o humano confere o juiz (convergência/divergência) e você refina o prompt do juiz.

## Comandos e configurações

<details>
<summary>Estrutura no Promptfoo (determinístico + juiz)</summary>

```yaml
prompts:
  - file://prompts/gerar-dockerfile.md
providers:
  - id: anthropic:messages:claude-haiku-4-5-20251001   # GERADOR
    config: { temperature: 0 }
defaultTest:
  options:
    provider: google:gemini-2.5-flash                  # JUIZ ≠ GERADOR
tests:
  - vars: { stack: "Node.js 20" }
    assert:
      # camada determinística (barata, estática)
      - type: not-regex
        value: ':latest'
      # camada probabilística (juiz aplica a rubrica)
      - type: llm-rubric
        value: |
          Avalie o Dockerfile. Reprove se rodar como root, se não usar
          multistage quando aplicável, ou se expuser segredos.
```

```bash
promptfoo eval -c promptfooconfig.yaml
promptfoo view
```

</details>

## Pegadinhas

- Defina o `provider` do juiz no `defaultTest.options` (ou por assert) — garantindo família diferente do gerador.
- Trate o output do juiz de forma estruturada (automação), não Markdown.

## Dúvidas para revisar

- Qual a divisão ideal entre asserts determinísticos e juiz nos meus prompts?
- Como versionar o prompt do juiz junto com o prompt avaliado?
