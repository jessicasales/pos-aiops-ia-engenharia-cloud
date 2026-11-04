# Análise de Logs e Troubleshooting

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | GenIA - Cotidiano técnico |
| **Aula** | 02 — Análise de Logs e Troubleshooting (13:28) |
| **Assunto** | Usar a IA para correlacionar logs, achar causa raiz e sugerir resolução — com cuidado com dados sensíveis |
| **Data** | 04/11/2026 00:55 |
| **Tags** | troubleshooting, logs, causa-raiz, correlacao, crashloopbackoff, dados-sensiveis, mascaramento |

## Resumo da aula

A IA acelera e dá assertividade ao troubleshoot: correlaciona logs de aplicação + cluster + métricas e aponta a causa raiz. Dois exemplos: um pod em CrashLoopBackOff e uma falha em cascata.

## Conceitos principais

- Exemplo 1 (simples): colar `kubectl logs` + `kubectl describe` do pod → a IA identifica falha de autenticação no PostgreSQL e sugere comandos (que podem não casar exatamente, pois há pouco contexto).
- Exemplo 2 (cascata): log grande → pedir para **agrupar por categoria, correlacionar e dar causa raiz**. A IA reconstrói a timeline (normal → degradação → colapso → recuperação), identifica esgotamento do pool de conexões como causa raiz e lista recomendações — em segundos.

### Segurança (crítico)

**Nunca envie dados sensíveis** à IA: tokens de API, senhas, chaves SSH, dados de usuário. Mascare logs/IPs/tokens antes. Especialmente em OpenAI/Claude Code (dados do usuário).

## Prompts da aula

<details>
<summary>Prompts de troubleshoot</summary>

```text
# Pod em CrashLoopBackOff
Analise o log abaixo de um pod no Kubernetes que está em CrashLoopBackOff.
Identifique a causa raiz e sugira como resolver.
[kubectl logs ... / kubectl describe ...]
```

```text
# Falha em cascata
Analise os logs abaixo de um sistema de produção. Resuma o comportamento,
agrupe eventos por categoria, identifique correlações entre os problemas
e sugira a causa raiz mais provável.
[bloco de logs]
```

</details>

## Pegadinhas

- Pouco contexto = comandos sugeridos genéricos; o ideal é a IA acessar o cluster em tempo real (visto depois).
- Faça a filtragem/mascaramento de dados sensíveis antes de enviar.

## Dúvidas para revisar

- Meu pipeline de observabilidade já mascara dados sensíveis antes da IA?
- Quais correlações recorrentes eu peço à IA para acelerar o RCA?
