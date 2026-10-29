# Introdução — MCP, a "porta USB" da IA

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 01 — Introdução (16:56) |
| **Assunto** | O que é o Model Context Protocol, por que existe e como funciona por baixo dos panos |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp` `model-context-protocol` `tools` `host` `client` `server` `stdio` `streamable-http` `json-rpc` |

## Resumo da aula

Até aqui o agente ficou **preso à máquina local** (arquivos, terminal, comandos como `kubectl`). Para alcançar recursos externos (Kubernetes, Prometheus, GitHub, Notion...) sem depender de terminal — como fazem os **agentes autônomos**, que não têm acesso a terminal — entra o **MCP (Model Context Protocol)**.

## Conceitos principais

### O problema que o MCP resolve
Antes do MCP, cada framework/tecnologia implementava "tools" (ferramentas) do seu próprio jeito — LangChain Python ≠ LangChain TypeScript ≠ SDK ≠ N8N. Para o mesmo recurso externo, era preciso reimplementar a integração em cada ferramenta.

**MCP = protocolo aberto que padroniza como a IA recebe contexto de ferramentas e chama recursos externos.** Criado pela Anthropic, hoje tem **governança aberta na Linux Foundation**, com adoção de Anthropic, OpenAI, Google, Microsoft e mais de **10 mil MCP servers** disponíveis.

### Analogia: a USB da IA
A porta MCP no agente é como a porta USB do computador — você "pluga" qualquer dispositivo (serviço externo): Kubernetes, GitHub, Prometheus, Notion, gerenciador de tarefas etc.

### Os três componentes
| Componente | Papel |
|---|---|
| **Host** | A aplicação de IA que você usa (Claude Code, Antigravity...) |
| **Client MCP** | Faz a ponte de comunicação entre o host e o servidor MCP |
| **MCP Server** | Faz a comunicação de fato com o recurso/serviço externo |

O **MCP** é o protocolo de comunicação entre client e server — a padronização em si.

### O que um MCP pode fornecer (não é só "tool")
1. **Tools (ferramentas)** — a ação que o agente executa no mundo externo.
2. **Resources (recursos/dados)** — arquivos, dados de banco de dados etc.
3. **Prompts** — um repositório de prompts pode virar um MCP Server, evitando copiar e colar prompts manualmente.

### Como funciona por baixo dos panos
- Usa **JSON-RPC 2.0** como protocolo de comunicação.
- O MCP server expõe a **lista de recursos** e a forma de chamá-los.
- A descoberta é **dinâmica**: ao plugar um MCP, o agente lê todos os recursos disponíveis — isso **ocupa a janela de contexto**, então não adianta plugar MCPs "à toa" (tema aprofundado na próxima aula).

### Duas formas de comunicação
| Transporte | Quando usar |
|---|---|
| **STDIO** | Comunicação local via terminal (stdin) — MCP **dedicado** ao seu agente local, rodando na mesma máquina |
| **Streamable HTTP** | Comunicação remota via chamada HTTP (JSON-RPC) — para **disponibilizar o MCP para vários agentes/membros da equipe** |

### MCP no Harness
O MCP entra no loop de execução do agente junto com as ferramentas nativas (read, write, edit, bash) — é mais uma fonte de "tools" que o agente pode decidir usar.

## Pegadinhas
- MCP não "acessa" o recurso externo sozinho — é a **ferramenta/server** que implementa o protocolo quem faz essa comunicação de fato.
- Plugar muitos MCPs de uma vez polui a janela de contexto desnecessariamente (descoberta dinâmica carrega tudo).

## Dúvidas para revisar
- Mapear quais sistemas internos (DPMG: Kubernetes, GitLab, Moodle etc.) fariam sentido virar/usar um MCP Server.
