# MCP Inspector — testar e debugar MCP Servers

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 05 — MCP Inspector (06:13) |
| **Assunto** | Testar um MCP Server diretamente, sem precisar de um agente de IA no meio |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp-inspector` `debug` `teste` `stdio` `http` `resources` `tools` `prompts` |

## Resumo da aula

Quando você está **desenvolvendo** ou **validando** um MCP Server, é útil testar direto, sem o modelo/agente como intermediário. Ferramenta: **MCP Inspector**, compatível com STDIO e HTTP.

## Conceitos principais

### Subir o Inspector
```bash
npx @modelcontextprotocol/inspector <comando-de-inicialização-do-mcp>
# ex.: npx @modelcontextprotocol/inspector npx mcp-server-kubernetes
```
Requer Node instalado. Abre uma interface onde você escolhe o transporte (STDIO ou Streamable HTTP) e clica em **Connect**.

### O que o Inspector mostra
- **Resources** — recursos disponibilizados pelo MCP (no caso do Kubernetes, dados do cluster).
- **Prompts** — se o MCP expuser prompts prontos.
- **Tools** — lista de ferramentas (`list tools`); cada uma pode ser executada diretamente informando os parâmetros pedidos (ex. `kubectl get` com o tipo de recurso; `get node` pedindo o nome do node; pegar logs de um pod específico).

### Fluxo de teste
1. Conectar.
2. Listar tools disponíveis.
3. Clicar numa tool → preencher parâmetros pedidos → executar → ver a resposta direto, sem o agente interpretando.

### HTTP no Inspector
Mesma lógica: conectar no endpoint HTTP do MCP; se o servidor cair, a conexão falha e é preciso reconectar manualmente, igual ao visto com o Claude Code.

## Pegadinhas
- Útil tanto para **debugar** um MCP com problema quanto para **validar antes de colocar em produção** — teste "cru" sem a camada de interpretação do agente.

## Dúvidas para revisar
- Usar o Inspector antes de plugar qualquer MCP novo em produção, para confirmar que as tools fazem o que dizem fazer.
