# Sugestão de Comandos e Scripts

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | GenIA - Cotidiano técnico |
| **Aula** | 03 — Sugestão de Comandos e Scripts (09:05) |
| **Assunto** | Gerar comandos/scripts com IA e o ciclo de validação antes de produção |
| **Data** | 04/11/2026 00:55 |
| **Tags** | comandos, scripts, aws-cli, python, boto3, validacao, dry-run |

## Resumo da aula

A IA brilha em gerar comandos e scripts (shell, Python, manifestos K8s). Regra: **seja específico** (ferramenta, versão, CLI) e **sempre valide** antes de produção.

## Conceitos principais

- Exemplo: pedir uma sequência de comandos AWS CLI (criar bucket, versionamento, bloquear acesso público, criptografia, lifecycle) com explicação de cada um. Depois, transformar isso num **script Python (boto3)** — a IA segue os princípios da linguagem pedida.
- **Ciclo de validação**: pedir ajustes, combinar com contexto real, testar em ambiente seguro (dev/staging), usar `dry-run` quando possível, checar flags/docs. **Nunca** executar em produção algo não verificado (risco de alucinação).

## Prompts da aula

<details>
<summary>Exemplos</summary>

```text
# Comandos AWS CLI (com explicação)
Gere os comandos AWS CLI para criar um bucket S3 com versionamento,
bloqueio de acesso público, criptografia SSE-S3 e lifecycle (expira após 90/365 dias).
Para cada comando, explique o que ele faz.
```

```text
# Transformar em script Python
Gere um script em Python (boto3) para [mesma tarefa], comentado.
```

</details>

## Pegadinhas

- Não copie/cole em produção — valide em conta/ambiente de teste.
- Seja explícito sobre linguagem, versão e ferramenta (CLI, Helm, kubectl).

## Dúvidas para revisar

- Qual meu ciclo de validação padrão para scripts gerados por IA?
- Vale pedir README separado em vez de comentários no código?
