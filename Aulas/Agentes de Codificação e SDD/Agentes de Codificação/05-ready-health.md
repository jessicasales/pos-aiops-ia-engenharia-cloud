# Ready Health — endpoints de liveness/readiness com Cursor

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Agentes de Codificação |
| **Aula** | 05 — Ready Health (14:33) |
| **Assunto** | Implementar /health e /ready de verdade (hoje usa a rota raiz) e configurar as probes no Deployment, com Cursor |
| **Data** | 29/10/2026 19:19 |
| **Tags** | `liveness` `readiness` `probes` `cursor` `kubernetes` `self-healing` `flask` |

## Resumo da aula

Quarta etapa: melhoria do projeto. O manifesto usa a rota raiz (`/`) como liveness/readiness, o que é falha — se o banco cair, a rota raiz pode continuar respondendo 200. Implementação feita com o **Cursor** (primeira ferramenta IDE-first usada no capítulo), em **Plan Mode**, fase a fase.

## Conceitos principais

### Liveness × Readiness (Kubernetes)
| Probe | Pergunta | Ação se falhar |
|---|---|---|
| **Liveness** | O processo está vivo? | Kubernetes **reinicia o container** (self-healing) |
| **Readiness** | A aplicação está pronta para receber tráfego? | Pod sai de "Ready" e **para de receber requisições** (mas não reinicia) |

Usar a rota raiz para ambos é prática ruim — não reflete o estado real de dependências (ex. banco de dados).

### Endpoints implementados
| Endpoint | Verifica | Sucesso | Falha |
|---|---|---|---|
| `GET /health` (liveness) | Só se o processo está vivo — **não** checa banco/dependências | 200 `{"status":"ok"}` | — |
| `GET /ready` (readiness) | Roda `SELECT 1` no Postgres usando a conexão já existente | 200 `{"status":"ready"}` | 503 `{"status":"not ready","reason":"<erro>"}`, **sem derrubar a aplicação** |

Seguem a arquitetura em camadas do projeto (**router → service**), reaproveitando a configuração de conexão existente — nada de criar uma nova.

### Fluxo do Cursor (Plan Mode, fase a fase)
- Modelo usado: **Composer** (próprio do Cursor).
- O agente perguntou se o professor queria confirmar cada fase antes de avançar — "fase a fase".
- Gerou um **diagrama** do que seria alterado (camadas router/service) antes de implementar.
- Depois de implementar, mostrou o diff para revisão (`review` → aceitar).
- Aplicou o manifest no cluster `kind` e testou via `kubectl port-forward`.

## Prompt da aula

```text
A app hoje verifica saúde pela rota raiz (/), mas isso não representa o estado
real: se o banco estiver indisponível, ela continua respondendo 200.

Antes de escrever qualquer coisa, leia a estrutura do projeto e mapeie a
camada de rotas, a camada de service e onde fica a configuração de conexão
com o PostgreSQL.

Depois, implemente dois endpoints seguindo a arquitetura em camadas
(router → service):

1. GET /health (liveness)
- verifica apenas se o processo está vivo
- NÃO checa banco nem dependências externas
- retorna 200 com { "status": "ok" }

2. GET /ready (readiness)
- executa uma query simples (ex.: SELECT 1) no PostgreSQL usando a conexão
já configurada no projeto
- retorna 200 com { "status": "ready" } se a query funcionar
- retorna 503 com { "status": "not ready", "reason": "<erro>" } se a
conexão falhar, sem derrubar a aplicação
- reuse a configuração de conexão existente, não crie uma nova

Para ambos:
- a rota fica na camada de router, a lógica na camada de service
- mantenha o estilo e as convenções dos endpoints existentes

Com os endpoints implementados, suba a aplicação com docker-compose e valide
os dois com curl: GET /health e GET /ready com o banco no ar.

Em seguida, adicione ao Deployment do Kubernetes uma livenessProbe e uma
readinessProbe:
- livenessProbe: httpGet no path /health, na porta da aplicação
- readinessProbe: httpGet no path /ready, na mesma porta
- defina initialDelaySeconds, periodSeconds, timeoutSeconds e failureThreshold
com valores sensatos para uma app Flask, explicando cada escolha
- altere apenas o manifest do Deployment

Antes de aplicar, explique o que acontece se o initialDelaySeconds for baixo
demais para o tempo de boot da app e se os valores sugeridos têm folga
suficiente. Ajuste se necessário.

Aplique o manifest no cluster, acompanhe o rollout e mostre o status do pod
e o kubectl describe evidenciando que as probes estão configuradas e passando.

Por último, simule uma falha de conexão com o banco: a readinessProbe deve
falhar e o pod sair de Ready, mas a livenessProbe deve continuar passando.
Depois restaure o banco e mostre o pod voltando a Ready.

Para o teste com Kubernetes, utilize o kind para criar o cluster e, depois,
mantenha o cluster criado para podermos testar em seguida.
```

## Pegadinhas
- Durante o teste manual, deu erro de `port-forward` por causa de uma anotação específica de AWS deixada no manifest (de uma aula anterior) — o agente não teve esse problema porque testou internamente; sempre confira resíduos de configuração ao trocar de ambiente (AWS → kind).
- Pedir para o agente **explicar o raciocínio de timing** (`initialDelaySeconds` etc.) antes de aplicar ajuda a pegar valores "chutados".

## Dúvidas para revisar
- Revisar os valores de `initialDelaySeconds`/`periodSeconds`/`timeoutSeconds`/`failureThreshold` sugeridos e comparar com o que uso hoje em produção.
