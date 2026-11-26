# Checkpoint 02 — Padronizando as notas de triagem

## O Problema

Toda vez que o Sentinel dispara um alerta, o plantonista abre uma nota de triagem. 

O problema: cada um escreve do seu jeito, e isso atrapalha quem assume o turno seguinte. A Carol Danvers quer um **padrão único de nota**.

> ⚠️ **Atenção:** Este checkpoint tem duas listas diferentes de exemplos — o **formato de saída** (nota pronta) e as **entradas** (alertas crus). Não misture os dois.

## Formato de Saída Esperado

É assim que a nota pronta deve ficar. O time consolidou três exemplos do padrão que considera bom. **Isto é referência de formato, não é entrada do prompt:**

```
ALERTA: Relay - taxa de rejeição de ingestão acima de 2% por 5min
IMPACTO: ingestão de telemetry degradada para ~12% dos tenants
HIPÓTESE INICIAL: deploy do Relay às 09:14 reduziu o buffer de ingestão
AÇÃO IMEDIATA: rollback iniciado via Argo CD
ESCALAR PARA: @relay-core se a rejeição não cair em 10min
```

```
ALERTA: Forge - lag de ingestão acima de 15min
IMPACTO: dashboards do Sentinel atrasados para todos os tenants
HIPÓTESE INICIAL: pico de volume do tenant acme-corp saturou o consumer
AÇÃO IMEDIATA: aumento manual de partições do consumer do Relay
ESCALAR PARA: @data-platform se lag não estabilizar em 20min
```

```
ALERTA: Cerebro - latência de busca p99 acima de 4s
IMPACTO: investigação de incidentes lenta para o time interno
HIPÓTESE INICIAL: reindexação noturna não concluiu antes do horário comercial
AÇÃO IMEDIATA: pausar reindexação e priorizar shard quente
ESCALAR PARA: @search-infra se p99 não cair em 15min
```

## Entradas para o Prompt

Agora sim, os alertas crus que o prompt recebe por parâmetro e transforma em nota. **São estes três (e só estes) que você vai rodar para testar:**

### Entrada 1

```
2026-05-12 14:02:09 UTC [Sentinel] autoscaler hit max replicas (60/60) on sentinel-api,
queue depth on Relay growing 2k/min, CPU avg 88%, tenant stark-industries
sending 4x baseline volume after onboarding new region
```

### Entrada 2

```
2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems,
buffer saturated after deploy 02:55
```

### Entrada 3

```
2026-05-13 11:40:22 UTC [Forge] consumer lag 9min and climbing, batch forge-batch-ingest
delayed after previous job failure, downstream Sentinel starting to lag
```

## O Desafio

Você vai construir um **prompt parametrizável** que produza a nota padronizada a partir de qualquer alerta cru.

A decisão de método aqui é sua: dá para ensinar esse padrão ao modelo de mais de uma forma, e é essa escolha que você vai justificar.

---

## Tarefa

**Escrever o prompt parametrizável de geração de notas de triagem** (use meta-prompting para criá-lo) e **executá-lo contra os três alertas crus acima**.

## Entregáveis

- Prompt parametrizável
- Execução (modelo e output) nos exemplos
- Curadoria