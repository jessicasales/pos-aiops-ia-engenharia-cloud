# Post-mortem — Decisão de Resposta ao Incidente: Rollback `v2.48.0` vs. Escalonamento Emergencial

**Serviço:** chronos-api — Ledger
**Deploy correlacionado:** `v2.48.0` (Argo CD sync 2026-04-23 18:42:11 UTC)
**Janela de análise:** 2026-04-24 13:30 → 14:20 UTC
**Documento:** Apoio à decisão — não é autópsia final (causa raiz em investigação)
**Autor:** SRE (Drafted for on-call/squad decision call)

---

## 1. Resumo executivo

O serviço está em degradação acelerada: **p99 de 420ms → 8.100ms, erro de 0,2% → 11,7% em 50 minutos**, com pool de conexões exaurido, circuit breaker aberto (87% vs. limiar de 50%), RDS com 240/250 conexões e fila do Reactor crescendo a ~800 msg/min (lag de 18 min e aumentando).

**Recomendação preliminar (o que levaremos para o call da sala de guerra):**

1. **Antes de decidir — 1 pergunta crítica:** existe tráfego real consumindo `POST /v2/transactions/batch`?
   - **Se NÃO** (endpoint novo, nenhum consumidor relevante): **Rollback imediato para `v2.47.0`**. É a ação mais rápida, reversível e que não mexe em limites do RDS (menor risco de agravar).
   - **Se SIM**: rollback = quebra de contrato (404 para quem já usa o endpoint). Nesse caso, **escalar primeiro (Opção B) como contenção** e acelerar a investigação da causa.
2. Escalonamento é contenção, **não correção** — não resolve as causas prováveis e tem riscos próprios.
3. Aplicar **gatilhos objetivos de rollback obrigatório** (seção 10) independentemente da escolha inicial.

---

## 2. Classificação do evento

| Item | Valor |
|---|---|
| Severidade | **SEV-1** (experiência degradada, p99 > SLO, fila acumulando) |
| Impacto atual | Erros 11,7%, p99 8,1s, circuit breaker OPEN → falha-rápida amplificando erro upstream |
| Tendência | **Worsening** (todos os sinais crescendo ~linearmente) |
| SLO afetado | Latência e disponibilidade funcional (errors) |

---

## 3. Linha do tempo consolidada

| Horário (UTC) | Evento |
|---|---|
| 04-23 18:42 | Deploy `v2.47.0 → v2.48.0` via Argo CD |
| 04-24 13:30 | p99 420ms (baseline já com resíduo), erro 0,2% |
| 04-24 14:00 | p99 780ms, erro 0,8% — degradação acelerando |
| 04-24 14:10 | p99 2.400ms, erro 4,5% |
| 04-24 14:15 | p99 5.200ms, erro 8,2% |
| 04-24 14:19–52 | Logs: pool exaurido (`max=20, waiting=147`), timeouts, circuit breaker **OPEN**, `connection reset by peer`, falha de publicação no Reactor |
| 04-24 14:20 | p99 8.100ms, erro 11,7% — decisão necessária |

---

## 4. Leitura das evidências (semiologia do incidente)

**4.1. Cronologia não suporta causalidade única e imediata.** O deploy ocorreu 19h antes do início da degradação observada. Compatível com: (a) adoção gradual do `/batch` por clientes, (b) vazamento de conexão acumulando ao longo do tempo (regressão da nova lib interna), ou (c) dois eventos somados (deploy + mudança de tráfego). Um bug puro de deploy normalmente explode na primeira rajada de tráfego.

**4.2. CPU 62% e memória 71% descartam saturação de capacity.** Não é falta de CPU. Com 62% de CPU, um pool saudável entregaria p99 < 1s. O p99 de 8.1s com fila de 147 esperando quase sempre significa **conexões retidas** — por locks/transações longas no lado do banco ou **vazamento na lib de pooling** (conexão não devolvida ao pool).

**4.3. A matemática de conexões está "no fio da navalha" — e isso é estrutural:**
- Pool por pod: `max=20` × 12 pods = **240** conexões possíveis.
- Limite do RDS: **250**.
- Conclusões: (1) **HPA já está no teto (12/12)** → não dá para ganhar mais capacidade via pods; (2) **aumentar só o pool não resolve** porque esbarra no `max_connections` do RDS 2 linhas acima; escalar exige **mexer nos dois** (pool e RDS). Isso encarece e arrisca a Opção B.

**4.4. Timeout 5s → 2s é um multiplicador de dano, não a causa.** Automaticamente transforma queries de 3–4s em erro. Mais erros → mais retries/cancelamentos → mais pressão no pool → circuit breaker abre (87% > 50%) e passa a falhar rápido, **exportando o erro para consumidores upstream**. O backlog do Reactor cresce porque consumidores não conseguem drenar (erros upstream), e o lag de 18min cresce a ~800 msg/min.

**4.5. `connection reset by peer` em 14:19:50** é consistente com banco/proxy rejeitando novas conexões ao atingir `max_connections` (240/250) — ou conexões sendo mortas por idle/reap sob pressão.

**4.6. Mudanças candidatas no `v2.48.0` (cada uma é suspeita ao seu modo):**

| Mudança | Suspeita principal |
|---|---|
| `POST /v2/transactions/batch` novo | Sobe volume por request (N transações por request) → conexões retidas por mais tempo; pode carregar plano de execução/locks novos na tabela `transactions` |
| Refactor do cliente do Ledger (pool → lib interna) | **Suspeito nº 1**: leak de conexão, má leitura de config, pool não-await-safe, health-check ausente |
| Bump psycopg 3.1.18 → 3.2.0 | Comportamento de pooling/timeout/`session` pode ter mudado (verificar changelog e PRs do bump) |
| Timeout Ledger 5s → 2s | Não é causa, mas agrava o erro e dispara o breaker (4.4) |

---

## 5. Hipóteses de causa raiz (ranqueadas por confiança)

| # | Hipótese | Confiança | Peso na decisão |
|---|---|---|---|
| H1 | **Regressão na nova lib de pooling** (leak / config / misuse) retendo conexões → exaustão crescente do pool | **Alta** (padrão clássico: CPU baixa + connections retidas + piora progressiva ao longo de 19h) | Redundância a favor do **rollback** |
| H2 | Padrão de acesso do `/batch` gerando plano de execução caro e/ou **locks** na tabela transacional → transações longas prendendo conexões | Média (lock lento não explicaria sozinho 240/250 com 62% CPU sem picos de banco) | A favor escalar + rate-limit; rollback quebra contrato |
| H3 | Bump psycopg 3.2.0 com breaking change de comportamento (pooling/session/timeout) | Baixa–Média | Reforça rollback (bump é reversível junto) |
| H4 | Pico real de tráfego (demanda) — sem relação com código | Baixa (CPU 62% não sustenta; mas `req_rate` subiu 1200→2650) | A favor escalar |

---

## 6. Opção A — Rollback para `v2.47.0`

**Procedimento:** sincronizar Argo CD para a versão anterior (`rollback`/`retry` com target `v2.47.0`). Nada novo além do revert.

| | |
|---|---|
| Tempo esperado p/ efeito | Erros/DOR caindo em ≤ 10–15 min; lag do Reactor drenando em seguida |
| Reversibilidade | Alta (voltar para `v2.48.0` é um clique, quando hipótese confirmada) |
| Custo de risco | Baixo — **não** mexe em RDS, pool, HPA |

**Riscos e mitigação:**
1. **Quebra de contrato** se clientes já usam `/v2/transactions/batch` (endpoint não existe em v2.47.0) → 404 em massa. **Mitigação:** conferir tráfego por rota no ingress/apiserver ANTES de decidir; se houver consumidores, tratar via feature-flag no rectify (ver conclusão da seção de decisão).
2. Se a causa for H2/H4 (banco/tráfego), rollback não resolve sozinho → escalar de qualquer forma (combinação Opção A + componentes da Opção B).
3. Não perder o `v2.48.0` — ele pode voltar após correção da causa.

**Veredito:** opção mais rápida, segura e diagnóstica. Neutraliza H1 e H3 completamente.

---

## 7. Opção B — Escalonamento emergencial

**Escopo do que escalar (intervenções em sequência):**

| Intervenção | Ação | Efeito | Risco |
|---|---|---|---|
| 1. Reator | Pausar/desacelerar consumo ou aumentar concorrência de consumidores | Contém crescimento do lag | Backlog continua; pode sobrecarregar mais |
| 2. Rate-limit no `/batch` | Throttle no gateway/ingress e/ou app | Corta a fonte de pressão | Rejeições 429 (visível) |
| 3. Pool por pod | 20 → 40 | 240 → 480 conexões | Só funciona SE o RDS aceitar (ver 4) |
| 4. **RDS `max_connections`** | 250 → (ex.: 1000) **somente com headroom validado** | Dá folga p/ pool e p/ vazamentos | **Niágara**: cada conexão reserva memória do Postgres (`work_mem`/`shared_buffers`/overhead ~10–20MB). Aumento sem colateral = OOM na instância RDS. Ver tamanho da instância e headroom |
| 5. Timeout Ledger 2s → 5s | Revive queries de 3–4s | Reduz erros; reduz disparo do breaker | Encarrega mais o banco (possível piora se origem = locks) |
| 6. HPA `maxReplicas` ↑ | 12 → 16+ | +capacidade | Não resolve se origem for leak/locks; pool total cresce ainda mais — esbarra em RDS 250 |

**O que a Opção B NÃO corrige:** H1 (vazamento) e H3 (bump). Com vazamento ativo, escalar só adia a exaustão — e a folga criada será devorada pela fuga de conexões. Aumentar `max_connections` do RDS sem correção da causa migra o problema para OOM.

**Custo de risco:** médio-alto. Mexe em limites produtivos sob falha-rápida (pior momento para erro de cálculo de memória).

---

## 8. Matriz de decisão

| Critério | Rollback (A) | Escalar (B) | Vencedor |
|---|---|---|---|
| Tempo para estancar | ~10–15 min | 30–60+ min + validação de memória RDS | **A** |
| Remove suspeito nº1 (pool/psycopg)? | **Sim** | Não | **A** |
| Resolve possível caso de capacidade/tráfego (H2/H4)? | Parcial | Sim (temporário) | **B** |
| Quebra contrato do `/batch`? | Sim, se em uso | Não | **B** |
| Risco de colateral (RDS OOM, limites produtivos) | Baixo | Médio-alto | **A** |
| Gera evidência diagnóstica limpa (A/B) | Sim | Não (meio "sujo") | **A** |
| Reversível | Sim | Parcialmente (reduzir RDS depois exige manutenção) | **A** |
| Custo de execução sob incidente | 1 operação | 5–6 operações | **A** |

---

## 9. Recomendação e plano de ação imediato

**Decisão recomendada (fluxo em gates):**

1. **Gate 0 — diagnóstico de contrato (5 min, agora):** checar no telemetry/routing se `/v2/transactions/batch` tem tráfego não-trivial.
2. **Se não tem consumidores relevantes → ROLLBACK (Opção A) imediato + contenção do Reactor.**
3. **Se tem consumidores → ESCALAR PRIMEIRO (Opção B):** rate-limit do `/batch` > aumentar pool p/ 40 > RDS `max_connections` (com memória validada) > timeout 2s→5s, nesta ordem; e tratar a correção da causa como SEV-1 paralela.
4. **Gatilhos objetivos de rollback — independente do que se decida acima:**
   - `err_rate` ≥ 5% sustentado por 10 min continuados; **ou**
   - lag do Reactor > 30 min e crescendo; **ou**
   - conexões ao RDS atingindo 250 (reset de peers ativo)
   → **rollback obrigatório mesmo que haja consumidores do `/batch`** (404 de contrato < indisponibilidade geral).
5. **Após rollback:** manter `/batch` em feature-flag/desabilitado até prova de causa; preparar release `v2.49` sem as mudanças problemáticas.

---

## 10. O que fazer depois de estabilizar (para o post-mortem final)

- **Auditoria de leak na lib do pool:** confirmar via `pg_stat_activity` (contando `idle in transaction` > 5s) se há **conexão não devolvida**; conferir health-check do pool habilitado.
- **Changelog rigoroso do bump psycopg 3.2.0** e do refactor (diff da lib interna; testes de carga antes de produção).
- **Plano de execução / locks:** query plan do padrão do `/batch` sobre `transactions`; checar bloat, índices ausentes, locks (`pg_locks`).
- **Teste de carga do novo endpoint** em ambiente canary — medindo conexões retidas por request.
- **Runbook:** criar gestão de `max_connections` × memória RDS (fórmula base: ~10–20MB/conexão × headroom).

---

## 11. Checklist de evidências a coletar AGORA (sem mudar sistema)

- [ ] Tráfego por rota (`/batch` vs. `/v1/*`) no apiserver/ingress a partir de 13:30
- [ ] `pg_stat_activity`: top conexões, `state` (active/idle in transaction/idle), duração média de queries, locks em `transactions`
- [ ] `max_connections` atual do RDS e memória/tipo de instância (para cálculo de colateral)
- [ ] Métricas da lib interna de pool (conexões criadas/liberadas por pod) — procurar crescimento monotônico sem devolução
- [ ] Changelog oficial e PRs do bump psycopg 3.2.0 e do refactor
- [ ] Quem está chamando `/v2/transactions/batch` (consumidores do Reator/API) e volumetria
- [ ] Retry policy dos clientes do Reator (retry storm amplifica erro de upstream)