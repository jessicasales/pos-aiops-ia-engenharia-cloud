# Prompt Chaining

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas avançadas de Prompt Engineering |
| **Aula** | 02 — Prompt Chaining - Diagramas (21:01) |
| **Assunto** | Executar prompts em cadeia, cada um com uma responsabilidade, com gates entre etapas |
| **Data** | 03/11/2026 23:58 |
| **Tags** | prompt-chaining, cadeia-de-prompts, gate, input-output, pipeline-incidente, linear-condicional-loop |

## Resumo da aula

Em vez de resolver uma tarefa grande num único prompt, o **Prompt Chaining** executa **prompts em cadeia**: cada prompt faz uma tarefa e seu **output** alimenta o **input** do próximo. Pode ser feito na mesma conversa (o modelo já tem o contexto), sem copiar e colar.

Cada prompt da cadeia tem três elementos: **input** (do usuário ou do prompt anterior), **instrução** (a tarefa) e **output** (consumido pelo próximo). O ponto-chave: **uma responsabilidade por prompt**.

## Conceitos principais

### Três formas de execução

| Forma | Como funciona |
|---|---|
| **Linear** | Ordem fixa, um após o outro (output anterior → input seguinte) |
| **Condicional** | Prompt A decide se roda B ou C |
| **Loop** | Repete até uma condição ser atendida |

A maioria começa linear; branches e loops aparecem em ferramentas de workflow (n8n) ou código (LangChain, LangGraph).

### Três princípios de projeto

1. **Uma responsabilidade por prompt** — cada etapa faz uma coisa só (como uma função no código).
2. **Output verificável** — dá para avaliar se está certo antes de seguir.
3. **Formato definido** — especifique o formato de saída para o próximo prompt consumir.

### Gate (checkpoint entre etapas)

Antes de alimentar o próximo prompt, avalie se o output anterior está bom. Pode ser **manual** (você lê e decide) ou **automático** (outro prompt avalia). Os gates evitam o **efeito cascata de erro** — mesmo conceito do *quality gate* em pipelines CI/CD.

### Quando usar

Se a tarefa tem **mais de uma etapa cognitiva**, monte uma cadeia. "Resuma este texto" = 1 etapa (prompt único). "Analise o log, identifique a causa raiz e proponha a correção" = 3 etapas → 1 prompt por etapa.

> O prompt é o novo código: cadeias de prompt precisam ser versionadas e organizadas (tema de capítulos seguintes).

## Prompts da aula

<details>
<summary>Cadeia 1 — Post de LinkedIn (2 etapas)</summary>

```markdown
# Passo 1 — Rascunho de conteúdo (foco só na mensagem)
Sou um profissional de DevOps e quero escrever um post para LinkedIn
sobre uma lição importante que aprendi: automatizar sem entender o
processo manual primeiro leva a automações frágeis que quebram em
cenários não previstos.

Escreva um rascunho do post focando apenas no conteúdo e na mensagem.
Não se preocupe com hook, tom ou call-to-action por enquanto.
Inclua um exemplo concreto que ilustre a lição.
```

```markdown
# Passo 2 — Refinamento para engajamento (mesma janela de contexto)
Pegue o rascunho abaixo e reescreva como um post de LinkedIn otimizado
para engajamento:

- Comece com um hook de 1-2 linhas que gere curiosidade
- Use tom conversacional e direto (como se estivesse falando com um colega)
- Quebre em parágrafos curtos (máximo 3 linhas cada)
- Termine com uma pergunta que convide comentários

Rascunho:
[colar o output do Prompt 1]
```

</details>

<details>
<summary>Cadeia 2 — Pipeline de incidente (4 etapas: triagem → diagnóstico → remediação → post-mortem)</summary>

```markdown
# Passo 1 — Triagem (organiza os fatos, sem diagnosticar)
Você é um SRE fazendo triagem de um incidente em produção.
Abaixo estão os dados brutos coletados do ambiente.

Sua tarefa: organizar esses dados num relatório de triagem
estruturado. Identifique padrões, correlações temporais e anomalias.
NÃO tente diagnosticar ainda. Apenas organize os fatos.

LOGS DA APLICAÇÃO (últimas 2h, filtrado por ERROR):
14:02:31 ERROR [req-a8f1] DBPool: Connection attempt failed - ECONNREFUSED 10.0.3.42:5432
14:02:31 ERROR [req-a8f1] Handler /api/orders: 500 Internal Server Error
14:03:47 ERROR [req-d4e7] DBPool: Connection attempt failed - ECONNREFUSED 10.0.3.42:5432
14:04:55 ERROR [req-c7d2] DBPool: Pool exhausted, waiting for available connection... timeout after 5000ms
14:04:55 ERROR [req-c7d2] Handler /api/products: 500 Internal Server Error
14:06:03 ERROR [req-h3j8] DBPool: Connection attempt failed - ECONNREFUSED 10.0.3.42:5432
14:08:22 ERROR [req-k5m1] DBPool: Pool exhausted, waiting for available connection... timeout after 5000ms

MÉTRICAS DO RDS (CloudWatch, últimas 2h):
- DatabaseConnections: 98-100 (limite: max_connections=100)
- CPUUtilization: 92-96%
- ReadLatency: 45ms (normal: 5-8ms)

STATUS DOS PODS (kubectl): api-server x3 réplicas, todos Running, 0 restarts, 18h

TRECHO DO ÚLTIMO DEPLOY (diff do values.yaml, ontem 18h):
  db:
    pool:
-     size: 10
+     size: 50

AMBIENTE: Node.js, EKS com 3 réplicas; PostgreSQL RDS (db.r5.large, max_connections=100).
Início dos erros: 14h hoje. Erros afetam ~30% das requisições.

Gere o relatório de triagem no formato: 1. Resumo, 2. Padrões (com evidências),
3. Anomalias nas métricas, 4. Mudanças recentes, 5. Correlações.
```

```markdown
# Passo 2 — Diagnóstico da causa raiz
Com base no relatório de triagem abaixo, diagnostique a causa raiz deste incidente.

[colar output do Prompt 1]

Apresente: 1. Causa raiz (cadeia causal completa), 2. Evidências que sustentam,
3. Hipóteses alternativas e por que foram descartadas.
```

```markdown
# Passo 3 — Plano de remediação (2 fases)
Com base no diagnóstico abaixo, proponha um plano de remediação.

[colar output do Prompt 2]

Contexto: Node.js em EKS (3 réplicas); PostgreSQL RDS db.r5.large (max_connections=100);
pool size atual 50/réplica, anterior 10/réplica.

Plano em duas fases: 1. Mitigação imediata, 2. Correção definitiva.
Para cada ação: o que fazer, comando/configuração, risco e como validar.
```

```markdown
# Passo 4 — Post-mortem (consolida tudo)
Com base nas informações abaixo, gere a documentação post-mortem deste incidente.

Relatório de triagem: [output do Prompt 1]
Diagnóstico: [output do Prompt 2]
Remediação aplicada: [output do Prompt 3]

Formato: Resumo, Timeline (deploy → resolução), Causa raiz, Impacto,
Ações tomadas, Action items para prevenir recorrência.
```

</details>

## Pegadinhas

- Peça cada etapa na **janela de contexto do chat** (ou salve em variável, se estiver em n8n/LangChain) — o próximo prompt precisa ler o output anterior.
- Sem gate entre etapas, um erro no passo N contamina todos os seguintes.

## Dúvidas para revisar

- Qual pipeline de incidente do meu time eu transformaria numa cadeia de 4 prompts?
- Onde colocar gates automáticos (prompt avaliador) versus gates manuais?
