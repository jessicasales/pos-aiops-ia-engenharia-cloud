# Ferramentas e Capacidades Publicadas

Capítulo do módulo **Construção de Agentes e Fundamentos de AIOps** — Pós AIOps e IA na Engenharia de Cloud.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução às Ferramentas](01-introducao-as-ferramentas.md) | 13:38 | Tipos de ferramenta (informação, extensão de capacidade, ação) e natureza (leitura, escrita reversível/irreversível); blast radius |
| 02 | [Anatomia da Ferramenta](02-anatomia-da-ferramenta.md) | 38:53 | `@tool`, `parse_docstring`, Pydantic/`args_schema`, ciclo de tool calling — projeto de inventário de Droplets (DigitalOcean) |
| 03 | [Testando a Ferramenta](03-testando-a-ferramenta.md) | 19:06 | Testes de unidade (esquema) e integração (conta real) gerados por IA em Plan Mode, com pytest |
| 04 | [Ferramenta Pronta: Avaliar Antes de Adotar](04-ferramenta-pronta-avaliar-antes-de-adotar.md) | 15:27 | `TavilySearch`, ferramentas prontas do catálogo LangChain, cuidados de segurança |
| 05 | [Construção de MCP Server com Agent Skills](05-construcao-de-mcp-server-com-agent-skills.md) | 12:39 | Boilerplate FastMCP + OpenSpec + skill `build-mcp-server`; os 3 PRDs do MCP de DigitalOcean |
| 06 | [Consulta de Droplets e Paginação](06-consulta-de-droplets-e-paginacao.md) | 20:37 | Implementação do PRD 001 — análise, perguntas da skill, `/opsx:apply`, testes end-to-end |
| 07 | [Controle de Energia e Ação Assíncrona](07-controle-de-energia-e-acao-assincrona.md) | 08:27 | Implementação do PRD 002 — `destructive_hint`, ação assíncrona, correção de timing nos testes |
| 08 | [Listagem do K8S e Banco de Dados](08-listagem-do-k8s-e-banco-de-dados.md) | 15:21 | Implementação do PRD 003 — uma change com duas capabilities, testes reais (~20 min), archive/sync |
| 09 | [Agente LangChain Consumindo MCP via HTTP](09-agente-langchain-consumindo-mcp-via-http.md) | 21:18 | MCP Inspector, migração de tool LangChain para `MCPAdapter`, encadeamento autônomo de tools |
