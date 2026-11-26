# Checkpoint 01 — Resultado do prompt.md por entrada

## Entrada 1 - Pod reiniciando
Modelo utilizado: Claude Sonnet 5.5 (`claude-sonnet-5-5`)

```markdown
Status geral: ATENÇÃO
Pods problemáticos: 1

Namespace: sentinel-prod

| Pod                          | STATUS           | READY | RESTARTS     | Idade |
|------------------------------|------------------|-------|--------------|-------|
| sentinel-api-7d9c8b6f4-h4m2t | CrashLoopBackOff | 0/1   | 14 (90s ago) | 42m   |

Estado atual do container: Waiting (CrashLoopBackOff)

### sentinel-api-7d9c8b6f4-h4m2t

Diagnóstico:
 O container `api` está sendo encerrado por exceder o limite de memória (512Mi) e o kubelet o reinicia em loop (CrashLoopBackOff é o sintoma, não a causa). O log anterior indica que o consumo cresce durante o carregamento do cache de alertas de 6h até esgotar o heap.

Evidências:
- STATUS: CrashLoopBackOff, 14 restarts em 42m, READY 0/1.
- Evento: `Warning BackOff` (x18 em 40m) — "Back-off restarting failed container api".
- Último estado: `Terminated`, Reason `OOMKilled`, Exit Code `137` (forte evidência de encerramento por limite de memória).
- Limits: memory 512Mi; Requests: memory 256Mi.
- Log `--previous`: heap 410Mi/512Mi ao carregar o "6h alert cache" → "high GC pressure, heap 498Mi/512Mi" → `[FATAL] out of memory, shutting down process`.
- Os outros pods (api-2xk9p, worker, scheduler) estão Running e Ready há 6d, então o impacto parece restrito a esta réplica.

Causa provável (hipótese, não confirmada): o limite de 512Mi é insuficiente para o uso de memória do cache de 6h nesta réplica. O snapshot não mostra por que a réplica de 6d (2xk9p) não sofre o mesmo problema (versão, volume de dados ou carga); isso está indeterminado com os dados disponíveis.

Evidência faltante: consumo de memória (`kubectl top pod`) da réplica saudável e desta, versão/imagem da réplica 2xk9p e configuração do tamanho do cache.

Próxima ação do plantão:
 1. Mitigação: manter a réplica 2xk9p atendendo (confirmar que está absorvendo a carga); se necessário, aumentar temporariamente o memory limit do deployment (ação reversível), com acompanhamento do rollout.
 2. Confirmação: comparar `kubectl top pod` entre as duas réplicas e comparar versão/imagem e config de cache entre elas.
 3. Correção definitiva: dimensionar corretamente requests/limits de memória para o cache de 6h, ou reduzir a janela/tamanho do cache, conforme o que a confirmação mostrar.

Prioridade: P2 — alta
```

---

## Entrada 2 - Pods que não sobem
Modelo utilizado: Claude Sonnet 5.5 (`claude-sonnet-5-5`)

```markdown
Status geral: CRÍTICO
Pods problemáticos: 2

Namespace: sentinel-prod

| Pod                            | STATUS           | READY | RESTARTS | Idade |
|--------------------------------|------------------|-------|----------|-------|
| sentinel-ingest-8f7a9c5b-4dkqm | Pending          | 0/1   | 0        | 8m    |
| sentinel-api-7d9c8b6f4-zzp10   | ImagePullBackOff | 0/1   | 0        | 8m    |

Estado atual dos containers: ingest-4dkqm = Waiting (Pending); api-zzp10 = Waiting (ImagePullBackOff)

### sentinel-ingest-8f7a9c5b-4dkqm

Diagnóstico:
 O pod não foi agendado em nenhum node: o scheduler informa que nenhum dos 6 nodes tem CPU suficiente para atender ao request de 2 CPUs do pod. O container nem chegou a ser criado.

Evidências:
- STATUS: Pending, 0/1, 0 restarts, 8m.
- Evento: `Warning FailedScheduling` (default-scheduler) — "0/6 nodes are available: 6 Insufficient cpu".
- Requests: cpu 2.
- No snapshot, não há nenhum pod `sentinel-ingest` Running, portanto o componente de ingestão parece sem réplica ativa (a confirmar no Deployment).

Causa provável: insuficiência de CPU alocável nos 6 nodes para o request de 2 CPUs. Não há evidência de problema de memória, falha de node ou autoscaling. A capacidade real dos nodes não consta no snapshot.

Evidência faltante: CPU alocável vs. já requisitada por node (`kubectl describe nodes`) e se existe autoscaler no cluster.

Próxima ação do plantão:
 1. Mitigação: liberar ou adicionar capacidade de CPU para que um node comporte 2 CPUs (por exemplo, adicionar node ou reduzir workloads não críticos, se permitido).
 2. Confirmação: `kubectl describe nodes` (Allocatable x Allocated requests) para validar o gargalo e conferir se o request de 2 CPUs é o esperado.
 3. Correção definitiva: revisar o dimensionamento do cluster e/ou o request de CPU do ingest, apenas se a análise mostrar superdimensionamento.

Prioridade: P1 — imediata

### sentinel-api-7d9c8b6f4-zzp10

Diagnóstico:
 A imagem `registry.aegis.io/sentinel-api:2.9.2` não pode ser obtida porque o registry retornou `manifest unknown`, indicando que essa tag/imagem não está disponível no registry. O container nunca iniciou.

Evidências:
- STATUS: ImagePullBackOff, 0/1, 0 restarts, 8m.
- Evento: `Warning Failed` — Failed to pull image "registry.aegis.io/sentinel-api:2.9.2": manifest unknown.
- Evento: `Warning Failed` — Error: ErrImagePull; `Normal BackOff` — Back-off pulling image.
- Image: `registry.aegis.io/sentinel-api:2.9.2`.
- A réplica `sentinel-api-7d9c8b6f4-2xk9p` segue Running e Ready, então o serviço da API não está totalmente indisponível.

Causa provável: a tag `2.9.2` não existe (ou ainda não foi publicada) no registry. Não há evidência de problema de credenciais, rede ou DNS.

Evidência faltante: confirmação da lista de tags do registry e da origem do pipeline que referenciou a 2.9.2. O snapshot também não informa qual imagem a réplica saudável executa.

Próxima ação do plantão:
 1. Mitigação: não escalar nem avançar o rollout com essa tag; manter a réplica saudável servindo (se foi um rollout, avaliar rollback para a última tag funcional, ação reversível).
 2. Confirmação: verificar no registry se `sentinel-api:2.9.2` existe e se o pipeline de build/publicação concluiu.
 3. Correção definitiva: publicar a imagem 2.9.2 ou corrigir a referência do Deployment para uma tag existente.

Prioridade: P2 — alta
```

---

## Entrada 3 - Tudo saudável
Modelo utilizado: Claude Sonnet 5.5 (`claude-sonnet-5-5`)

```markdown
Status geral: SAUDÁVEL
Pods problemáticos: 0

Conclusão:
 Nenhum pod problemático identificado no snapshot fornecido. Os 4 pods estão Running e 1/1 Ready, e os logs da API mostram health check OK, 0 erros nos últimos 5 min, 4.2k alertas/min processados e p99 de 120ms.

Observações:
 - `sentinel-worker-5b8f9c8d-jq7rs` teve 1 restart há 3 dias, isolado e antigo, sem recorrência, e o pod está estável desde então. Não é suficiente para classificá-lo como problemático. O snapshot não traz o motivo desse restart; se houver interesse, consultar o `Last State` ou os logs históricos.
 - Nenhuma ação imediata necessária.
```
