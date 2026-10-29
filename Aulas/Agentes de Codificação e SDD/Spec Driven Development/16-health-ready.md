# Health Ready

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 16 — Health Ready (16:14) |
| **Assunto** | Implementação dos endpoints de health/readiness (PRD0001) com o ciclo opsx, já com as customizações de context/rules aplicadas |
| **Data** | 29/10/2026 15:50 |
| **Tags** | opsx, openspec, health-check, readiness-probe, kubernetes, prd, blast-radius |

## Resumo da aula

Primeira implementação de código do projeto (até aqui só havia infraestrutura). O instrutor usa o ciclo completo `explore → propose → apply → sync → archive` do opsx para implementar o PRD0001 (endpoints de health e readiness), já se beneficiando das customizações feitas no `config.yaml` (aula anterior): o `proposal.md` gerado agora inclui automaticamente blast radius e plano de rollback; as specs e o design mapeiam o PRD de origem; e as tasks já trazem validação automatizada — tudo sem precisar pedir de novo em cada prompt.

## Conceitos principais

### Health vs Readiness — recapitulação

- **Health** (liveness probe): verifica se a aplicação está saudável e no ar. Resposta esperada: status 200. Se falhar, o Kubernetes reinicia o container.
- **Ready** (readiness probe): verifica se a aplicação está pronta para receber tráfego — inclui checar conectividade com o banco de dados e capacidade de atender requisições (listagem, inclusão, atualização de eventos).

### Explore — refinamento interativo do PRD

Ao rodar `/opsx:explore @<PRD0001>`, o agente inicialmente respondeu em inglês; o instrutor pediu para continuar em português. Nas perguntas levantadas:
- **Timeout do Ready**: decidido verificar conectividade com o banco em no máximo 5 segundos, configurável via variável de ambiente (`ReadyDBTimeoutSeconds`). Isso entrou em conflito com o PRD original, que fixava um teto hardcoded de 2 segundos — o agente sinalizou a implicação antes de seguir, e o instrutor optou por atualizar o próprio PRD para refletir a nova decisão.
- **Log level**: definido como `warning`.

O instrutor pediu explicitamente para o agente atualizar o PRD com essas decisões.

### Propose — specs e manifesto juntos

Ao rodar `/opsx:propose`, o instrutor pediu também que o manifesto Kubernetes fosse alterado para suportar os novos endpoints (não só o código da aplicação). O agente criou a change `addHealthReadyEndpoint` com uma spec adicional específica para o Kubernetes Deployment.

Efeitos visíveis da customização do `config.yaml` (aula anterior) nos artefatos gerados:
- **proposal.md**: agora traz seções explícitas de **blast radius**, impacto em **disponibilidade** e **plano de rollback** — ausentes nas changes anteriores (Docker, K8s), criadas antes da customização.
- **specs**: cada requisito mapeia explicitamente os itens do PRD0001 de origem (ex.: "mapeia P1, P2 e R1 do PRD0001").
- **design**: decisões ancoradas nos ADRs e no PRD, como configurado.
- **tasks**: já trazem validação automatizada e testes, sem precisar pedir de novo.

### Apply e verificação

O instrutor manteve o Sonnet (usado sem querer já na fase de especificação) e considerou o resultado satisfatório, mesmo não sendo o Opus. Após o `/opsx:apply`, o agente criou um `health_router` com uma função de checagem de banco de dados (`check_database`), implementando os endpoints `/health` e `/ready`, parametrizados por variável de ambiente. O instrutor reforça que não faz code review detalhado na aula — verifica em alto nível se a implementação atende aos requisitos, e orienta o aluno a validar na própria máquina se a implementação satisfaz seus requisitos, pedindo ajustes à IA quando necessário.

Testes realizados:
- Manifesto Kubernetes: liveness agora aponta para `/health`, readiness para `/ready` (testado anteriormente também com Kind).
- Local via Docker Compose: `docker compose up -d --build`, requisições a `localhost:8000/health` (retorna status ok) e `/ready` (retorna status do banco como ready).

### Archive com sync na mesma janela

Como é uma tarefa simples, o instrutor executa o `archive` na mesma janela de contexto do `apply` (sem limpar), pedindo explicitamente para fazer o `sync` antes, já que sabia que isso era necessário e não tinha feito ainda. O comando executa sync + archive em sequência, consolidando a spec.

## Comandos e configurações

```
/opsx:explore @<PRD0001>

# decisões dadas durante o explore:
"Quero que verifique a conectividade com o banco de dados em um período de
no máximo 5 segundos, podendo alterar via variável de ambiente."
"Log level será warning."
"ReadyDBTimeoutSeconds" (nome da variável de ambiente)
"Atualize o PRD."

/opsx:propose
"O manifesto Kubernetes também deve ser alterado para suportar os endpoints."

/opsx:apply

/opsx:archive
"Faça o sync, se for necessário."
```

```
# testes manuais locais
docker compose up -d --build
curl localhost:8000/health
curl localhost:8000/ready
```

## Pegadinhas

- O agente pode entrar em conflito direto com o que já está decidido no PRD (ex.: timeout hardcoded de 2s vs. novo requisito de 5s configurável) — nesses casos, é preciso decidir conscientemente se atualiza o PRD ou mantém a decisão original, e pedir explicitamente a atualização do documento.
- Por padrão o agente pode responder em inglês mesmo em um projeto em português — é preciso corrigir isso interativamente.
- As melhorias de customização (`context`/`rules`) só aparecem em changes criadas **depois** da configuração — changes anteriores (Docker, K8s) não têm blast radius/rollback no `proposal.md`.
- Não fazer code review completo na aula é intencional — o foco é a verificação em alto nível de que os requisitos foram atendidos; cabe ao aluno validar o código gerado na própria máquina.
- Rodar `archive` na mesma janela de contexto do `apply` é aceitável para tarefas simples, mas não deixa de ser necessário pedir explicitamente pelo `sync` antes.

## Dúvidas para revisar

- Qual seria o impacto de manter o timeout original de 2 segundos (hardcoded) em vez de alterá-lo para 5 segundos configuráveis — o PRD atualizado documenta esse trade-off?
- Como garantir que futuras atualizações de PRD sejam sempre refletidas tanto na documentação quanto nas specs já arquivadas?
- Vale a pena sempre limpar a janela de contexto antes do archive, mesmo em tarefas simples, para evitar qualquer viés de contexto acumulado?
