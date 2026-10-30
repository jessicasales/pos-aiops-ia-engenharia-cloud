# Git worktree

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Considerações finais |
| **Aula** | 03 — Git worktree (28:13) — última aula do módulo |
| **Assunto** | Usar `git worktree` para rodar múltiplos agentes de codificação em paralelo, cada um em seu próprio diretório/branch, implementando features independentes sem conflito |
| **Data** | 29/10/2026 23:35 |
| **Tags** | git-worktree, paralelismo, branches, plan-mode, pull-request, docker-compose, conflito-de-porta |

## Resumo da aula

Última aula do módulo "Agentes de Codificação e SDD". Até aqui, todo o trabalho foi conduzido em um fluxo essencialmente linear (mesmo quando usando sub-agentes em paralelo, sempre em torno de uma única feature/incidente). Esta aula apresenta o **Git Worktree** — recurso nativo do Git (funciona com GitHub, GitLab, qualquer implementação) que permite ter múltiplos diretórios de trabalho, cada um vinculado a uma branch diferente, todos apontando para o mesmo repositório — como forma de ter **múltiplos agentes de codificação trabalhando em paralelo em features diferentes**, de forma análoga a uma equipe de várias pessoas trabalhando na mesma base de código.

## Conceitos principais

### O problema que o Git Worktree resolve

Trabalhar em várias features simultaneamente com múltiplos agentes exigiria, ingenuamente, múltiplos clones do mesmo repositório (ineficiente, difícil de gerenciar) ou múltiplos `checkout` de branches diferentes no **mesmo** diretório (impossível trabalhar em duas branches ao mesmo tempo no mesmo diretório de arquivos).

### O que é Git Worktree

Funcionalidade nativa do Git que cria uma **nova branch** e a materializa em um **diretório separado**, como se fosse uma cópia do repositório vinculada àquela branch. Cada worktree pode ser trabalhada de forma independente (edição, commits), e ao final pode-se abrir um PR/merge na branch principal e remover o diretório da worktree.

### Pré-requisito: separação clara de escopo entre features

Como múltiplos agentes (mesmo em diretórios separados) podem acabar tocando nos mesmos arquivos de alguma forma, é essencial escolher features cujo conjunto de arquivos afetados seja **claramente independente** — minimizando o risco de conflito no merge. O mesmo cuidado que se teria ao dividir trabalho entre pessoas de uma equipe real.

### Comandos principais

```bash
# Listar worktrees existentes
git worktree list

# Criar uma worktree com nova branch
git worktree add ../boilerplate-web-app-info -b feat/app-info
git worktree add ../boilerplate-web-request-id -b feat/request-id

# Remover uma worktree (após merge/PR aprovado)
git worktree remove ../boilerplate-web-app-info
git worktree remove ../boilerplate-web-request-id
```

### Demonstração: duas features em paralelo no boilerplate Python

Usando o boilerplate apresentado na aula anterior, o instrutor cria duas worktrees — `boilerplate-web-app-info` (branch `feat/app-info`) e `boilerplate-web-request-id` (branch `feat/request-id`) — e abre **dois terminais diferentes**, um Claude Code em cada diretório.

**Feature 1 — `/api/info`**: endpoint que retorna nome e ambiente da aplicação a partir da configuração existente, sem expor URL do banco, credenciais ou qualquer outra configuração sensível.

**Feature 2 — Request ID**: middleware ASGI que preserva um valor de `X-Request-ID` recebido (ou gera um UUID se ausente), disponibiliza em `request.state.request_id`, e devolve no header de todas as respostas.

Ambos os prompts usam **Plan Mode** explicitamente (sem OpenSpec/SDD, para manter o foco didático no fluxo de worktree), exigindo: ler o `AGENTS.md` e inspecionar a arquitetura antes de propor mudanças; apresentar um plano (escopo, arquivos afetados, testes, riscos) antes de implementar; não alterar templates/middleware/dependências/infraestrutura fora do escopo da própria feature; não criar commit automaticamente.

### Problema real encontrado: conflito de porta

O instrutor havia alterado manualmente (sem commit) o `docker-compose.yml` do boilerplate antes da demo. Resultado: os dois ambientes Docker, subindo em paralelo a partir de worktrees diferentes, tentaram usar a **mesma porta** (8000) — o teste de uma das implementações falhou por a porta já estar em uso pela outra. Correção ao vivo: ajustar a porta no Compose de uma das worktrees, permitindo que os dois ambientes rodassem simultaneamente em portas diferentes. Lição: múltiplos worktrees com ambientes Docker em paralelo exigem atenção a conflitos de porta/recursos — a independência de arquivos não elimina sozinha a independência de infraestrutura em execução.

### Fechamento do ciclo: commit, PR, merge e limpeza

Após as implementações corretas, o instrutor pediu a cada agente, em sua worktree: "Faça commit e abra um pull request para essa implementação." Cada agente comitou os arquivos da sua feature (deixando de fora o `docker-compose.yml`, alterado manualmente fora do escopo da task) e abriu um PR correspondente. Na branch `main` do repositório remoto, os dois PRs apareceram disponíveis para aprovação — simulando o fluxo real de revisão de código de uma equipe. Depois de aprovados e mergeados, o instrutor removeu as duas worktrees (`git worktree remove`) e sincronizou a `main` local (`git pull`), recebendo as duas features integradas.

### Quando usar

Implementação de múltiplas features independentes em paralelo, ou resolução de incidentes diferentes ligados ao mesmo projeto — sempre que o paralelismo real (múltiplos agentes, múltiplos terminais) compensar o esforço de isolamento via worktree.

## Comandos e configurações

```bash
git worktree list

git worktree add ../boilerplate-web-app-info -b feat/app-info
git worktree add ../boilerplate-web-request-id -b feat/request-id

git worktree remove ../boilerplate-web-app-info
git worktree remove ../boilerplate-web-request-id
```

```text
# prompt — Feature App Info (Plan Mode)
Leia o AGENTS.md e inspecione a arquitetura existente antes de propor alterações.

Adicione um endpoint GET /api/info que retorne somente o nome e o ambiente da aplicação a partir das
configurações existentes. O contrato JSON deve usar os campos name e environment. Não exponha a URL
do banco, credenciais ou qualquer outra configuração. Inclua testes em um arquivo dedicado.

Não use OpenSpec e não crie documentos de especificação. Estamos no Plan Mode: primeiro apresente um
plano com escopo, arquivos afetados, testes e riscos. Implemente somente depois que eu aprovar o plano.
Não altere templates, middleware, dependências ou infraestrutura. Não crie commit.
```

```text
# prompt — Feature Request ID (Plan Mode)
Leia o AGENTS.md e inspecione a arquitetura existente antes de propor alterações.

Adicione correlação de requisições HTTP com X-Request-ID. Preserve um valor não vazio recebido nesse
header; quando ele não for informado, gere um UUID. Disponibilize o valor em request.state.request_id
para uso futuro e devolva-o no header X-Request-ID de todas as respostas. Inclua testes para o valor
recebido e para o valor gerado, em um arquivo dedicado.

Não use OpenSpec e não crie documentos de especificação. Estamos no Plan Mode: primeiro apresente um
plano com escopo, arquivos afetados, testes e riscos. Implemente somente depois que eu aprovar o plano.
Não altere endpoints, templates, configurações, dependências ou infraestrutura. Não crie commit.
```

```text
# prompt final em cada worktree, após validação das features
Faça, comite e abra um pull request para essa implementação.
```

## Pegadinhas

- Features com sobreposição de arquivos (ex.: duas features relacionadas ao mesmo módulo "usuário") aumentam significativamente o risco de conflito de merge, mesmo trabalhando em worktrees/diretórios separados — escolher features com escopo de arquivo bem isolado é essencial.
- Rodar ambientes Docker Compose em paralelo a partir de worktrees diferentes do mesmo projeto pode gerar conflito de porta (ou outros recursos compartilhados) — cada worktree pode precisar de configuração de porta própria.
- Alterações feitas manualmente fora do fluxo do agente (como o ajuste no `docker-compose.yml` antes da demo) não são commitadas automaticamente — é preciso prestar atenção ao que de fato entra em cada commit/PR de cada worktree.
- Remover uma worktree com arquivos não commitados (untracked) pode gerar aviso — é preciso decidir entre descartar (`revert`) ou commitar antes de remover.

## Dúvidas para revisar

- Como esse fluxo de worktree se conectaria ao modelo ORDEM e à orquestração por agente principal (capítulo Sub Agentes) — o orquestrador poderia gerenciar a criação/remoção de worktrees automaticamente?
- Vale sempre usar portas configuráveis via variável de ambiente no `docker-compose.yml` dos boilerplates, justamente para evitar o conflito visto nesta aula ao trabalhar com múltiplas worktrees simultâneas?
- Em um cenário real de equipe (não só um profissional orquestrando múltiplos agentes), como as convenções de nomenclatura de branch/diretório de worktree deveriam ser padronizadas para evitar confusão?
