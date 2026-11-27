# Checkpoint 03 — Causa-raiz da degradação no Cerebro

## O Incidente

Agora um caso mais detalhado. 

O Cerebro — o sistema de indexação e busca da Aegis — começou a devolver **buscas lentas** e, em alguns casos, **resultados incompletos**. 

O Sam Wilson, do plantão, levantou três artefatos antes de escalar para você. Cada um vem de uma fonte diferente, e vale saber de onde, porque é **cruzando os três que se chega à causa**.

> 💡 Você não precisa conhecer o Cerebro por dentro — os artefatos abaixo trazem tudo que importa.

## Os Artefatos

### Artefato 1 — Configuração do Cluster Elasticsearch

O Cerebro é um serviço Java que usa o Elasticsearch como motor de indexação e busca (Elasticsearch também roda na JVM — por isso o heap aparece em GB). 

Este é o arquivo `cerebro.yaml`, versionado no repositório de infra, que define os parâmetros do cluster: shards, réplicas, heap da JVM, job de reindexação e cache de query.

> Não é configuração de aplicação de negócio nem de banco relacional: são os **ajustes do próprio Elasticsearch**.

# cerebro.yaml — configuração do cluster Elasticsearch (repositório de infra)
```yaml
cerebro:
  shards: 12
  replicas_per_shard: 1
  jvm_heap: 8g
  refresh_interval: 1s
  reindex_job:
    schedule: "0 2 * * *"     # roda todo dia às 02:00
    avg_duration_min: 90      # normalmente termina ~03:30
  query_cache:
    enabled: true
    size_mb: 512
```

### Artefato 2 — Métricas das Últimas Duas Horas

Saíram do dashboard do Sentinel (o produto de observabilidade da própria Aegis). Cada linha é um ponto de 30 em 30 minutos:
```bash
timestamp              search_p99_ms   indexed_docs_per_s   heap_used_pct   cache_hit_pct
2026-05-13 08:00 UTC   850             4200                 61              74
2026-05-13 08:30 UTC   1100            4100                 68              71
2026-05-13 09:00 UTC   2300            9800                 79              58
2026-05-13 09:30 UTC   4100            11200                88              41
2026-05-13 10:00 UTC   6700            12400                94              29
```

#### Legenda das Colunas

- **search_p99_ms** — latência da busca no percentil 99 (ms). 99% das buscas terminam abaixo desse valor (↓ menor, ↑ melhor; 850ms já é alto, 6700ms é crítico)
- **indexed_docs_per_s** — documentos indexados por segundo (vazão de escrita no índice)
- **heap_used_pct** — percentual do heap da JVM em uso. O teto é o `jvm_heap: 8g` do Artefato 1
- **cache_hit_pct** — percentual de buscas atendidas pelo query_cache sem reprocessar (↑ maior, ↓ menos esforço por query)

### Artefato 3 — Logs do Nó do Cerebro

Um trecho dos logs coletado com `kubectl logs` no pod, cobrindo a janela do problema (~08h às ~10h, as mesmas 2h das métricas). É o log nativo do Elasticsearch (horário em UTC):
```bash
[2026-05-13T08:02:11,540][INFO ][o.e.t.LoggingTaskListener              ][cerebro-node-3] reindex task [88123] (scheduled 02:00) progress, created [3.8M]/[10M] docs (38%)
[2026-05-13T08:14:33,019][WARN ][o.e.m.j.JvmGcMonitorService            ][cerebro-node-3] [gc][young] duration [620ms], collections [1] in [10s], heap [4.9gb]->[3.1gb]/[8gb]
[2026-05-13T08:41:07,222][INFO ][o.e.i.IndexingMemoryController         ][cerebro-node-3] now throttling indexing for shard [logs-2026.05][7]: segment writing can't keep up
[2026-05-13T09:03:55,810][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool queue at [150/200]
[2026-05-13T09:12:48,402][WARN ][o.e.m.j.JvmGcMonitorService            ][cerebro-node-3] [gc][old] duration [1.1s], collections [2] in [60s], heap [6.3gb]->[5.9gb]/[8gb]
[2026-05-13T09:20:02,118][INFO ][o.e.t.LoggingTaskListener              ][cerebro-node-3] reindex task [88123] (scheduled 02:00) progress, created [4.0M]/[10M] docs (40%)
[2026-05-13T09:31:17,653][WARN ][o.e.i.b.HierarchyCircuitBreakerService ][cerebro-node-3] [parent] usage [6.9gb/8gb] (86%), approaching limit
[2026-05-13T09:44:29,901][WARN ][o.e.s.SearchService                    ][cerebro-node-3] slow query on shard [logs-2026.05][7] took [2380ms]
[2026-05-13T09:51:08,377][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool queue at [188/200]
[2026-05-13T09:58:41,102][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool queue full [200/200], rejecting bulk — EsRejectedExecutionException
[2026-05-13T09:58:43,210][WARN ][o.e.m.j.JvmGcMonitorService            ][cerebro-node-3] [gc][old] duration [1.8s], collections [4] in [60s], heap [7.6gb]->[7.4gb]/[8gb]
[2026-05-13T09:58:44,005][INFO ][o.e.t.LoggingTaskListener              ][cerebro-node-3] reindex task [88123] (scheduled 02:00) still running, created [4.1M]/[10M] docs (41%), ETA unknown
[2026-05-13T09:58:45,889][WARN ][o.e.i.IndexingMemoryController         ][cerebro-node-3] indexing buffer above limit, throttling shard [logs-2026.05][7]
[2026-05-13T09:58:46,330][DEBUG][o.e.s.query.QueryPhase                 ][cerebro-node-3] shard [logs-2026.05][7] search took [5031ms] (timeout [5000ms])
[2026-05-13T09:58:46,512][ERROR][o.e.s.SearchService                    ][cerebro-node-3] search returned partial results: 11/12 shards succeeded
[2026-05-13T09:58:46,701][WARN ][o.e.i.b.HierarchyCircuitBreakerService ][cerebro-node-3] [parent] circuit breaker tripped, usage [7.7gb/8gb] (96%) over limit
[2026-05-13T09:58:47,001][WARN ][o.e.i.cache.query.IndicesQueryCache    ][cerebro-node-3] query cache eviction rate spiking, hit_ratio dropped to 0.29
[2026-05-13T10:01:12,778][ERROR][o.e.s.SearchService                    ][cerebro-node-3] CircuitBreakingException: [parent] Data too large, would be [7.9gb/8gb]
[2026-05-13T10:03:39,255][WARN ][o.e.t.ThreadPool                       ][cerebro-node-3] write thread pool rejected [1284] bulk requests in last 5min
[2026-05-13T10:05:50,640][ERROR][o.e.s.SearchService                    ][cerebro-node-3] all shards failed for index [logs-2026.05] on 3 of last 20 queries
```

#### Como Ler

É o log nativo do Elasticsearch. O trecho cobre as mesmas ~2h das métricas (08h→10h), então dá para acompanhar a degradação se construindo. 

Cada linha traz:
- **Horário** — UTC, ISO com milissegundos
- **Nível** — INFO/WARN/ERROR/DEBUG
- **Classe Java** — `o.e.…` é abreviação de `org.elasticsearch.…`
- **Nó** — `cerebro-node-3`

#### O Que Importa

| Componente | Significado |
|---|---|
| **ThreadPool** | A fila de escrita encheu e os bulks de indexação estão sendo rejeitados (EsRejectedExecutionException) |
| **JvmGcMonitorService** | Garbage collector com pausas longas e o heap colado no teto de 8gb |
| **LoggingTaskListener** | O job de reindex agendado (02:00) ainda em 41% (4.1M de 10M docs) |
| **IndexingMemoryController** | O buffer de indexação acima do limite, forçando throttle no shard 7 |
| **QueryPhase / SearchService** | Buscas estourando o timeout de 5s e retornando resultado parcial (11 de 12 shards) |
| **HierarchyCircuitBreakerService** | O circuit breaker de memória disparou a 96% do heap, recusando novas operações |
| **IndicesQueryCache** | O cache de query com eviction alta e o hit ratio caído para 0.29 (= os 29% da métrica) |

---

## O Desafio

A reindexação que **deveria ter terminado às 03:30** ainda estava em **41% às 10:00**.

O prompt que você vai construir:
- Recebe esse pacote de artefatos (config, métricas e log) como **parâmetro**
- Precisa levar a IA a **raciocinar até a causa-raiz**, não só listar sintomas
- É o tipo de prompt que o time vai **reusar** toda vez que uma degradação dessas aparecer, trocando só o pacote de entrada

> ⚠️ Os dados são fictícios, mas trata-os como produção: **decide o que precisaria ser tratado antes de mandar isso para um modelo externo**.

---

## Tarefa

**Escrever o prompt parametrizável de análise de causa-raiz** (que recebe os artefatos como entrada; use meta-prompting para criá-lo) e **executá-lo sobre os artefatos acima**.

## Entregáveis

- Prompt parametrizável
- Execução (modelo e output)
- Curadoria