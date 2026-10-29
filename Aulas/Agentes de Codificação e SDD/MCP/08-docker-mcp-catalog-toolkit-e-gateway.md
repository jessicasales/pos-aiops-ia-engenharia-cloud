# Docker MCP Catalog, Toolkit e Gateway

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 08 — Docker MCP Catalog, Toolkit e Gateway (12:09) |
| **Assunto** | Agrupar vários MCPs num profile e expor via um único Gateway, usando Docker Desktop |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `docker-desktop` `mcp-gateway` `mcp-toolkit` `mcp-catalog` `profile` `github` `kubernetes` `allowlist` |

## Resumo da aula

Com vários MCP servers (Kubernetes, GitHub, Prometheus, Zabbix...), gerenciar a conexão de cada um em cada cliente (Claude Code, Codex, Antigravity...) vira trabalho repetido. O **MCP Gateway** do Docker resolve isso: cria **profiles** (perfis) que agrupam vários MCP servers, e o cliente aponta para **um único endpoint** (o gateway), que multiplexa tudo.

## Conceitos principais

### As três peças
| Peça | Papel |
|---|---|
| **Catalog** | De onde vêm os servers, com proveniência (imagem verificada, versão e origem conhecidas) — mesmo catálogo do Docker Hub |
| **Toolkit** | Como gerenciar e guardar segredo (UI/CLI de configuração) |
| **Gateway** | Um endpoint só para o cliente — multiplexa vários servers |

### Pré-requisitos importantes
- **Docker Desktop** (não funciona só com Docker Engine — comum em Linux "puro"; existe Docker Desktop para Linux também).
- Cluster Kubernetes **remoto** (não local em container) — o Gateway roda num container que não enxerga um cluster Kind/Minikube rodando em outro container na mesma máquina. Se o cluster for local, prefira a execução direta (`docker run`, aula anterior).
- Conta GitHub com permissão para Fine-grained PAT (ou OAuth).

### Fluxo (UI do Docker Desktop, com CLI equivalente)
1. **Ligar profiles e olhar o Catalog**: `docker mcp feature enable profiles`; `docker mcp catalog ls`; `docker mcp catalog server inspect docker/mcp github`. Fixar versão por tag/digest, nunca `latest` mutável.
2. **Criar o profile** com a dupla do capítulo: `docker mcp profile create --name aiops --server kubernetes --server github`. Escolher também o **client** (Claude Code) — o Docker já configura o cliente sozinho.
3. **Kubernetes em modo não-destrutivo**: apontar o `kubeconfig` e travar com `ALLOW_ONLY_NON_DESTRUCTIVE_TOOLS=true` (só `get`/`describe`/`logs`; bloqueia `create`/`apply`/`delete`/`scale`). Conferir antes `kubectl config current-context` — o blast radius é o RBAC do contexto ativo.
4. **GitHub com escopo mínimo**: preferir **OAuth** localmente (abre browser, autoriza); se usar PAT, gerar **Fine-grained PAT** só no repo necessário, com `Contents/Issues/Pull requests = Read`. Enxugar toolsets: `GITHUB_TOOLSETS=issues,pull_requests` + `GITHUB_READ_ONLY=1`. Segredo nunca no `.mcp.json`/histórico — `docker mcp secret set github.token`.
5. **Subir o gateway e conectar**: `docker mcp gateway run --profile aiops`; `docker mcp client connect claude-code --profile aiops` — escreve a config do cliente sozinho, sem precisar de `claude mcp add` server por server.
6. **Provar que as tools chegam juntas**: `claude mcp list` mostra o gateway como **"MCP Docker"** — um único server do ponto de vista do Claude Code, mesmo multiplexando vários atrás.
7. **Allowlist de tools**: `docker mcp profile tools aiops --disable-all github` + `--enable github.list_issues --enable github.get_issue` — liga só o necessário, central no profile (vale para todo cliente conectado).

### Tabela de env/secret por server (exemplo da aula)
| Server | Chave | Valor/origem | Efeito |
|---|---|---|---|
| Kubernetes | `KUBECONFIG` | `~/.kube/config` (cluster remoto) | Aponta o cluster |
| Kubernetes | `ALLOW_ONLY_NON_DESTRUCTIVE_TOOLS` | `true` | Só leitura/diagnóstico |
| GitHub | `github.token` | Fine-grained PAT ou OAuth | Credencial fora do arquivo/histórico |
| GitHub | `GITHUB_TOOLSETS` | `issues,pull_requests` | Enxuga toolsets |
| GitHub | `GITHUB_READ_ONLY` | `1` | Só leitura no GitHub |

### Governança: catálogo próprio da organização
Em vez de cada dev instalar o que quiser, a empresa pode homologar uma **lista permitida de servers** num catálogo OCI próprio:
```bash
docker mcp catalog create <ref> --from-profile aiops   # cria a partir de um profile validado
docker mcp catalog push <oci-ref>                       # publica (registry OCI)
docker mcp catalog pull <oci-ref>                        # outra máquina consome o catálogo da org
```
⚠️ Vários comandos desta aula (profile, secret, oauth, client, catalog push/pull) são **marcados "a verificar"** no material — confirme com `docker mcp <comando> --help` antes de depender deles em automação.

### Quando usar Gateway × `docker run` direto
| Cenário | Use | Por quê |
|---|---|---|
| Um server, uma máquina | `docker run` direto (aula 07) | Gateway é overhead desnecessário |
| Vários servers e/ou pessoas/clientes | **Gateway** | Config única, governança de catálogo, secret centralizado, allowlist por profile |
| Precisa de hardening do server | — | O Gateway **organiza, não blinda**: `:ro`, RBAC reduzido, mínimo privilégio continuam valendo |

## Prompts da aula

```text
list os pods do meu cluster
```
```text
verifique as issues abertas no repositório do projeto
```

## Pegadinhas
- **Conflito de tools**: se o MCP registrado direto no cliente (ex. `k8s` da aula 07) e o do Gateway (`MCP Docker`) estiverem ativos juntos, o agente pode escolher a ferramenta errada — remova o duplicado, deixando só o do Gateway, e reabra a sessão.
- Projeto de teste precisa ser um **fork** do repositório para o MCP de GitHub ter o que consultar.

## Links
- Docker MCP Catalog e Toolkit (docs): https://docs.docker.com/ai/mcp-catalog-and-toolkit/
- Docker MCP Gateway (docs): https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/
- Docker MCP Gateway (repo + CLI): https://github.com/docker/mcp-gateway
- GitHub MCP Server (oficial): https://github.com/github/github-mcp-server
- Repositório do projeto: https://github.com/KubeDev/encontros-tech

## Dúvidas para revisar
- Testar se o Docker Desktop para Linux funciona bem no meu ambiente de trabalho para montar um profile `aiops`.
- Validar os comandos marcados "a verificar" contra a CLI real antes de usar em automação.
