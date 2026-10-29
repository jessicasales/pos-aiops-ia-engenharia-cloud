# Escopo de Configuração e Credenciais dos MCP Servers

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 06 — Escopo de Configuração de Credenciais (23:17) |
| **Assunto** | Os três escopos de MCP (local/project/user) e como manter credenciais fora do repositório com variáveis |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp` `escopo` `claude-mcp` `credenciais` `context7` `variáveis-de-ambiente` `.mcp.json` `segurança` |

## Resumo da aula

Dois temas centrais do Harness: **quem enxerga** um MCP (escopo) e **como não vazar credenciais** ao configurá-lo (variáveis de ambiente).

## Conceitos principais

### Os três escopos (referência rápida)
| Escopo | Onde mora | Quem enxerga | Quando usar | Flag |
|---|---|---|---|---|
| **local** (padrão) | `~/.claude.json`, atrelado ao caminho do projeto | Só você, só neste projeto | Experimentar server novo; credencial pessoal que não pode vazar | nenhuma (default) ou `--scope local` |
| **project** | `.mcp.json` na raiz do repo (versionável) | Todo o time que clona o repo | Server que o time inteiro usa no mesmo alvo | `--scope project` |
| **user** (global) | `~/.claude.json` (settings globais) | Só você, em qualquer pasta da máquina | Utilitário pessoal sempre à mão (ex.: Context7) | `--scope user` |

**Precedência: `local` > `project` > `user`** (mais específico vence). Se um server "não atualiza" mesmo depois de reconfigurado no `project`, quase sempre é uma entrada `local` esquecida ganhando — use `claude mcp get <nome>` para revelar de qual escopo está vindo.

### Comandos
```bash
# local (padrão): privado a você, só neste projeto
claude mcp add k8s -- npx mcp-server-kubernetes

# project: cria/edita o .mcp.json na raiz do repo (versionável, time herda)
claude mcp add --scope project k8s -- npx mcp-server-kubernetes

# user (global): vale em qualquer pasta da máquina, só pra você
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

# project + HTTP + header com a API key (Context7 via HTTP)
claude mcp add --scope project \
  --header "CONTEXT7_API_KEY: YOUR_API_KEY" \
  --transport http context7 https://mcp.context7.com/mcp
```
Anatomia: as flags (`--scope`, `--header`, `--transport`, `--env`) vêm **antes** do nome do server; o `--` separa o comando que o agente vai disparar.

### Inspeção
```bash
claude mcp list                     # todos os servers ativos + status
claude mcp get k8s                  # detalha um server: origem (escopo) e comando
claude mcp reset-project-choices    # reseta as aprovações de servers do .mcp.json
```
Dentro da sessão: `/mcp` mostra status + contagem de tools de cada um, e pede **aprovação na primeira vez** que um server vindo do `.mcp.json` (project) é usado — repo de terceiro não liga server sem seu ok.

### Credenciais com `${VAR}` — nunca hardcode
Sintaxe:
```text
${VAR}            # usa o valor da variável de ambiente VAR
${VAR:-default}   # usa VAR; se não existir, cai no default
```
Vale em `command`, `args`, `env`, `url` e `headers` do `.mcp.json`. O arquivo guarda a **referência**, nunca o segredo.

```json
// .mcp.json — server HTTP (Context7) com variável no header
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": { "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}" }
    }
  }
}
```
Outros exemplos de `env`:
```json
"env": {
  "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PAT}",
  "KUBECONFIG": "${KUBECONFIG}"
}
```

Passo a passo:
1. Referenciar no arquivo (`${CONTEXT7_API_KEY}` em vez do valor cru).
2. Prover o segredo no ambiente, **fora do repo** (`export CONTEXT7_API_KEY=ctx7_xxxx`; na vida real: shell, `.env` não-versionado, ou secret manager).
3. Validar que resolve: `claude mcp list`.
4. Prova anti-vazamento antes de commitar: `grep -E "ctx7_|TOKEN=|secret" .mcp.json` — não deve retornar nada.

**Regra de bolso:** estrutura do server → versionada (project); segredo → ambiente (`${VAR}`); experimento isolado → local.

### MCP de exemplo: Context7
Agrupa documentação de bibliotecas/serviços (Next.js, Supabase, React, Kubernetes, Istio...) para o agente consultar em vez de alucinar.
- Conta via GitHub → gerar API Key (formato `ctx7_...`) no perfil.
- Camada free: ~1000 requests (⚠️ a transcrição não confirma se é por dia).
- Setup HTTP: `claude mcp add --scope project --header "CONTEXT7_API_KEY: YOUR_API_KEY" --transport http context7 https://mcp.context7.com/mcp`
- Setup stdio (user): `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp`
- Teste: "consulte a documentação do Kubernetes e me mostre como usar o Service" — o agente deve chamar o context7.

## Links
- Claude Code — MCP configuration: https://code.claude.com/docs/en/mcp
- Claude Code — Settings e escopos: https://code.claude.com/docs/en/settings
- Model Context Protocol (site oficial): https://modelcontextprotocol.io/
- Context7 (endpoint HTTP): https://mcp.context7.com/mcp · pacote npm: `@upstash/context7-mcp`

## Pegadinhas
- Mesmo nome de server em escopos diferentes: o **mais específico** (local) sobrescreve, mesmo que você já tenha "corrigido" no `project` — sempre confira com `claude mcp get`.
- Nunca commitar chave em texto puro — sempre validar com grep antes do commit.

## Dúvidas para revisar
- Levantar quais MCPs do meu dia a dia (GitHub, Kubernetes interno) deveriam ser `project` (time) × `user` (só eu) × `local` (experimento).
