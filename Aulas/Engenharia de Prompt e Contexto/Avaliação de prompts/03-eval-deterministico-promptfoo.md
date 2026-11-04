# Eval determinístico — Promptfoo

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 03 — Eval determinístico - Promptfoo (35:23) |
| **Assunto** | Base da pirâmide: avaliação determinística (regex, schema, latência, custo) com Promptfoo |
| **Data** | 04/11/2026 00:20 |
| **Tags** | promptfoo, deterministico, regex, asserts, yaml, ci-cd, latencia, custo |

## Resumo da aula

A base da pirâmide é o teste **determinístico** — rápido e barato (regex, template, string, latência, custo). A ferramenta do capítulo é o **Promptfoo**.

## Conceitos principais

### Por que Promptfoo

- **Declarativo** (YAML) → versionável no Git.
- Roda em **CI** (CLI em Node → GitHub Actions, GitLab, Jenkins).
- **Agnóstico** (Anthropic, Google, OpenAI...).
- **Local** (open source). Alternativas citadas: DeepEval (acoplado a Python/pytest), LangSmith (acoplado ao LangChain), Braintrust, Langfuse (open source).

### Estrutura do YAML

`prompts` (texto inline ou `file://`), `providers` (modelos), `tests` (cada um com `vars` e `assert`). Asserts determinísticos: `regex`, `not-regex`, `contains`, `icontains`, `is-json`, `is-sql`, `latency`, `cost`.

## Comandos e configurações

<details>
<summary>Comandos e exemplo de config (determinístico)</summary>

```bash
promptfoo init                    # inicializa o projeto
export ANTHROPIC_API_KEY=...      # chave do provider
promptfoo eval                    # roda a avaliação (promptfooconfig.yaml)
promptfoo eval -c arquivo.yaml    # config específico (um por prompt)
promptfoo view                    # abre a interface web (localhost:15500)
```

```yaml
description: "Variação do prompt gerador de Dockerfile"
prompts:
  - file://prompts/gerar-dockerfile.md
providers:
  - id: anthropic:messages:claude-haiku-4-5-20251001
    config:
      temperature: 0
tests:
  - vars:
      stack: "Node.js 20"
    assert:
      - type: regex          # exige uma tag declarada
        value: 'FROM\s+\S+:\S+'
      - type: not-regex      # não pode ser :latest
        value: ':latest'
      - type: regex          # tem que declarar USER (não roda como root)
        value: 'USER\s+\w+'
      - type: latency
        threshold: 15000     # < 15s
      - type: cost
        threshold: 0.002     # < US$ 0,002
  - vars: { stack: "Python 3.12 FastAPI" }
  - vars: { stack: "Go 1.22" }
```

</details>

## Pegadinhas

- Prefira `file://` apontando para o Markdown do prompt (não colar o prompt no YAML — evita acoplar à ferramenta).
- `temperature: 0` para resultado reproduzível.
- Para conteúdo que exige interpretação (veracidade, tom), o determinístico não serve — use LLM as judge.

## Dúvidas para revisar

- Quais asserts determinísticos já cortam 80% dos meus casos ruins?
- Como colocar o `promptfoo eval` numa GitHub Action sobre o repositório de prompts?
