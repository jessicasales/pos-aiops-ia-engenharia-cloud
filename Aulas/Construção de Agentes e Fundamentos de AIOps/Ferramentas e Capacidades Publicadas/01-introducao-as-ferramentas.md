# Introdução às Ferramentas

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 01 — Introdução às Ferramentas (13:38) |
| **Assunto** | Taxonomia conceitual das ferramentas de um agente — tipos (obtenção de informação, extensão de capacidade, ação) e natureza (leitura, escrita reversível, escrita irreversível) — e o conceito de blast radius |
| **Data** | 30/10/2026 01:15 |
| **Tags** | tools, tipos-de-ferramenta, natureza-da-ferramenta, blast-radius, harness, mcp, langchain-tools |

## Resumo da aula

Aula de abertura do novo capítulo, puramente conceitual (sem código). Depois de uma visão macro das ferramentas no capítulo anterior, o instrutor aprofunda a taxonomia: por que ferramentas são essenciais para estender os recursos de um agente além do conhecimento do modelo, os três **tipos** de ferramenta (obtenção de informação, extensão de capacidade, ação sobre ambiente), e a **natureza** de cada ferramenta (leitura, escrita reversível, escrita irreversível) — introduzindo o conceito de **blast radius**, central para quem trabalha com agentes de infraestrutura/AIOps. Fecha anunciando que o capítulo vai cobrir duas abordagens de implementação: tools nativas do LangChain e MCP Servers próprios.

## Conceitos principais

### Por que ferramentas são essenciais

Um agente conectado apenas a um LLM está restrito ao conhecimento que o modelo teve em seu treinamento/base de dados. A ferramenta (tool) é o principal recurso para conectar o agente a recursos externos, de forma geral — e isso vai muito além de apenas "obter mais dados": é o próprio Harness do agente, o mesmo papel que as ferramentas desempenham em agentes de codificação (Claude Code, Codex).

### Tipo 1 — Ferramentas de obtenção de informação (enriquecimento de contexto)

Ferramentas que ampliam o conhecimento do agente conectando-o a fontes externas: listar um documento, obter métricas de infraestrutura, acessar logs de uma máquina ou aplicação. O instrutor ressalva que esse não é o único mecanismo de enriquecimento de contexto — RAG e memória de longo prazo (temas de aulas futuras) também cumprem esse papel —, mas a ferramenta é um recurso essencial dentro desse tipo.

### Tipo 2 — Ferramentas de extensão de capacidade (tarefas determinísticas)

Para tarefas que são inerentemente determinísticas — por exemplo, calcular P95/P50 em dados de observabilidade, fazer conversões ou períodos de dados — usar o LLM para "raciocinar" sobre esse cálculo é mau uso de recurso: gasta tokens de reasoning e de output para fazer algo que um script simples resolveria com mais acerto e menor custo. Ferramentas de extensão de capacidade entregam ao agente a possibilidade de executar essas operações via código determinístico (script, Python, bash), com:
- **Custo muito menor** (não consome tokens do LLM para o cálculo em si).
- **Assertividade muito maior** (testável, sempre correto, sem risco de alucinação).

Esse tipo de ferramenta está diretamente relacionado ao conceito de **workflow** (automação determinística) já visto em aulas anteriores do curso — a ferramenta é o ponto onde o agente "terceiriza" a parte determinística da tarefa.

### Tipo 3 — Ferramentas de ação sobre ambiente/serviço externo

Ferramentas que não obtêm informação nem enriquecem contexto — elas **executam uma ação** que altera o estado de um ambiente ou serviço externo: conectar a uma API externa, executar uma operação na infraestrutura, acionar um serviço de um fornecedor. É o ponto de comunicação do agente com o mundo externo, no sentido de **causar efeito**, não apenas consultar.

### Natureza da ferramenta — o eixo complementar aos tipos

Independente do tipo, toda ferramenta também tem uma **natureza**, relacionada ao efeito que sua execução causa no ambiente:

- **Leitura**: não altera o estado de nada — ex.: listar droplets, listar instâncias EC2, listar componentes. Impacto no ambiente externo é zero, pois só consome informação.
- **Escrita reversível**: altera o estado de um elemento da infraestrutura/ambiente/serviço, mas essa alteração pode ser desfeita (como um "Ctrl Z") — ex.: adicionar/remover uma tag, fazer um deploy e depois um rollback.
- **Escrita irreversível**: altera o estado do ambiente/serviço **sem possibilidade de reversão** — ex.: destruir uma instância EC2 ou um droplet. Uma vez destruída a máquina, não há como voltar atrás; o máximo possível é recriar algo semelhante (via infraestrutura como código), nunca reverter literalmente a ação.

### Blast radius — o conceito central para agentes de infraestrutura/AIOps

**Blast radius** é o alcance (escala/impacto) que a execução de uma operação pode causar em um determinado ambiente. Entender o tipo e a natureza de cada ferramenta ajuda a antecipar o blast radius de cada ação do agente: por exemplo, excluir uma máquina virtual tem um blast radius que depende de quantas aplicações rodam ali; excluir um cluster Kubernetes tem um blast radius ainda maior. O instrutor enfatiza que, embora isso possa parecer óbvio, é essencial — especialmente ao projetar agentes que operam sobre infraestrutura real — mapear corretamente tipo + natureza de cada ferramenta antes de conceder a ela acesso ao agente.

### As duas abordagens de implementação a seguir no capítulo

O capítulo vai demonstrar ferramentas implementadas de duas formas:
1. **Nativamente com LangChain** — útil porque, trabalhando com LangChain, o desenvolvedor inevitavelmente terá contato com ferramentas nativas do framework e precisará dar suporte a esse padrão; em certos casos, faz sentido criar ferramentas específicas diretamente em LangChain.
2. **Via MCP (Model Context Protocol)**, criando MCP Servers próprios — abordagem já reconhecida no curso como essencial para ganhar portabilidade das ferramentas entre diferentes agentes/plataformas, e alinhada aos padrões de mercado no uso de IA em empresas.

## Comandos e configurações

Aula puramente conceitual — sem código, comandos ou "Código da Aula" nesta lição.

## Pegadinhas

- Usar o LLM/agente para executar cálculos ou transformações puramente determinísticas (ex.: P95/P50, conversões) é desperdício de tokens e introduz risco de alucinação onde um script simples seria sempre correto — esse tipo de tarefa pertence a uma ferramenta de extensão de capacidade, não ao "raciocínio" do modelo.
- Confundir "escrita reversível" com "sem risco" é um erro: mesmo uma escrita reversível altera o estado real de um ambiente até que a reversão seja executada — o cuidado operacional não desaparece, só a chance de recuperação aumenta.
- Uma escrita irreversível (ex.: destruir uma instância ou droplet) não tem "desfazer": o máximo que se pode fazer depois é recriar algo parecido via IaC, nunca reverter literalmente a ação já executada — isso deve pesar diretamente em qualquer decisão de dar esse tipo de ferramenta a um agente autônomo.

## Dúvidas para revisar

- Como documentar, num TRD/ADR, o blast radius esperado de cada ferramenta antes de conceder acesso a um agente de infraestrutura/AIOps?
- Quais critérios usar para decidir se uma ferramenta de escrita irreversível deve exigir confirmação humana explícita antes da execução pelo agente?
- Na prática do capítulo, como vai ficar a escolha entre implementar uma ferramenta nativamente em LangChain versus publicá-la como MCP Server, caso ambas as abordagens sirvam para o mesmo caso de uso?
