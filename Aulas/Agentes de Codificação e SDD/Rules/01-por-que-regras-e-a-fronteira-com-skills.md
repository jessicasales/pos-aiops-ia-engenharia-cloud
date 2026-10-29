# Por que Regras e a Fronteira com Skills

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Rules |
| **Aula** | 01 — Por que Regras e a Fronteira com Skills (08:21) |
| **Assunto** | Diferença entre Skills (genéricas/reutilizáveis) e Rules (específicas do projeto) como componentes de harness |
| **Data** | 29/10/2026 17:10 |
| **Tags** | rules, skills, mcp, agents.md, cloud.md, harness |

## Resumo da aula

Aula de abertura do capítulo "Rules", que estabelece a fronteira conceitual entre os componentes de harness já estudados (MCP e Skills) e o novo conceito: **Rules**. O instrutor argumenta que nem MCP nem Skills são o lugar certo para armazenar as particularidades/regras específicas de um projeto — e é exatamente esse vazio que o conceito de Rules preenche, geralmente materializado em arquivos como `AGENTS.md` ou `CLAUDE.md`, ou em regras customizadas por diretório/arquivo.

## Conceitos principais

### Recapitulação: MCP vs. Skills

- **MCP**: ponte do agente para recursos externos que o modelo não acessa diretamente (ex.: Kubernetes, outros serviços). É sobre **ferramentas e acesso externo**.
- **Skills**: habilidades, base de conhecimento, guidelines e workflows — generalistas e genéricas, reaproveitáveis em diversos projetos (ex.: skill de boas práticas Python, skill de troubleshoot Kubernetes que consulta eventos e correlaciona causa raiz).

### O vazio: particularidades do projeto

Todo projeto tem particularidades que não cabem nem em MCP nem em Skills: uma pasta extra de documentação, uma estrutura ligeiramente diferente do boilerplate padrão, uma convenção específica daquele time. Essas definições:
- **Não devem ir na Skill**, porque a skill precisa continuar generalista/reutilizável entre projetos.
- **Não devem ir no MCP**, porque MCP serve para fornecer ferramentas, prompts armazenados e acesso a bases de dados — não regras de projeto.
- **Não devem ser repetidas manualmente em cada prompt/sessão**, porque isso não é eficiente e vai contra o próprio objetivo do Harness Engineering (calibrar o agente para não precisar reexplicar informações o tempo todo).

### Rules: o componente certo para isso

**Rules** são o recurso-chave de Harness Engineering para registrar as definições e regras específicas de um projeto. Costumam aparecer materializadas em:
- `AGENTS.md`
- `CLAUDE.md`
- Regras customizadas aplicadas a diretórios/arquivos específicos (uma terceira forma, baseada em estrutura de pastas, que será vista em aulas futuras do capítulo)

### Rules não substituem Skills

O instrutor deixa claro: Rules não eliminam a necessidade de Skills. Skills continuam valendo para workflows genéricos reaproveitáveis entre projetos. Rules (via `AGENTS.md`/`CLAUDE.md`) tendem a ter **menos reaproveitamento**, justamente porque são específicas de cada projeto — funcionam como o "ajuste fino de parafuso" quando se está trabalhando em um projeto particular.

## Comandos e configurações

Não há comandos executados nesta aula — é conteúdo conceitual introdutório do capítulo.

## Pegadinhas

- Tentar guardar regras específicas de projeto dentro de uma skill genérica compromete a reutilização dessa skill em outros projetos.
- Repetir manualmente as particularidades do projeto em cada prompt/sessão é ineficiente e contraria o propósito do harness bem calibrado.
- `AGENTS.md`/`CLAUDE.md` não são a única forma de aplicar rules — existe também uma abordagem baseada em estrutura de diretórios/arquivos específicos, a ser detalhada mais adiante no capítulo.

## Dúvidas para revisar

- Como ficaria a divisão exata de responsabilidades entre uma skill de "boas práticas Python" e um `AGENTS.md` que define convenções específicas do projeto Encontros Tech?
- Em um monorepo com múltiplas áreas/serviços, como as rules devem ser organizadas (tema de uma aula futura deste capítulo)?
- Vale a pena documentar explicitamente, no próprio `AGENTS.md`, quando uma regra deveria "evoluir" para se tornar uma skill compartilhada entre projetos?
