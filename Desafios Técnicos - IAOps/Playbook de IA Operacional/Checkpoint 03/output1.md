# Checkpoint 03 — Causa-raiz da degradação no Cerebro

> **Modelo usado:** Claude Sonnet 4.6 (`claude-sonnet-4-6 medium`)

---

## 1. Prompt Parametrizável

```
Você é um engenheiro de plantão sênior especializado em Elasticsearch e observabilidade.

Recebi três artefatos sobre uma degradação em produção. Preciso que você:
1. Correlacione os três artefatos identificando a sequência de eventos
2. Separe causas de sintomas
3. Chegue à causa-raiz (não a lista de sintomas — a causa que, se removida, impede a cascata inteira)
4. Proponha remediação imediata e ações preventivas

---

### ARTEFATO 1 — Configuração do cluster
{{ARTEFATO_CONFIG}}

---

### ARTEFATO 2 — Métricas (janela de {{JANELA_TEMPO}})
{{ARTEFATO_METRICAS}}

---

### ARTEFATO 3 — Logs do nó (mesma janela)
{{ARTEFATO_LOGS}}

---

Formato de resposta:

**Linha do tempo da degradação** — sequência dos eventos correlacionando os três artefatos, com timestamps dos logs e valores das métricas lado a lado.

**Causa-raiz** — uma frase direta. Depois, o raciocínio que a sustenta.

**Por que não terminou no horário esperado** — se houver um job agendado nos artefatos, explique o desvio.

**Cascata** — como a causa-raiz gerou cada sintoma observável, em ordem.

**Remediação imediata** — o que fazer agora para estabilizar o cluster, em ordem de prioridade.

**Prevenção** — mudanças de configuração ou processo para evitar a recorrência.

**Pré-tratamento para modelos externos** — que campos destes artefatos precisam ser removidos ou mascarados antes de enviar para um modelo fora do ambiente (ex.: nomes de índice, IPs, nomes de nós, dados de negócio).
```

**Parâmetros a substituir:**

| Placeholder | O que colocar |
|---|---|
| `{{ARTEFATO_CONFIG}}` | Conteúdo do `cerebro.yaml` ou equivalente |
| `{{ARTEFATO_METRICAS}}` | Tabela de métricas exportada do Sentinel (ou outro sistema de observabilidade) |
| `{{ARTEFATO_LOGS}}` | Trecho de log do pod relevante para a janela do incidente |
| `{{JANELA_TEMPO}}` | Ex.: "últimas 2 horas", "08:00–10:00 UTC de 2026-05-13" |

---

## 2. Execução

### Entrada (artefatos do incidente de 2026-05-13)

Os três artefatos foram passados conforme o template acima — `cerebro.yaml`, métricas 08:00–10:00 UTC e logs do `cerebro-node-3` para a mesma janela.

---

### Output do modelo

#### Linha do tempo da degradação

| Hora (UTC) | Evento nos logs | Métrica correspondente |
|---|---|---|
| 02:00 | Reindex task [88123] iniciada (agendamento diário) | — |
| 08:02 | Reindex em 38% (3,8M/10M docs) — esperado estar em ~100% | heap 61%, p99 850ms |
| 08:14 | GC young de 620ms — heap recupera de 4,9→3,1 GB | heap subindo |
| 08:30 | — | p99 1.100ms, indexed_docs 4.100/s (tráfego matinal chegando) |
| 08:41 | IndexingMemoryController throttla shard [7]: "segment writing can't keep up" | — |
| 09:00 | — | p99 2.300ms, indexed_docs **9.800/s** (+137% vs 08:30), heap 79% |
| 09:03 | Write thread pool: 150/200 | — |
| 09:12 | GC **old** de 1,1s, heap 6,3→5,9 GB — sinal de pressão séria | — |
| 09:20 | Reindex ainda em 40% (praticamente parado em 2h) | — |
| 09:30 | — | p99 4.100ms, indexed_docs 11.200/s, heap **88%**, cache_hit 41% |
| 09:31 | Circuit breaker approaching limit: heap 6,9/8 GB (86%) | — |
| 09:44 | Slow query 2.380ms no shard [7] | — |
| 09:51 | Write thread pool: 188/200 | — |
| 09:58 | **Colapso simultâneo:** fila de escrita cheia (200/200) → `EsRejectedExecutionException`; GC old 1,8s, 4 coletas em 60s; shard [7] timeout 5.031ms > 5.000ms; partial results 11/12 shards; circuit breaker trip 96%; cache hit_ratio→0,29 | p99 **6.700ms**, heap **94%**, cache_hit **29%** |
| 10:01 | `CircuitBreakingException`: heap 7,9/8 GB | — |
| 10:03 | 1.284 bulk requests rejeitados nos últimos 5 min | — |
| 10:05 | 3 de 20 queries com **all shards failed** | — |

---

#### Causa-raiz

> **O job de reindexação agendado para 02:00 não concluiu no tempo esperado (03:30) e ainda estava em execução às 08:00, competindo por heap e threads de escrita com o tráfego de indexação de pico matinal — que chegou 2–3× acima do normal — até esgotar a JVM e travar as buscas.**

**Raciocínio:**

- Às 08:02, o reindex estava em apenas 38% — com 6 horas de execução para o esperado 90 minutos. Isso confirma que o job já estava com throughput muito baixo antes do pico matinal.
- O log de 08:41 mostra throttle do `IndexingMemoryController` ("segment writing can't keep up"), que é a assinatura de segment merging mais lento do que a taxa de ingestão — o `refresh_interval: 1s` força um flush de segmento por segundo durante todo o reindex, multiplicando a pressão de merge.
- Com o reindex ainda ativo às 09:00, o tráfego vivo saltou de 4.100 para 9.800 docs/s (+137%). Os dois fluxos de escrita dividiram o mesmo heap de 8 GB e as mesmas threads do write pool — sem isolamento de recursos entre eles.
- A partir daí a cascata foi linear: heap sobe → GC old generation mais frequente e mais longo → cache de query evicta para liberar memória → cache_hit_pct cai → queries reprocessam mais → heap sobe mais → circuit breaker dispara → buscas retornam parciais ou falham.

---

#### Por que o reindex não terminou no horário esperado

O desvio tem duas causas sobrepostas:

1. **`refresh_interval: 1s` durante a reindexação** — a configuração padrão força o Elasticsearch a criar um novo segmento de Lucene a cada segundo. Durante reindexação em massa isso multiplica o trabalho de merge de segmentos, reduzindo drasticamente o throughput de ingestão. O recomendado é desabilitar o refresh (`-1`) durante o job e reativá-lo ao final.

2. **Ausência de throttle no próprio job** — a API de reindexação tem parâmetro `requests_per_second` para limitar a taxa. Sem ele, o job compete livremente pelos recursos do nó, e quando o tráfego vivo aumenta, o SO e o GC passam a throttlar o reindex de forma não-determinística (como visto no log de 08:41), tornando o tempo de conclusão imprevisível.

---

#### Cascata (causa → sintomas)

```
Reindex não termina no prazo
        │
        ▼
Reindex ativo durante pico matinal (09:00+)
        │
        ├──► Dois fluxos de escrita competem pelo heap de 8 GB
        │           │
        │           ├──► GC old generation com pausas longas (1,1s → 1,8s)
        │           │
        │           └──► Write thread pool satura (150 → 200/200)
        │                       │
        │                       └──► EsRejectedExecutionException (bulk rejections)
        │
        ├──► Pressão de heap força eviction do query cache
        │           │
        │           └──► cache_hit_pct: 74% → 29%
        │                       │
        │                       └──► Queries reprocessam → heap sobe mais
        │
        └──► Circuit breaker dispara a 96% do heap
                    │
                    ├──► Partial results (11/12 shards)
                    ├──► CircuitBreakingException (buscas recusadas)
                    └──► all shards failed (3/20 queries)
```

---

#### Remediação imediata (ordem de prioridade)

1. **Cancelar o reindex em execução:**
   ```bash
   POST /_tasks/88123/_cancel
   ```
   Isso libera imediatamente as threads de escrita e alivia a pressão de heap.

2. **Forçar GC e aguardar estabilização do heap:**
   ```bash
   POST /_nodes/cerebro-node-3/jvm/gc
   ```
   Monitorar `heap_used_pct` cair abaixo de 70% antes de prosseguir.

3. **Reiniciar o reindex com throttle e refresh desabilitado:**
   ```bash
   # Desabilitar refresh antes de iniciar
   PUT /logs-2026.05/_settings
   { "index.refresh_interval": "-1" }

   # Iniciar reindex com rate limiting
   POST /_reindex?requests_per_second=500
   { "source": { "index": "logs-2026.05-old" }, "dest": { "index": "logs-2026.05" } }
   ```
   Ajustar `requests_per_second` conforme heap e p99 das buscas.

4. **Reabilitar refresh ao concluir:**
   ```bash
   PUT /logs-2026.05/_settings
   { "index.refresh_interval": "1s" }
   ```

---

#### Prevenção

| Área | Ação | Impacto esperado |
|---|---|---|
| **Config do reindex** | Adicionar `requests_per_second: 500` no `cerebro.yaml` para limitar o throughput do job | Reindex não compete descontroladamente com tráfego vivo |
| **Refresh durante reindex** | No script/operador de reindex, setar `refresh_interval: -1` antes e restaurar ao final | Reduz segment merging durante o job; melhora throughput de reindex em 2–4× |
| **Alerta de progresso** | Alertar se o job ainda estiver abaixo de 80% às 05:00 (1,5h após o término esperado) | Time acorda para o problema antes do pico matinal |
| **Horário do job** | Avaliar mover o schedule para 03:00 ou reduzir frequência (a cada 2 dias se os dados permitirem) | Mais margem antes do pico |
| **Heap** | Avaliar upgrade de heap para 12–16 GB ou migração para cluster multi-nó com shards distribuídos | Remove o gargalo de memória compartilhada entre reindex e buscas |
| **Circuit breaker** | Configurar alerta no Sentinel ao atingir 80% de heap_used_pct | Tempo de reação antes do colapso |

---

#### Pré-tratamento para modelos externos

Antes de enviar estes artefatos para qualquer modelo fora do ambiente (ex.: API pública, ChatGPT, Gemini), remover ou mascarar:

| Campo | Motivo |
|---|---|
| Nomes de índice (`logs-2026.05`) | Podem revelar convenções de nomenclatura, produto ou data de retenção de dados |
| Nomes de nós (`cerebro-node-3`) | Revelam topologia interna e naming de infraestrutura |
| IDs de task (`88123`) | Associados a operações internas; irrelevantes para diagnóstico externo e mapeáveis a horários |
| Nome do sistema (`Cerebro`, `Aegis`, `Sentinel`) | Nomes de produto e time internos |
| Timestamps exatos com data | Substituir por offsets relativos (T+0min, T+30min…) para não expor janelas de manutenção |

> Os valores de métrica e os níveis de log **podem ser mantidos** — são genéricos o suficiente para não identificar o ambiente.

---

## 3. Curadoria

### O que funcionou bem no prompt

- Pedir explicitamente "causa que, se removida, impede a cascata inteira" evitou que o modelo listasse sintomas como causa (ex.: "GC lento" é sintoma, não causa)
- A instrução de correlacionar timestamps dos logs com valores de métricas lado a lado forçou o raciocínio sequencial — o modelo não saltou para conclusão
- Incluir a seção de pré-tratamento diretamente no prompt torna o template reutilizável sem precisar lembrar de adicionar essa etapa depois

### O que ajustar em próximas iterações

- **Adicionar contexto de baseline:** o prompt não pede "valores normais esperados para cada métrica" — com isso, o modelo poderia calcular o desvio em vez de qualificar subjetivamente (ex.: p99 de 850ms "já é alto" vem do enunciado, não de uma baseline explícita no artefato)
- **Incluir o número de nós no cluster:** com apenas `shards: 12` e `replicas_per_shard: 1` não fica claro se todos os shards estão no mesmo nó ou distribuídos — isso muda o diagnóstico de heap sharing
- **Pedir severidade da remediação:** o prompt pede "ordem de prioridade" mas não pede uma estimativa de risco de cada ação (ex.: cancelar o reindex é seguro; forçar GC em produção tem caveats)

### Decisão de pré-tratamento

Os artefatos desta análise **não foram enviados para nenhum modelo externo** — a execução rodou localmente via Claude Code (Claude Sonnet 4.6, rodando no ambiente da Anthropic com dados trafegando pela API Anthropic). Em um cenário real com dados de produção, aplicar as substituições descritas na seção de pré-tratamento antes de qualquer envio externo.
