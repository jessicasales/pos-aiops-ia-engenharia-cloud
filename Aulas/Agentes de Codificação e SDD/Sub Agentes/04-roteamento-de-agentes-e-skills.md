# Roteamento de Agentes e Skills

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 04 — Roteamento de Agentes e Skills (24:02) |
| **Assunto** | Três formas de rotear uma tarefa para um sub-agent (delegação automática, nome em linguagem natural, menção explícita com `@`) e como o sub-agent carrega skills por conta própria |
| **Data** | 29/10/2026 19:15 |
| **Tags** | roteamento, delegacao-automatica, mencao-explicita, arroba, skill-trigger, janela-de-contexto |

## Resumo da aula

Aula prática que usa os dois sub-agents criados na aula anterior (`devops-engineer` e `software-developer`) em três cenários reais do projeto Encontros Tech — implementação de um endpoint de consulta por ID, criação de Docker/Docker Compose, e criação de manifestos Kubernetes — cada um demonstrando uma forma diferente de **rotear** a tarefa para o sub-agent certo: delegação automática, nome do agente em linguagem natural, e menção explícita com `@`. A aula também evidencia que um sub-agent pode carregar uma **skill** por conta própria, pela trigger da description da skill — reforçando a distinção entre agente (escopo/papel) e skill (procedimento).

## Conceitos principais

### As três formas de rotear para um sub-agent

1. **Delegação automática**: o prompt apenas instrui "Utilize um subagente", sem nomear qual. O agente principal escolhe o sub-agent certo com base na `description` de cada um disponível (daí a importância de descriptions bem estruturadas, como já visto com skills).
2. **Nome do agente em linguagem natural**: o prompt menciona o nome do agente dentro do texto (ex.: "Use o agente devops-engineer para..."). Aqui a `description` do agente importa menos, porque a escolha já foi feita explicitamente pelo usuário.
3. **Menção explícita com `@`**: digitar `@devops-engineer` no campo de prompt da ferramenta (o Claude Code sugere o agente ao digitar `@`), garantindo a seleção do sub-agent sem depender da interpretação do agente principal. Ao reproduzir em outra ferramenta, usar o seletor de menção equivalente daquela ferramenta em vez de digitar o nome manualmente.

### Cenário 1 — Delegação automática: endpoint de consulta de evento por ID

Prompt zero-shot (sem Plan Mode, sem SDD) pedindo a implementação de `GET /api/events/<id>` (200 com dados do evento se existir, 404 se não existir, sem expor detalhes internos do erro), reaproveitando a camada de serviço e a exceção `EventNotFoundError` já existentes, com testes cobrindo os dois casos, sem alterar modelo/schema — e a instrução "Utilize um subagente". O agente principal identificou que o `software-developer` era a melhor opção (por ser implementação de código) e delegou. Resultado: o sub-agent implementou o endpoint no `api_router`, criou o teste correspondente, não tocou no modelo — e **não chamou nenhuma skill**, porque não havia skill de desenvolvimento/Python cadastrada no projeto (só skills de brainstorm, design docs, dockerização, troubleshoot Kubernetes). Consumo de contexto do agente principal: **6%**.

### Cenário 2 — Nome do agente em linguagem natural: Docker e Docker Compose

Antes do teste, o instrutor deletou e commitou a remoção do Dockerfile/Compose/`.dockerignore` e do manifesto Kubernetes, para garantir que o sub-agent não "visse" uma implementação anterior já existente — prática recomendada ao comparar comportamentos entre abordagens: sempre usar o mesmo cenário de partida. Prompt: "Use o agente devops-engineer para preparar a execução local desta aplicação com Docker", especificando os artefatos esperados (Dockerfile, `.dockerignore`, `compose.yaml`, configuração de banco via variáveis de ambiente, healthcheck via `/health`, dependência condicionada à disponibilidade do Postgres), proibindo inventar credenciais e alterar código da aplicação, e pedindo validação com evidências.

Ponto importante observado: o `devops-engineer`, ao identificar que a tarefa envolvia Dockerfile/Compose, **carregou automaticamente a skill "Dockerizar aplicação"** criada em capítulos anteriores — porque a trigger (description) da skill correspondia à tarefa. Isso demonstra na prática a diferença entre agente (contexto/comportamento geral) e skill (workflow específico): o agente decide, por si, quando uma skill disponível deve ser usada. Resultado: Dockerfile, `.dockerignore` e `compose.yaml` criados seguindo as instruções da skill (ex.: Hadolint executado como parte da validação, conforme a própria skill instrui), com relatório de evidências. Consumo de contexto do agente principal: **8%**.

### Cenário 3 — Menção explícita com `@`: manifests Kubernetes

Prompt: `@devops-engineer crie os manifests Kubernetes necessários para executar esta aplicação`, especificando Deployment, Service, liveness probe (`/health`), readiness probe (`/ready`), requests/limits, security context, configuração via variáveis de ambiente, referência à imagem `encontros-tech:1.0.0`; proibindo Helm/Kustomize, proibindo aplicar os manifests em qualquer cluster, proibindo alterar código/artefatos Docker; pedindo validação local e evidências. Como não havia skill específica de manifestos Kubernetes cadastrada, o sub-agent executou a tarefa só com as instruções do próprio prompt. Resultado: arquivos criados em `k8s/`, com observação do próprio agente sobre o `CLAUDE.md` estar desatualizado (mencionando um nome de projeto anterior). Consumo de contexto do agente principal: **9%**.

### Diferença sintática entre nome e `@`

O instrutor esclarece que a escolha entre citar o nome do agente em texto corrido ou usar `@nome` é majoritariamente estilística: `@` tende a ser usado quando o prompt é mais direto/comando; o nome em linguagem natural quando o prompt é mais narrativo/cursivo.

### Reforço do padrão observado nas três execuções

Em todos os cenários, a janela de contexto do agente principal ficou em uma faixa pequena (6-9%), independentemente da complexidade da tarefa delegada — reafirmando o princípio da "caixa preta" (fronteira) já estabelecido na primeira aula do capítulo: o agente principal só vê o input (prompt) e o output (resultado/relatório), nunca o processamento interno do sub-agent.

### Gancho para a próxima aula

Os sub-agents criados até aqui têm acesso a **todas** as ferramentas disponíveis no harness (Bash, MCPs, etc.) — não há ainda nenhuma restrição (ex.: impedir que o `devops-engineer` acesse código, ou que o `software-developer` acesse um MCP de Kubernetes). Isso é tema da próxima aula, sobre recorte de capacidade (ferramentas, modelo e permissões).

## Comandos e configurações

```text
# Cenário 1 — delegação automática
Implemente a consulta de um evento pelo ID na API.

Crie o endpoint GET /api/events/<id> com o seguinte comportamento:

- retornar 200 e os dados do evento quando ele existir;
- retornar 404 quando o evento não for encontrado;
- não expor detalhes internos do erro na resposta.

Reutilize a camada de serviço e a exceção EventNotFoundError que já existem no projeto.

Crie ou atualize os testes necessários para cobrir os dois retornos.

Não altere o modelo nem o schema do banco de dados.

Utilize um subagente.

Execute os testes relacionados e retorne os arquivos alterados e o resultado da validação.
```

```text
# Cenário 2 — nome do agente em linguagem natural
Use o agente devops-engineer para preparar a execução local desta aplicação com Docker.

Analise a aplicação e crie somente os artefatos necessários para executar o Encontros Tech e o PostgreSQL com Docker Compose.

O resultado deve incluir:

- Dockerfile para a aplicação;
- .dockerignore;
- compose.yaml com os serviços da aplicação e do PostgreSQL;
- configuração da conexão com o banco usando variáveis de ambiente;
- healthcheck da aplicação usando o endpoint /health;
- dependência da aplicação condicionada à disponibilidade do PostgreSQL.

Use as configurações e os arquivos de exemplo que já existem no projeto. Não invente credenciais ou valores que possam ser descobertos no repositório.

Não altere o código da aplicação.

Valide os artefatos criados e retorne as evidências das verificações executadas.
```

```text
# Cenário 3 — menção explícita com @
@devops-engineer crie os manifests Kubernetes necessários para executar esta aplicação.

Salve os arquivos no diretório k8s/.

O resultado deve incluir:

- Deployment;
- Service;
- liveness probe usando /health;
- readiness probe usando /ready;
- requests e limits;
- security context;
- configuração da aplicação por variáveis de ambiente;
- referência à imagem encontros-tech:1.0.0.

Use o Dockerfile, o compose.yaml e as configurações existentes no projeto como fonte.

Não use Helm ou Kustomize.

Não aplique os manifests em nenhum cluster.

Não altere o código da aplicação nem os artefatos Docker.

Valide localmente os arquivos que puderem ser validados e retorne as evidências.
```

## Pegadinhas

- Para comparar comportamentos entre diferentes formas de delegação, é importante sempre partir do mesmo estado do projeto (deletar e commitar os artefatos anteriores) — testar em cenários diferentes dá só uma "percepção", não uma comparação precisa.
- A ausência de uma skill relevante para a tarefa (ex.: skill de desenvolvimento Python) significa que o sub-agent trabalha só com suas próprias instruções — é um lembrete de que a cobertura de skills no projeto impacta diretamente a qualidade do resultado do sub-agent.
- O sub-agent pode interpretar e tomar decisões não especificadas no prompt (ex.: criar arquivos separados quando não foi pedido explicitamente) — sempre revisar o resultado.
- Sub-agents, por padrão, têm acesso a todas as ferramentas do harness — não há isolamento de permissões até que isso seja configurado explicitamente (próxima aula).

## Dúvidas para revisar

- Vale criar uma skill de "desenvolvimento Python/Flask" para o projeto Encontros Tech, já que o cenário 1 mostrou que o `software-developer` não tinha nenhuma skill disponível para consumir?
- Como ficaria o comportamento se houvesse mais de uma skill com triggers que se sobrepõem — o agente escolheria qual, e por quê?
- Depois de restringir ferramentas/permissões por agente (próxima aula), os três modos de roteamento (automático, nome, `@`) continuam funcionando da mesma forma?
