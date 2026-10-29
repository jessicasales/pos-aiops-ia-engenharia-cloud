# MCP STDIO na Prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 03 — MCP STDIO (21:18) |
| **Assunto** | Configurar e usar o MCP Server de Kubernetes via STDIO no Claude Code |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp` `stdio` `kubernetes` `kubeconfig` `claude-mcp` `escopo` `kind` |

## Resumo da aula

Primeira prática com MCP: conectar o Claude Code a um **MCP Server de Kubernetes** (`mcp-server-kubernetes`, projeto Node.js) via **STDIO**, rodando localmente, usando o `kubeconfig` da máquina.

## Conceitos principais

### Por que STDIO aqui
O MCP roda como **subprocesso** do Claude Code: comunicação via stdin (requisição) / stdout (resposta) / stderr (logs). Não tem URL nem autenticação separada — ele herda o acesso do `kubeconfig` local. Bom para ambiente local/pessoal (menos trabalho de configurar credenciais); em produção/equipe, o recomendado é um MCP com **service account** e token dedicado (tema de aula futura).

### Passo a passo
1. Criar um cluster local (`kind`, ou `k3d`) e aplicar os manifests do projeto.
2. Testar o MCP server isoladamente: `npx mcp-server-kubernetes` — ele inicia e fica **esperando o MCP Client** se conectar; sozinho não faz nada além disso.
3. Registrar no Claude Code:
   ```bash
   claude mcp list              # lista MCPs configurados (local/global)
   claude mcp add --scope project kubernetes -- npx mcp-server-kubernetes
   ```

### Escopos de configuração (Claude Code)
| Escopo | Onde fica | Efeito |
|---|---|---|
| **local** (default) | `.claude/settings.local.json` | Só na sua máquina, só nesse projeto |
| **project** | `.mcp.json` na raiz do projeto | Compartilhável com a equipe (vai pro Git) |
| **user** | `~/.claude.json` | Disponível em **todos os projetos** desse usuário |

```json
// .mcp.json gerado
{
  "mcpServers": {
    "kubernetes": {
      "type": "stdio",
      "command": "npx mcp-server-kubernetes"
    }
  }
}
```

### Uso
Dentro do Claude Code: `/mcp` lista e gerencia os servers conectados. Ao iniciar, ele detecta o MCP configurado no projeto e pergunta se quer habilitar.

## Prompts da aula

```text
liste as nodes do meu cluster Kubernetes
```
```text
liste os pods do meu cluster
```
```text
delete o deployment da nossa aplicação
```

## Pegadinhas
- **STDIO = processo filho do cliente**: se você fechar o Claude Code (ou o terminal), o MCP server morre junto. Cada agente que você abrir cria seu **próprio subprocesso** — não dá para compartilhar entre ferramentas/pessoas dessa forma.
- **STDIO não é controle de permissão.** O nível de acesso do MCP é o do `kubeconfig` usado — se o kubeconfig tem acesso de admin, o agente pode **deletar o deployment de produção** se você pedir (testado na aula: `delete o deployment da nossa aplicação` de fato deletou). Separe sempre **segurança do transporte** de **nível de acesso da credencial**.
- Use STDIO principalmente quando: está desenvolvendo/testando um MCP, quer uso **exclusivamente local**, ou o MCP **não tem mecanismo de autenticação** próprio (o isolamento do processo vira a camada de segurança).

## Dúvidas para revisar
- Qual kubeconfig/role eu uso quando ligar um MCP de Kubernetes nos clusters do trabalho — nunca usar um com privilégio de admin à toa.
