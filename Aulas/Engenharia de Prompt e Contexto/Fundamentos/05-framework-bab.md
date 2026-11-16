# Framework B-A-B (Before, After, Bridge)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 05 — Framework B-A-B (Before, After, Bridge) (16:42) |
| **Assunto** | Framework de transformação (Before, After, Bridge) para migrações, refatorações e transições com estado atual e desejado definidos |
| **Data** | 29/10/2026 22:35 |
| **Tags** | bab, before, after, bridge, migracao, refatoracao, transicao-de-carreira, copywriting |

## Resumo da aula

Terceiro framework. O **B-A-B (Before, After, Bridge)** é baseado em **estado atual → estado desejado**. Resolve o que o T-A-G não faz: descrever com clareza o ponto de partida e o ponto de chegada. A origem vem do copywriting (mostra a dor, mostra o resultado, apresenta a solução). O modelo recebe o antes e o depois e **constrói o caminho** (a ponte). Demonstrado com transição de carreira (sysadmin → Cloud Engineer) e migração on-premises → AWS.

## Conceitos principais

### Os 3 componentes

| Componente | Função |
|---|---|
| **Before** | Estado atual — problema, dor, limitação, ponto de partida. Quanto mais específico, melhor |
| **After** | Estado desejado — resultado, cenário ideal, objetivo final. Deve ser realista e específico |
| **Bridge** | O pedido de transformação — plano, passo a passo, análise de gaps, estratégia. É onde o modelo trabalha |

### Diferencial

Contexto completo de **origem e destino**. O modelo não adivinha de onde você vem nem para onde vai — ele monta o plano com base no que você já sabe (ex.: se você é de infra, ele assume que você já conhece rede, DNS, HTTPS).

### Quando usar

- Existe uma transformação clara: migração (VM → container), refatoração (monolito → microsserviços, Jenkins → GitHub Actions), transição de carreira, evolução de stack/monitoramento, reestruturação financeira, mudança de hábitos.

### Quando NÃO usar

- Não há estado anterior (criar do zero): "me dê uma receita de bolo".
- Busca de informação conceitual ("o que é IaC"), criação de documentação — não há os dois estados.

## Prompts da aula

<details>
<summary>Prompts B-A-B</summary>

```markdown
# Transição de carreira: sysadmin para Cloud Engineer
# Before
Hoje trabalho como sysadmin em uma empresa de médio porte. Minha rotina é gerenciar servidores físicos, fazer deploys manuais via SSH, monitorar com Zabbix e apagar incêndios. Não tenho experiência com cloud, containers ou IaC. Meu inglês é intermediário.
# After
Quero estar trabalhando como Cloud Engineer em até 12 meses, com pelo menos uma certificação AWS, domínio básico de Terraform e Kubernetes, e capaz de participar de processos seletivos em empresas que usam cloud nativa.
# Bridge
Crie um plano de transição de carreira em fases mensais, considerando que posso dedicar 2 horas por dia durante a semana e 4 horas nos fins de semana. Inclua certificações recomendadas em ordem e projetos práticos para construir portfólio.
```

```markdown
# Migração on-premises para AWS
# Before
Temos uma aplicação web em Python/Django rodando em 2 VMs on-premises (NGINX + Gunicorn), banco PostgreSQL em uma VM dedicada, storage em NFS, e backups manuais semanais em fita. O monitoramento é básico (Nagios verificando uptime). Deploy é manual: o dev faz SSH, puxa o código do Git e reinicia o serviço. Não temos CI/CD. A aplicação atende ~500 usuários internos.
# After
Queremos a aplicação rodando na AWS com: containers em ECS Fargate, banco em RDS PostgreSQL Multi-AZ, storage em S3, pipeline CI/CD com GitHub Actions, monitoramento com CloudWatch e alertas no Slack, backups automáticos diários com retenção de 30 dias, e infraestrutura como código com Terraform.
# Bridge
Crie um plano de migração em fases, onde cada fase possa ser executada sem derrubar a aplicação em produção. Para cada fase inclua: o que será migrado, pré-requisitos, estimativa de esforço, riscos principais e plano de rollback.
```

</details>

## Pegadinhas

- O After precisa ser **realista** — não colocar um destino inatingível.
- O modelo pode "puxar demais" (ex.: sugerir direto a certificação Solutions Architect Associate em vez de começar pelo Practitioner). Refine com crítica e ajuste o Input ("certificações relevantes" em vez de "pelo menos uma certificação").
- O input influencia muito: mudar uma palavra no After muda a escada de certificações sugerida.

## Dúvidas para revisar

- Como escalonar certificações de forma incremental no Bridge (Practitioner → Associate → Professional) sem o modelo pular etapas?
- Em migração, como garantir que cada fase tenha de fato um plano de rollback executável e não genérico?
