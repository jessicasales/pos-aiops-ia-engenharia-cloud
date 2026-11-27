# Checkpoint 04 — Mesa-redonda sobre contenção sob pico no Relay

---

**Nome:** Jéssica Sales
**Assunto:** Execução do prompt parametrizável de mesa-redonda para avaliar estratégias de contenção no Relay (barramento de eventos) sob pico de 320k msgs/s
**Data:** 2026-11-26
**Modelo e esforço:** Opus 4.7 Extra High (single-turn, debate simulado em uma única resposta)
**Palavras-chave:** Relay, barramento de eventos, pico, backpressure, DLQ, autoscaling, sharding por tenant, priorização, SLA, trade-off, multi-persona, debate

---

## 1. Parâmetros preenchidos

| Placeholder | Valor usado |
|---|---|
| `{{PERFIL_ANALISTA_1}}` | SRE focado em confiabilidade e SLA — prioriza margem de segurança sobre custo |
| `{{PERFIL_ANALISTA_2}}` | Arquiteto de plataforma focado em custo e eficiência — questiona overengineering e exige justificativa de ROI |
| `{{PERFIL_ANALISTA_3}}` | Engenheiro de dados focado em integridade e reprocessamento — obcecado por não perder evento |
| `{{NOME_DO_SISTEMA}}` | Relay |
| `{{PAPEL_NA_ARQUITETURA}}` | Barramento de eventos assíncrono entre produtores de telemetry e consumidores a jusante |
| `{{DESCRICAO_DO_PROBLEMA}}` | Sob picos, o Relay aproxima-se da saturação. O alerting em tempo real (Sentinel) começa a atrasar e viola o SLA de 60s, e há risco de o barramento repetir o comportamento do predecessor, que perdia mensagens sob pico — inaceitável para um produto de observabilidade. |
| `{{THROUGHPUT_SUSTENTADO}}` | 180k msgs/s |
| `{{PICO_OBSERVADO}}` | 320k msgs/s |
| `{{DURACAO_DO_PICO}}` | 25 min |
| `{{RETENCAO_ATUAL}}` | 4h |
| `{{CONSUMIDORES}}` | Forge (ingestão em lote, SLA tolera atraso de até 15min); Sentinel (alerting em tempo real, SLA ≤ 60s) |
| `{{RESTRICOES}}` | • Sentinel: atraso máximo 60s (SLA contratual)<br>• Forge: pode atrasar até 15min sem violar SLA<br>• Orçamento de infra do trimestre já está 8% acima do previsto<br>• Histórico: barramento antigo perdia mensagens sob pico — perda de telemetry é inaceitável (produto de observabilidade) |
| `{{ESTRATEGIAS}}` | 1. Priorização do Sentinel sobre o Forge no consumo do Relay<br>2. Dead-letter queue (DLQ) para o que não for processado no pico<br>3. Sharding do Relay por cliente/tenant<br>4. Autoscaling horizontal de consumidores |
| `{{HORIZONTE_CURTO_PRAZO}}` | Próximas 2 sprints (~30 dias) |

---

## 2. Output do modelo

### 1. Rodada de análises individuais

---

#### Analista 1 — SRE (confiabilidade e SLA)

**Diagnóstico.** O verdadeiro problema não é o pico em si — é que o Relay trata os dois consumidores como iguais, quando eles têm SLAs em ordens de grandeza diferentes (60s vs 15min). Enquanto o alerting compartilhar fila e orçamento de recursos com a ingestão em lote, qualquer pico empurra os dois juntos para a zona de risco, e quem viola SLA contratual primeiro é o Sentinel. O pico de 320k msgs/s por 25min cabe confortavelmente dentro da retenção de 4h, então o problema não é capacidade bruta de armazenamento — é *fairness* de consumo sob contenção.

**Posição sobre cada estratégia:**

| Estratégia | Posição | Justificativa |
|---|---|---|
| 1. Priorização Sentinel > Forge | **A favor (prioritária)** | Elimina o risco de SLA sem custo adicional: Forge já tolera 15min de atraso, é a folga exata que o pico de 25min precisa. |
| 2. DLQ | **Condicional** | Faz sentido como rede de segurança, mas não resolve o problema primário. Se precisamos de DLQ é porque o sistema está *perdendo* capacidade, não priorizando — pode mascarar o verdadeiro gargalo. |
| 3. Sharding por tenant | **Contra agora** | Isolamento entre tenants é valioso, mas é projeto estrutural (semanas de migração), custo não-trivial e não resolve o SLA do Sentinel — que é cross-tenant. Em pico de "cliente barulhento" ajuda, mas o incidente reportado não é esse padrão. |
| 4. Autoscaling horizontal | **A favor (secundária)** | É o mecanismo que torna a priorização sustentável — escala o consumidor crítico quando a carga sobe. Mas sem priorização, só escalar ambos consumidores no mesmo nível só move o gargalo. |

**Ordem de preferência:** 1 → 4 → 2 → 3

---

#### Analista 2 — Arquiteto de plataforma (custo e eficiência)

**Diagnóstico.** O time está a 8% acima do orçamento trimestral e a tentação vai ser resolver isso jogando ferro no problema: mais consumidores, mais shards, mais partições. Isso é overengineering para um pico de 25min. O Relay tem 4h de retenção — isso é um buffer gigantesco; o pico "cabe" no buffer se deixarmos o Forge drenar em velocidade reduzida enquanto o Sentinel passa na frente. O que precisamos é extrair valor do que já existe antes de autorizar gasto novo.

**Posição sobre cada estratégia:**

| Estratégia | Posição | Justificativa |
|---|---|---|
| 1. Priorização Sentinel > Forge | **A favor (prioritária)** | Custo zero. Usa a folga de SLA do Forge que já está contratualmente disponível. É o tipo de ganho que não aparece em fatura. |
| 2. DLQ | **Condicional, mínimo viável** | DLQ barato (mesma infra do Relay, só tópico separado) é OK. DLQ "robusto" com replay automatizado custa engenharia que não temos dentro do trimestre — adiar. |
| 3. Sharding por tenant | **Contra** | Dobra ou triplica o custo operacional (mais partições, mais metadata, mais complexidade de rebalanceamento) para resolver um problema que ainda não foi observado. Resolver isso agora é pagar hoje por risco futuro. |
| 4. Autoscaling horizontal | **A favor, mas com teto rígido** | Autoscaling *sem teto* vira cheque em branco. Com HPA + `maxReplicas` calibrado para absorver 2x o pico atual (640k msgs/s teóricos), ganhamos elasticidade sem perder controle de custo. |

**Ordem de preferência:** 1 → 4 (com teto) → 2 (mínima) → 3

---

#### Analista 3 — Engenheiro de dados (integridade e reprocessamento)

**Diagnóstico.** O fantasma do barramento antigo é o enunciado inteiro. O time tem trauma institucional com perda de mensagens, e qualquer solução que envolva "descartar" ou "amostrar sob pico" morre politicamente — com razão, porque telemetry perdida corrompe baseline de alerting e invalida análises retroativas. O verdadeiro ativo do Relay não é o throughput, é a *retenção de 4h* — que é tempo mais que suficiente para o Forge reprocessar sem perda. O risco invisível é confundir "backpressure" com "drop": se autoscaling demora para responder ou se a priorização fizer o Forge perder sua janela de 4h, voltamos ao incidente que não pode acontecer.

**Posição sobre cada estratégia:**

| Estratégia | Posição | Justificativa |
|---|---|---|
| 1. Priorização Sentinel > Forge | **A favor, com guarda explícita** | Priorizar é OK porque Forge pode esperar 15min, mas o Forge não pode acumular atraso maior que a retenção (4h). Precisa de alarme em, digamos, 50% da retenção (2h) para não perdermos evento no limite do buffer. |
| 2. DLQ | **A favor (prioritária)** | A DLQ é o seguro contra o cenário "pico dura muito mais que o esperado" e contra erro de deserialização que o consumidor não consegue processar — *não é* opcional em um produto de observabilidade. Já era devida desde o incidente antigo. |
| 3. Sharding por tenant | **Condicional** | Vale a pena se e somente se já temos um cliente barulhento identificado. Não vi dado nesse sentido no caso — portanto, não agora. Mas instrumentar métricas por tenant, sim, já para a decisão futura. |
| 4. Autoscaling horizontal | **A favor, mas com cuidado** | Autoscaling resolve throughput, não garante integridade. Se o consumidor escalar mas o checkpoint/offset do Forge não acompanhar, podemos reprocessar duplicado ou pular mensagens. Exige revisar idempotência antes. |

**Ordem de preferência:** 2 → 1 (com alarme de retenção) → 4 (com idempotência) → 3

---

### 2. Debate

> **Analista 1 (SRE):** Priorização é o primeiro passo porque transforma a folga contratual do Forge em folga operacional sem custo. Tudo mais é sobre custo de longo prazo ou cenário que não vimos.
>
> **Analista 3 (Engenheiro de dados):** Discordo da ordem. Sem DLQ, priorização é só empurrar o problema: se o pico durar 2h em vez de 25min, o Forge atrasa além dos 15min de SLA e acabamos perdendo o que não coube no buffer. Priorização é alívio tático; DLQ é a rede.

> **Analista 2 (Arquiteto):** A DLQ tem custo esperado zero no caso feliz — ninguém escreve nela quando o sistema está saudável. Mas o engenheiro de dados está pedindo também *replay automatizado*, e isso é um subprojeto. Qual é o custo real da DLQ mínima que você aceita?
>
> **Analista 3:** DLQ mínima = tópico Kafka separado com retenção de 7 dias e dashboard de contagem. Replay é manual via script versionado. Não precisa de orquestrador. Cabe em uma sprint.

> **Analista 1:** OK, aceito DLQ mínima em paralelo com priorização — não são mutuamente exclusivas. Mas quero marcar: o SLA do Sentinel vale 60s, qualquer coisa que adicione latência na ingestão do alerting entra depois de confirmar que priorização está funcionando. Inclusive autoscaling, que tem tempo de resposta não-zero.
>
> **Analista 2:** Concordo. E aqui está o trade-off real: autoscaling "elástico" pode salvar o próximo pico, mas estamos 8% acima do orçamento. Vou ceder em aceitar autoscaling *apenas* se o teto for calibrado para o pico histórico x2, e se tivermos métrica de custo marginal por réplica. Caso contrário vira o próximo overrun do trimestre.

> **Analista 3:** Mais uma preocupação: o debate está convergindo para "não fazer sharding agora". Concordo que não é prioridade, mas sem instrumentação por tenant estamos cegos. Se um cliente barulhento aparecer, vamos descobrir pelo mesmo tipo de incidente. Pode entrar como *métrica*, não como arquitetura.
>
> **Analista 1:** Aceito. Dashboard por tenant é barato e torna a decisão futura de sharding uma decisão baseada em dado, não em medo.

---

### 3. Recomendação convergente

**Ação imediata (próximo pico, antes de qualquer mudança estrutural)**

- Configurar consumer group do Sentinel com prioridade sobre o do Forge no scheduler do Relay (quota garantida de throughput e menor `max.poll.interval` no Sentinel).
- Playbook de incidente: se `sentinel_lag > 30s` sustentado por 2min, operador pausa manualmente o consumer do Forge por até 15min. Documentar o procedimento antes do próximo pico previsto.

**Ação de curto prazo (próximas 2 sprints / ~30 dias)**

| Ordem | Ação | Critério de pronto |
|---|---|---|
| 1 | Priorização estável do Sentinel sobre o Forge no barramento | Sob pico sintético de 2x (640k msgs/s) por 30min: `sentinel_lag_p99 < 45s` e `forge_lag_p99 < 10min` |
| 2 | DLQ mínima: tópico separado + retenção 7 dias + dashboard de contagem + script manual de replay versionado no repo | Mensagem que falhe N vezes no consumer vai para DLQ; dashboard mostra contagem; script replay testado em staging |
| 3 | Autoscaling horizontal dos consumidores (HPA baseado em `consumer_lag`) com `maxReplicas` = 2x baseline atual | Pico sintético de 2x absorvido sem intervenção manual; custo marginal por réplica documentado no dashboard de FinOps |
| 4 | Instrumentação de métricas por tenant (sem particionar, só observar) | Dashboard mostra throughput e lag por tenant; alerta se um tenant passar de 30% do throughput total por 10min |

**Ação estrutural (depois)**

- **Sharding por tenant:** fica para depois. Entra na pauta apenas se a instrumentação (ação 4 acima) mostrar um tenant acima de 30% do throughput total de forma recorrente, ou se um incidente de "vizinho barulhento" for observado.
- **Replay automatizado da DLQ:** fica para depois. Durante a sprint, o replay manual cobre o caso raro; automatizar só se a frequência de uso justificar.

**Risco residual (o que esta recomendação NÃO resolve)**

| Risco | Como monitorar |
|---|---|
| Pico muito mais longo que 25min (ex.: 2h+) pode fazer Forge violar o SLA de 15min mesmo com priorização | Alerta em `forge_lag > 10min` sustentado por 3min |
| Autoscaling pode não responder rápido o suficiente para picos abruptos (<2min) | Alerta em `sentinel_lag > 45s` com `consumer_replicas == maxReplicas` |
| Cliente barulhento isolado ainda consegue afetar os outros | Dashboard por tenant (ação 4) + alerta em distribuição desbalanceada |
| DLQ mínima sem replay automatizado — mensagens podem demorar a voltar se o volume for grande | Alerta em `dlq_count > 1000` em 1h |

---

### 4. Métricas de verificação

| Métrica | Limiar | Fonte sugerida |
|---|---|---|
| `sentinel_consumer_lag_p99` | Alerta amarelo a 30s, vermelho a 45s (SLA é 60s — manter margem) | Exporter nativo do Relay → Prometheus |
| `forge_consumer_lag_p99` | Alerta amarelo a 10min, vermelho a 13min (SLA é 15min — manter margem) | Exporter nativo do Relay → Prometheus |
| `dlq_message_count` (por tipo de erro) | Alerta amarelo a >100 em 1h, vermelho a >1000 em 1h | Dashboard DLQ dedicado |
| `consumer_replicas` vs `maxReplicas` | Alerta se `consumer_replicas == maxReplicas` por >5min (teto está pequeno) | HPA metrics + Prometheus |
| `tenant_throughput_share_p99` | Alerta se qualquer tenant >30% do throughput total por >10min (sinal pró-sharding) | Instrumentação por tenant |
