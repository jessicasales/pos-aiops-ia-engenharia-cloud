# SDD Docker

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 13 — SDD Docker (32:16) |
| **Assunto** | Fluxo completo do ciclo core do OpenSpec (opsx) aplicado na prática: empacotamento da aplicação com Docker |
| **Data** | 29/10/2026 15:00 |
| **Tags** | opsx, openspec, docker, ciclo-core, explore, propose, apply, sync, archive |

## Resumo da aula

Esta é a aula-base do mecanismo do `opsx` — as aulas seguintes (SDD K8S, Health Ready, Seed) só reaplicam o mesmo ciclo em alvos diferentes, então o material complementar desta aula serve de referência para todas elas. O instrutor implementa, na prática, o empacotamento Docker da aplicação usando o ciclo completo do OpenSpec: `explore` → `propose` → `apply` → `sync` → `archive`. Mesmo sendo um requisito técnico (não um PRD/feature de negócio), o OpenSpec funciona perfeitamente, pois o fluxo de especificação para a IA executar é o mesmo.

O instrutor usa o Opus (melhor modelo disponível) na fase de levantamento de requisitos/especificação, e troca para o Sonnet (mais barato) na fase de codificação/implementação — reforçando a prática já mencionada em aulas anteriores de usar o modelo mais caro só onde o raciocínio é crítico.

## Conceitos principais

### O ciclo core do opsx, na ordem

O `openspec init` (aula anterior) instalou o profile *core* — cinco passos. Cada comando é disparado dentro do agente de codificação (são *commands*, com barra), exceto os de validação, que são da CLI:

1. `/opsx:explore` — pensar a change contra o que já está decidido (TRD + ADRs). É pensamento, não compromisso — nada é criado ainda.
2. `/opsx:propose` — materializa a proposta e cria a change em `openspec/changes/<nome>/`.
3. `/opsx:apply` — o agente executa as tasks e escreve o código (nesta aula: Dockerfile + `.dockerignore`).
4. `/opsx:sync` — sincroniza os Spec Deltas com o estado da spec.
5. `/opsx:archive` — mescla o delta nos specs canônicos e fecha o ciclo (a change sai de `changes/` e vai para `archive/`).

### Os quatro artefatos que o `propose` gera

Dentro de `openspec/changes/<nome-da-change>/`:
- `proposal.md` → o porquê + o escopo (o "contrato" da mudança)
- `specs/` → o delta: diff da capability (ADDED / MODIFIED / REMOVED)
- `design.md` → a decisão técnica, já ancorada nos ADRs
- `tasks.md` → o checklist executável que o `apply` vai percorrer

Ponto central: o agente não decidiu a imagem base nem o process manager — ele leu isso dos ADRs 001-003 (aula ADR Docker), e o `design.md` apenas referencia a decisão. O SDD separa **decidir** (ADR) de **planejar a execução** (design).

### Fluxo prático demonstrado

1. **Explore**: `/opsx:explore` apontando para o TRD, pedindo "implementar uso de Docker na aplicação, criando o Dockerfile e Docker Compose". O agente lê os ADRs e o TRD, monta um plano inicial (multistage, lean, non-root) e vai perguntando decisões em aberto — o instrutor refina interativamente (Dockerfile dentro de `src/`, sem `.env` no Compose, sem testes dentro da imagem, log format simples, sem health check endpoint próprio).
2. **Propose**: ao rodar `/opsx:propose`, o agente gera os 4 artefatos (change "Containerizar App Docker"), já refletindo exatamente o que foi explorado, "sem drift".
3. **Apply**: trocando para o Sonnet, o agente executa o `tasks.md` tarefa por tarefa, construindo Dockerfile (multistage, imagem `3.9-slim`, usuário non-root), `docker-compose.yml` (Postgres com volume, healthcheck, `depends_on`) e `.dockerignore`.
4. **Validação**: o instrutor edita o `tasks.md` para pedir que a validação seja feita pelo próprio agente (rodando `docker compose up` e testes), não manualmente — o agente reexecuta e inclui teste de rota na API.
5. **Teste real**: `docker compose up -d --build`, acesso em `localhost:8000`, cadastro de um evento de teste — funcionou.
6. **Sync**: `/opsx:sync` leva o que foi implementado (capability "empacotamento docker") para a pasta `specs/`, criando o snapshot atual do estado da aplicação.
7. **Archive**: `/opsx:archive` move a change de `changes/` para `archive/`, mantendo histórico datado.

### Changes em paralelo

Pergunta do instrutor a si mesmo: é possível ter várias changes em paralelo? Sim — mas ele recomenda fazer sequencialmente quando se trabalha sozinho. Em equipe, dá para paralelizar, desde que cada change seja bem isolada, para evitar conflitos de merge (o mesmo problema do desenvolvimento tradicional sem IA).

### Comandos avançados do opsx (mencionados, não usados na demo)

- `/opsx:new` — scaffold da change sem gerar tudo, começa pelo esqueleto.
- `/opsx:continue` — cria o próximo artefato seguindo as dependências, um passo por vez.
- `/opsx:ff` — fast-forward: gera todos os artefatos de planejamento de uma vez.
- `/opsx:verify` — valida a implementação em três dimensões (mais rico que o `validate` da CLI).
- `/opsx:bulk-archive` — arquiva várias changes concluídas de uma vez.

## Comandos e configurações

```
/opsx:explore
/opsx:propose
/opsx:apply
/opsx:sync
/opsx:archive

openspec validate <change> --strict   # delta bem-formado e completo (CLI)
openspec status                       # artefatos concluídos? tasks fechadas?
openspec list                         # após archive: spec consolidada como novo baseline

/opsx:new
/opsx:continue
/opsx:ff
/opsx:verify
/opsx:bulk-archive
```

## Pegadinhas

- A IA é probabilística, não determinística — o resultado no seu ambiente não vai ficar exatamente igual ao da demo. É preciso avaliar e corrigir, nunca copiar e colar sem revisão.
- Ao interagir com o `explore`, cuidado para não "dar mole": se você continuar respondendo perguntas sem travar o escopo, o agente pode seguir direto para gerar a proposta sem você ter controlado explicitamente a transição — o instrutor prefere ele mesmo rodar o comando de execução (`propose`) ao invés de deixar o agente continuar sozinho.
- Requisito técnico (como "empacotar com Docker") não é um PRD nem uma regra de negócio, mas o OpenSpec funciona igual, pois o change pode ser de requisito técnico.
- Testes de unidade/integração não devem rodar dentro do Dockerfile/Compose — isso deve ficar fora (ex. pipeline), a não ser que se crie um ambiente de teste específico.
- Revisar os documentos gerados (`proposal.md`, `specs/`, `design.md`, `tasks.md`) com calma é essencial — o instrutor não leu tudo na aula para não estender o vídeo, mas recomenda que o aluno sempre faça essa revisão.

## Dúvidas para revisar

- Qual critério usar para decidir quando vale a pena ter múltiplas changes em paralelo versus trabalhar sequencialmente?
- Como ficaria o `tasks.md` se a validação automatizada pelo agente precisasse rodar em CI, não apenas localmente?
- Vale reproduzir esse mesmo fluxo completo (explore → propose → apply → sync → archive) para o empacotamento Kubernetes da próxima aula, comparando as diferenças de ADRs referenciados?
