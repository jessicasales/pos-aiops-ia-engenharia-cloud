# Streamable HTTP na Prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 04 — MCP HTTP (07:44) |
| **Assunto** | Rodar o mesmo MCP de Kubernetes como servidor remoto via Streamable HTTP |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp` `streamable-http` `kubernetes` `claude-mcp` `escalabilidade` `/context` |

## Resumo da aula

Mesmo MCP de Kubernetes da aula anterior, agora rodando como **servidor HTTP** — centralizado, podendo atender várias ferramentas/pessoas da equipe ao mesmo tempo (uma sessão por cliente).

## Conceitos principais

### Subir o MCP server em modo HTTP
```bash
npx mcp-server-kubernetes \
  --enable-unsafe-streamable-http-transport \
  --port 3001 \
  # aceitando requisições de qualquer host
```
- `unsafe` porque está sem mecanismos de segurança adicionais nesse exemplo.
- Endpoint exposto: `http://localhost:3001/mcp`.

### Registrar no Claude Code
```bash
claude mcp add --transport http kubernetes http://localhost:3001/mcp
```
Diferença visível no `/mcp`: aparecem opções de **Reauthenticate**, **Clear Authentication**, **Reconnect**, **Disable** — mecanismos próprios de conexão remota (autenticação será aprofundada em aulas futuras).

### STDIO × HTTP — diferença prática
| | STDIO | HTTP |
|---|---|---|
| Processo | Subprocesso do cliente | Servidor independente, de longa duração |
| Se o servidor cai | Cai junto com o cliente | **Cliente perde a conexão**; precisa reconectar manualmente quando o servidor volta |
| Compartilhamento | Só o processo local | Vários clientes/pessoas, com sessão própria cada um |
| Preocupações extras | — | Escalabilidade, quantidade de requisições, segurança — "como qualquer aplicação web" |

Teste feito na aula: matar o processo do servidor HTTP no meio de uma chamada faz a requisição falhar; subindo o servidor de novo e pedindo para **reconectar**, volta a funcionar.

### `/context`
Mostra quanto as tools/ferramentas do MCP conectado estão ocupando da janela de contexto — mencionado como lembrete de que **cada MCP conectado tem custo de contexto**, reforçando a aula anterior.

## Prompt da aula

```text
liste os pods do meu cluster
```

## Pegadinhas
- Diferente do STDIO, um MCP HTTP que cai **não volta sozinho** — é preciso reconectar explicitamente no client.
- MCP de terceiros expostos via HTTP merecem atenção extra de segurança (superfície de ataque maior que um processo local).

## Dúvidas para revisar
- Avaliar se algum MCP interno (DPMG) faria mais sentido como serviço HTTP compartilhado pela equipe em vez de STDIO individual.
