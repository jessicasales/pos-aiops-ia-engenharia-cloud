# Listagem do K8S e Banco de Dados

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 08 — Listagem do K8S e Banco de Dados (15:21) |
| **Assunto** | Implementação do PRD 003 (clusters Kubernetes + bancos de dados gerenciados) — uma change com duas capabilities, testes end-to-end reais (~20 min) e o fechamento do projeto com archive/sync |
| **Data** | 30/10/2026 01:15 |
| **Tags** | opsx-apply, archive-sync, teste-end-to-end, capabilities, enum, pydantic, organizacao-de-tools |

## Resumo da aula

Terceira e última feature do MCP didático de DigitalOcean (PRD 003, detalhado na nota da aula 05): listar clusters Kubernetes (DOKS) e bancos de dados gerenciados, cada um em sua própria consulta. É a feature mais simples em termos de lógica (leitura pura, sem filtro), mas a mais cara em termos de teste — os testes end-to-end criam cluster Kubernetes, banco gerenciado e Droplets reais, levando cerca de 20 minutos na gravação. A aula fecha o projeto completo, com o fluxo de `archive` + sincronização de todas as changes do OpenSpec.

## Conceitos principais

### Generalização do padrão: outros serviços, outros provedores

O instrutor reforça que o padrão demonstrado (consultar um serviço de cloud via MCP) pode ser estendido a qualquer outro serviço da DigitalOcean, ou até de outro provedor (AWS, Azure, GCP) — não é necessário usar um MCP já pronto de terceiros; construir o próprio MCP para um serviço específico é uma forma válida (e didaticamente recomendada) de consolidar o aprendizado da estrutura do protocolo.

### Pedido combinando plano de ação e propose em um único comando

```text
/build-mcp-server @docs/prds/003-consulta-de-kubernetes-e-bancos-gerenciados.md Crie o plano de ação, sem criar nada nesse momento. Depois de tudo especificado, crie o propose.
```

Diferente das aulas anteriores (que pediam a análise e esperavam, separadamente, pelo propose), aqui o pedido já antecipa a sequência completa: plano de ação → especificação → propose automático, sem nova interação manual entre as etapas.

### Decisões levantadas pelo agente durante o plano de ação

1. **Organização da change**: uma change só, com **duas capabilities** (Kubernetes e banco de dados), em vez de duas changes separadas — decisão de manter tudo relacionado ao PRD 003 numa única unidade rastreável de OpenSpec.
2. **Testes end-to-end na conta real**: decisão de criar os recursos reais (cluster Kubernetes, banco gerenciado) para o teste, em vez de qualquer forma de simulação — coerente com a prática já estabelecida nas aulas anteriores de nunca usar mock para testes de integração deste projeto.
3. **Representação dos estados na saída**: `enum` em vez de string livre, porque os estados possíveis são fixos — mesmo padrão já adotado no PRD 001 para o estado dos Droplets.

```text
Organização da change: uma change só, com as duas capabilities (Kubernetes e banco de dados).
Testes end-to-end na conta real: criar os recursos reais.
Estados na saída: enum, porque os estados são fixos.
```

### Observação sobre contexto decrescente conforme o projeto evolui

Ponto pedagógico explícito do instrutor, ao notar que o agente já incluiu a etapa de testes end-to-end sem precisar ser instruído dessa vez (diferente das aulas anteriores): **conforme o projeto evolui com uma estrutura consistente, menos contexto manual é necessário no prompt**, porque o agente passa a inferir o padrão já estabelecido no próprio código/histórico do projeto. A contrapartida: um projeto mal estruturado desde o início tende a gerar mais "alucinação" do agente, exatamente porque não há padrão consistente para ele seguir — reforçando a importância de manter a disciplina de SDD desde a primeira feature.

### `/opsx:apply` com seleção explícita da change

```text
/opsx:apply change Kubernetes Database
```

Como havia várias changes abertas no projeto (de PRDs anteriores, ainda não arquivadas), o pedido precisou especificar qual change aplicar.

### Teste end-to-end real: custo de tempo e dinheiro

O teste end-to-end criou, na conta DigitalOcean real: um cluster Kubernetes, um banco de dados gerenciado, e Droplets adicionais — levando cerca de 20 minutos de execução. O instrutor é transparente: esse é o custo real de ter testes de integração genuínos contra serviços de cloud (criação e provisionamento de recursos gerenciados leva tempo de verdade) — mas reforça que é necessário para garantir o funcionamento correto do que foi construído.

### Bugs encontrados e corrigidos pelo próprio agente durante o teste

Durante a execução, o agente **detectou e corrigiu sozinho** um bug real: a suposição inicial de que os nós de um cluster Kubernetes (que são Droplets por debaixo dos panos) herdariam automaticamente a tag usada para limpeza (`inventario-droplets-testes` ou equivalente) se revelou incorreta — e o agente ajustou o fluxo de teste/limpeza para lidar com isso corretamente. O instrutor destaca esse ponto como demonstração prática de por que ter critérios de aceite bem definidos e rodar os testes de fato importa: só a execução real revelou esse comportamento inesperado da plataforma.

### Estrutura final de código

```text
src/mcp_server/tools/
├── droplets.py     (PRD 001 + 002)
├── kubernetes.py   (PRD 003)
└── database.py     (PRD 003)
```

As tools ficaram organizadas em **arquivos separados por domínio** (Droplets, Kubernetes, banco de dados) — reforçando novamente a boa prática de organização já vista no `AGENTS.md` do boilerplate (aula 05): cada domínio tem seu próprio módulo com uma função `register()`, chamada centralizadamente. Cada módulo de tool se conecta a sua respectiva função de acesso à DigitalOcean (via PyDO), incluindo a nova listagem de clusters Kubernetes.

### Fechamento do projeto: archive + sincronização

```text
Arquive e faça a sincronização de todas as changes.
```

Último passo da aula: com as três features implementadas e testadas, todas as changes do OpenSpec são arquivadas e sincronizadas de uma vez — consolidando o histórico de especificação do projeto completo, sem deixar changes "em aberto" penduradas.

### Gancho para a próxima aula

A aula termina apontando a pergunta natural seguinte: o MCP Server está implementado e testado, mas **como ele vai se comportar na prática, conectado a um agente real?** — isso é o que a próxima aula aborda, conectando o MCP construído a um agente LangChain.

## Comandos e configurações

```text
/build-mcp-server @docs/prds/003-consulta-de-kubernetes-e-bancos-gerenciados.md Crie o plano de ação, sem criar nada nesse momento. Depois de tudo especificado, crie o propose.
```

```text
# Respostas durante o plano de ação
Organização da change: uma change só, com as duas capabilities (Kubernetes e banco de dados).
Testes end-to-end na conta real: criar os recursos reais.
Estados na saída: enum, porque os estados são fixos.
```

```text
/opsx:apply change Kubernetes Database
```

```text
# Fechamento do projeto
Arquive e faça a sincronização de todas as changes.
```

## Pegadinhas

- Testes end-to-end que provisionam serviços gerenciados de cloud (cluster Kubernetes, banco de dados) são **lentos e custam dinheiro real** — cerca de 20 minutos na gravação; isso precisa ser considerado no planejamento de CI/CD ou de qualquer rotina que rode esses testes com frequência.
- Suposições sobre a plataforma de cloud (como "os nós do cluster herdam a tag do Droplet pai") podem se revelar falsas apenas ao rodar o teste de fato contra a API real — reforçando que testes de integração não são apenas uma formalidade, mas uma forma de descoberta.
- Quando há várias changes abertas simultaneamente no projeto, o comando de apply precisa identificar explicitamente qual change aplicar (por nome ou palavras-chave) para evitar ambiguidade.
- Conforme o projeto ganha consistência estrutural, menos instrução explícita é necessária a cada novo pedido — mas isso também significa que inconsistências implantadas no início do projeto se propagam mais facilmente para features futuras, já que o agente tende a replicar o padrão existente.

## Dúvidas para revisar

- Como esse MCP Server (já com as três features) se comportaria ao ser conectado a um agente LangChain real, tema da próxima aula — que ajustes, se algum, seriam necessários no lado do agente?
- Valeria a pena, num pipeline de CI real, separar os testes de unidade (rápidos) dos testes end-to-end (lentos e caros) em estágios distintos, rodando os end-to-end só em merges para a branch principal, por exemplo?
- Como ficaria a estrutura do projeto se um quarto PRD fosse adicionado (ex.: consulta de bancos de dados específicos ou de volumes/block storage) — o padrão de organização por domínio em `tools/` se sustentaria sem fricção?
