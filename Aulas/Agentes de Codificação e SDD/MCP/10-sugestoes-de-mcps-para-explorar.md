# Sugestões de MCPs para Explorar

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 10 — Sugestões de MCPs para Explorar (03:32) |
| **Assunto** | Catálogo curado de MCPs relevantes para infra/SRE/DevOps/Cloud, por categoria |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `catálogo` `aws` `azure` `gcp` `terraform` `prometheus` `grafana` `datadog` `slack` `context7` `playwright` |

## Resumo da aula

Fechamento do capítulo com uma lista curada de MCPs para começar a usar no dia a dia de DevOps/Cloud/AIOps. Antes de instalar qualquer um: **rodar o checklist da aula 02** (Descobrindo e Avaliando MCP Servers).

## Catálogo por categoria

### Cloud — operar o provedor em linguagem natural
| MCP | Mantenedor | Link |
|---|---|---|
| AWS MCP Servers | awslabs (oficial) | https://github.com/awslabs/mcp |
| Azure MCP Server | microsoft (oficial) | https://github.com/microsoft/mcp |
| gcloud MCP | Google (oficial) | https://github.com/googleapis/gcloud-mcp |
| GKE MCP | Google (oficial) | https://github.com/GoogleCloudPlatform/gke-mcp |

Caso de uso AIOps: cruzar o estado da cloud com o do cluster durante a triagem de incidente.

### Infraestrutura como código (IaC)
| MCP | Mantenedor | Link |
|---|---|---|
| Terraform MCP Server | HashiCorp (oficial) | https://github.com/hashicorp/terraform-mcp-server |

É o oficial vigente — o antigo do awslabs foi **descontinuado**. Costuma rodar via Docker. Consulta o Registry de módulos/providers e raciocina sobre o `plan` antes do `apply`.

### Observabilidade e incidentes
| MCP | Mantenedor | Link |
|---|---|---|
| Prometheus MCP Server | pab1it0 | https://github.com/pab1it0/prometheus-mcp-server |
| Grafana MCP | oficial | https://github.com/grafana/mcp-grafana |
| Datadog MCP Server | oficial | https://github.com/datadog-labs/mcp-server |
| Sentry MCP | oficial | https://github.com/getsentry/sentry-mcp |
| PagerDuty MCP Server | oficial | https://github.com/PagerDuty/pagerduty-mcp-server |

Sentry e PagerDuty fecham o loop **incidente → telemetria → ação**.

### Dados e colaboração — o contexto do time
| MCP | Mantenedor | Link |
|---|---|---|
| PostgreSQL MCP (Postgres MCP Pro) | crystaldba | https://github.com/crystaldba/postgres-mcp |
| Atlassian MCP (Jira/Confluence) | oficial | https://github.com/atlassian/atlassian-mcp-server |
| Slack MCP Server | korotovsky | https://github.com/korotovsky/slack-mcp-server |
| GitHub MCP Server | oficial | https://github.com/github/github-mcp-server |

Postgres MCP: consultar schema e dados em **read-only** para diagnóstico, sem abrir o `psql`. Teams e Discord foram citados como exemplos de colaboração, mas sem server oficial fixado — procurar no registry e verificar procedência antes de instalar.

### Para o agente de código, docs e testes
| MCP | Mantenedor | Link |
|---|---|---|
| Context7 | Upstash | https://github.com/upstash/context7 |
| Playwright MCP | Microsoft | https://github.com/microsoft/playwright-mcp |

Context7: injeta docs atualizadas de bibliotecas sob demanda, combatendo alucinação de API antiga (já configurado na prática na aula 06). Playwright: dirige um browser real para testar UI/reproduzir bug de front.

**Contra-exemplo citado:** Filesystem MCP duplica o que o Claude Code já faz nativamente — lembrete de "não duplique o nativo" (critério da aula 02).

## Onde garimpar mais MCPs
- MCP Registry (oficial): https://registry.modelcontextprotocol.io/
- Smithery: https://smithery.ai/
- PulseMCP: https://www.pulsemcp.com/
- Docker MCP Catalog: https://hub.docker.com/mcp
- awesome-mcp-servers: https://github.com/punkpeye/awesome-mcp-servers

"A lista desta aula é mapa, não teto — procure pelo que falta no SEU domínio."

## Mini-checklist antes de instalar um MCP
1. O agente já não faz isso nativamente? Se faz, é só contexto gasto.
2. Procedência e manutenção: oficial × comunidade, commits/releases recentes.
3. O que o server expõe: tools, resources, prompts — e o blast radius (read-only × write/destroy).
4. Escopo mínimo de credencial: token só com a permissão que a tarefa exige.
5. Instalar com o escopo certo (aula 06) e validar no Inspector (aula 05) antes de confiar no agente.
6. "Menos é mais": habilitar só o que a tarefa pede e desligar o resto.

## Pegadinhas
- Vários comandos `claude mcp add` desta aula são **exemplos plausíveis, não confirmados** ("⚠️ a verificar") — confirme nome do pacote, transporte e variáveis de ambiente na documentação oficial antes de usar.

## Dúvidas para revisar
- Priorizar: para o meu trabalho em DPMG, os mais relevantes parecem ser GKE/gcloud MCP, Terraform MCP e talvez Postgres MCP — testar um de cada vez com o Inspector antes de produção.
