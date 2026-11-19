# AWS Bedrock (e Amazon Q)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | Ferramentas e plataformas |
| **Aula** | 07 — AWS Bedrock (09:58) |
| **Assunto** | Serviço de modelos da AWS (Bedrock) e o assistente Amazon Q |
| **Data** | 04/11/2026 00:45 |
| **Tags** | aws, bedrock, amazon-q, catalogo-de-modelos, api-key, calculadora-aws |

## Resumo da aula

A AWS tem vários serviços de IA; o foco é o **Amazon Bedrock** (modelos) e o **Amazon Q** (assistente).

## Conceitos principais

### Amazon Q (assistente)

Conversa em linguagem natural sobre a conta AWS: listar buckets S3, instâncias EC2, consultar **fatura/previsão de custo**. Útil para investigar o que está rodando e gerando cobrança (precisa de permissão de acesso).

### Amazon Bedrock (modelos)

- **Catálogo de modelos**: Amazon Nova, Anthropic (Claude Opus/Sonnet/Haiku), Google Gemma (open source), DeepSeek, etc. — todos rodando na AWS.
- **API keys** (curta/longa duração) para consumir via código.
- **Playground**: testar chat/imagem, ajustar system prompt, temperatura, top-p, **guardrails**.
- Também oferece fine-tuning, agentes, flows, gerenciamento de prompts (na pós usa-se n8n para flows, mantendo-se agnóstico).

### Custo

Use a **calculadora AWS** (`calculator.aws`): escolha região, modelo (sob demanda), média de req/min, tokens de input/output → estimativa.

## Pegadinhas

- A conta precisa de permissão para o Amazon Q ler recursos/fatura.
- Modelos "4" aparecem como legado — use os atuais.

## Dúvidas para revisar

- Vale usar Bedrock para consolidar modelos (Claude, Gemma, DeepSeek) com billing AWS?
