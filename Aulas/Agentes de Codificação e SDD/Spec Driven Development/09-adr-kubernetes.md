# ADR Kubernetes — decisão de Cloud Provider e ambiente de produção

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 09 — ADR Kubernetes (17:57) |
| **Assunto** | Brainstorm e ADR para a decisão de Cloud Provider (AWS) + serviço (EKS) + perfil de nós |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `adr` `aws` `eks` `rds` `node-group` `brainstorm` `advogado-do-diabo` |

## Resumo da aula

Segundo ADR do projeto: definir onde a aplicação roda em produção — **Cloud Provider** + **serviço gerenciado**. Mesmo fluxo (brainstorm → ADR), mas aqui o professor já entra com decisões fechadas (AWS, EKS) e debate o resto (banco, tipo de nó, HA) com o agente fazendo de "advogado do diabo".

## Conceitos principais

### Contexto dado de cara (decisões já tomadas, sem debate)
- **AWS** como Cloud Provider — parceria já existente da empresa.
- **EKS** em vez de **ECS** — padrão Kubernetes da equipe de DevOps, mais controle que ECS.

### Pontos debatidos no brainstorm
| Tema | Trade-off levantado | Decisão final |
|---|---|---|
| Banco de dados | Postgres em container no cluster × **RDS gerenciado** | RDS, numa única AZ + réplica de contingência em outra (sem necessidade de HA de réplicas) |
| Nós do EKS | Managed Node Group × **Fargate** | Managed Node Group — mais controle de provisionamento |
| Tamanho do nó | t3a.medium (2 vCPU/4GB) sugerido primeiro, depois questionado pelo professor por ser "aplicação leve" | **t3.small**, priorizando **escalabilidade horizontal** (réplicas) em vez de nó grande |
| On-Demand × Spot | O agente sugeriu Spot para reduzir custo | Professor **recusou Spot** — on-demand |

### A dinâmica da "bateria de interações"
O professor reforça que é normal — e desejável — várias rodadas de ida e volta: ele questiona a sugestão do agente (ex.: "o nó de 2vCPU/4GB é grande demais para uma app leve, pensar em escalar horizontalmente"), o agente reavalia e devolve uma análise atualizada ("concordo com a direção... mas qual alavanca entrega alta disponibilidade — não é o tamanho do nó, é quantidade de réplicas + Pod Disruption Budget"). **O importante é chegar a um denominador coerente com a real necessidade**, não aceitar a primeira sugestão.

### Escopo do ADR (definido explicitamente)
Só Cloud Provider + serviço + nós do EKS. **Fora do escopo**: Ingress, registry, infraestrutura como código, CI/CD — tudo isso fica para outros documentos.

### Resultado: `docs/adrs/02-ambiente-de-producao.md`
Contexto, alternativas (ECS × EKS, Fargate × Managed Node Group, Postgres no cluster × RDS, Spot × On-Demand), decisão (EKS com Managed Node Group, instâncias pequenas/burstable, capacidade On-Demand — razão principal: padronização do Kubernetes), consequências e premissas marcadas.

### Gancho para a próxima aula
Depois de dois ADRs criados, **o TRD ficou desatualizado** — as decisões de containerização e ambiente de produção não estão refletidas nele. Próxima aula: atualizar o TRD a partir dos ADRs.

## Prompts da aula

O **mesmo prompt de brainstorm** e o **mesmo prompt de ADR (template MADR)** das aulas anteriores — só muda o conteúdo de contexto fornecido. Ver aula 08 para o texto completo dos templates.

```text
Eu preciso definir aqui o ambiente de produção onde essa aplicação vai ser
executada. Nós já temos parceria com a AWS. Então, a AWS já foi decidida como
o Cloud Provider que vai ser utilizado. Falta definir em qual serviço que vai
ser utilizado da AWS para executar a aplicação, considerando que ela já está
preparada para containers. Então, nós vamos utilizar, no caso, o EKS no lugar
do SES/ECS, porque a empresa tem o Kubernetes como padrão, então a equipe de
DevOps já tem esse conhecimento, além do que, o EKS me dá muito mais controle
sobre o ambiente em relação ao ECS.
```

## Pegadinhas
- Dar contexto já com decisões fechadas (Cloud Provider, serviço) economiza rodadas de debate — reserve o brainstorm para o que realmente precisa de análise.
- Não aceitar de primeira a sugestão de dimensionamento do agente — questionar é parte do processo, não falha dele.
- Escopo apertado evita que um ADR vire "faz-tudo" — Ingress, IaC e CI/CD ficam para outros ADRs/documentos.

## Dúvidas para revisar
- Pensar em quando vale a pena recusar Spot/preemptible por previsibilidade × quando vale o risco pelo custo, no meu contexto de trabalho.
