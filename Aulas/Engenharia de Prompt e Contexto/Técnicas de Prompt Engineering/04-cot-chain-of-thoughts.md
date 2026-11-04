# Chain of Thoughts (CoT)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 04 — CoT (22:04) |
| **Assunto** | Forçar raciocínio passo a passo; reasoning explícito vs. implícito; CoT encadeado |
| **Data** | 03/11/2026 23:50 |
| **Tags** | chain-of-thoughts, cot, reasoning, raciocinio-explicito, analise-de-log, causa-raiz, post-mortem |

## Resumo da aula

Primeira técnica de **cadeia de raciocínio**. No **Chain of Thoughts** você pede que o modelo faça uma análise **passo a passo** antes de concluir. Forçar o raciocínio faz o modelo levantar mais contexto (cada etapa vira contexto para a próxima), o que **reduz alucinação** e aumenta assertividade em tarefas complexas.

## Conceitos principais

### Reasoning explícito vs. implícito

| | Implícito | Explícito |
|---|---|---|
| **O que é** | O modelo raciocina por conta própria (já é característica dele) | Você define no prompt os tópicos/subtópicos de raciocínio |
| **Controle** | Nenhum — o modelo escolhe a estrutura | Você direciona a análise |
| **Resultado** | Bom, mas sem direcionamento | **20% a 80% melhor** que deixar o modelo decidir |

> Prefira sempre o **explícito**: diga **quais etapas** seguir, não apenas "pense passo a passo".

### Quando usar

Tarefas com **mais de uma etapa** e que exigem reflexão: detecção de causa raiz, troubleshooting, avaliação/definição de arquitetura, documento estruturado, revisão de código / caça a bug.

### Quando NÃO usar

Tarefas simples — tradução, resumo, classificação, gerar um arquivo. O CoT gera **output muito grande** → mais caro. Em tarefa simples, o resultado ainda piora.

### CoT encadeado

O output de uma análise CoT alimenta o próximo artefato (ex.: a análise de causa raiz vira insumo do post-mortem), sem retrabalho manual.

## Prompts da aula

<details>
<summary>Prompts CoT (churrasco, logs e post-mortem)</summary>

```markdown
# Prompt 1 — Lista de churrasco (SEM CoT, baseline)
Monte uma lista de compras para um churrasco para 15 pessoas, incluindo 2 crianças. Preciso comprar tudo, incluindo descartáveis e bebidas.
```

```markdown
# Prompt 2 — Lista de churrasco (COM CoT estruturado)
Monte uma lista de compras para um churrasco para 15 pessoas, incluindo 2 crianças. Preciso comprar tudo, incluindo descartáveis e bebidas.

Antes de montar a lista, raciocine passo a passo:
1. Calcule a quantidade de carne por pessoa considerando adultos e crianças
2. Separe as carnes por bovinos, suínos e aves
3. Calcule bebidas separando adultos e crianças, alcoólicos e não alcoólicos
4. Liste os itens complementares (descartáveis, carvão, temperos)
5. Monte a lista final com quantidades calculadas
```

```markdown
# Prompt 3 — Análise de logs de incidente (SEM CoT)
Analise os logs abaixo de um incidente em produção e identifique a causa raiz.

[logs do incidente — ver bloco abaixo]
```

```markdown
# Prompt 4 — Análise de logs de incidente (COM CoT estruturado)
Analise os logs abaixo de um incidente em produção e identifique a causa raiz.

Antes de concluir, raciocine passo a passo:
1. Identifique o evento inicial que desencadeou o incidente
2. Correlacione os timestamps para reconstruir a sequência de falha
3. Calcule os recursos envolvidos (conexões, réplicas, limites)
4. Explique por que o sistema falhou com base nos números
5. Apresente a causa raiz e o que a provocou

[logs do incidente — ver bloco abaixo]
```

```markdown
# Prompt 5 — Post-mortem encadeado (CoT em cadeia, usa o output do Prompt 4)
Com base na análise de causa raiz acima, gere um documento de post-mortem estruturado. Raciocine passo a passo para:

1. Definir a severidade e o impacto com base nos dados dos logs
2. Montar a timeline com os marcos críticos
3. Derivar ações corretivas a partir da causa raiz identificada
4. Sugerir ações preventivas para evitar recorrência

Use o formato:
- Título do incidente
- Data, duração, severidade
- Resumo executivo
- Timeline
- Causa raiz
- Ações corretivas (com responsável sugerido e prazo)
- Ações preventivas
```

</details>

<details>
<summary>Logs do incidente (payment-service) — usados nos Prompts 3 e 4</summary>

```log
[2025-11-15 14:30:01] deploy-controller: Starting rollout for deployment payment-service v2.3.1
[2025-11-15 14:30:15] deploy-controller: Rollout completed — 3/3 replicas updated
[2025-11-15 14:31:02] payment-service-pod-7x9k2: INFO - Connecting to PostgreSQL at rds-payment.internal:5432
[2025-11-15 14:31:03] payment-service-pod-7x9k2: INFO - Connection pool initialized: max_connections=20
[2025-11-15 14:31:10] payment-service-pod-a3m8f: INFO - Connection pool initialized: max_connections=20
[2025-11-15 14:31:12] payment-service-pod-q1n5p: INFO - Connection pool initialized: max_connections=20
[2025-11-15 14:32:00] alb-ingress: 200 OK - /api/payments (23ms)
[2025-11-15 14:35:22] payment-service-pod-7x9k2: WARN - Connection pool usage: 18/20 (90%)
[2025-11-15 14:36:45] payment-service-pod-a3m8f: WARN - Connection pool usage: 19/20 (95%)
[2025-11-15 14:37:01] payment-service-pod-q1n5p: ERROR - Cannot acquire connection from pool: timeout after 5000ms
[2025-11-15 14:37:02] alb-ingress: 500 Internal Server Error - /api/payments
[2025-11-15 14:37:15] payment-service-pod-7x9k2: ERROR - Cannot acquire connection from pool: timeout after 5000ms
[2025-11-15 14:37:16] payment-service-pod-a3m8f: ERROR - Cannot acquire connection from pool: timeout after 5000ms
[2025-11-15 14:37:30] cloudwatch-alarm: ALARM - payment-service error rate > 50% (current: 87%)
[2025-11-15 14:38:00] rds-monitoring: INFO - Active connections: 60/100 — CPU: 92%
[2025-11-15 14:40:00] oncall-pagerduty: P1 incident opened — payment-service unavailable
```

</details>

## Pegadinhas

- Evite "raciocine passo a passo" **genérico** — a literatura mostra muito esse formato, mas você perde assertividade. Defina os tópicos.
- CoT gera output grande → **consumo alto de tokens**, mais caro que One/Few-Shot. Use só onde há mais de uma etapa e reflexão.
- Em modelos com reasoning implícito (ex.: Haiku), o CoT explícito ainda ganha, porque você controla a estrutura.

## Dúvidas para revisar

- Para os meus runbooks de incidente, quais são os 4–5 passos de reasoning que sempre quero impor ao modelo?
- Vale montar um prompt CoT encadeado padrão (causa raiz → post-mortem) como template do time?
