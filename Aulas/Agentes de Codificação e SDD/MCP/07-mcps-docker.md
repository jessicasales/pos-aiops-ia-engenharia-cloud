# MCP com Docker: Execução Agnóstica

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 07 — MCP's Docker (20:41) |
| **Assunto** | Rodar MCP servers em container Docker em vez de depender de Node/Python/Go instalados na máquina |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp` `docker` `stdio` `volume` `kubeconfig` `network-host` `hardening` |

## Resumo da aula

Problema: cada MCP server tem sua própria stack (Node, Python, Go...), exigindo que toda a equipe tenha as dependências corretas instaladas, além de riscos de acesso do processo à máquina. Solução: rodar o MCP server **dentro de um container Docker**, ganhando portabilidade e isolamento.

## Conceitos principais

### Pré-requisitos
- Docker instalado e rodando (`docker version`).
- Cluster Kubernetes local (Kind/Minikube) com contexto válido em `~/.kube/config`.
- Claude Code instalado e autenticado.
- Estar dentro de um projeto para usar `--scope project` (gera/edita `.mcp.json`).

### Imagem usada
`flux159/mcp-server-kubernetes:latest` — mas **fixe a versão** por tag (`:2.x`) ou digest (`@sha256:...`) em vez de `latest`, para garantir o mesmo binário em laptop, CI e servidor.

### Registrar o server no Claude Code (stdio via Docker)
```bash
claude mcp add k8s --scope project -- docker run -i --rm \
-v ~/.kube/config:/home/appuser/.kube/config:ro \
flux159/mcp-server-kubernetes:latest
```
- `-i`: obrigatório — sem ele o stdio não tem pipe.
- `--rm`: descarta o container ao encerrar.
- `-v ...:ro`: monta o kubeconfig **somente leitura** (o server não precisa alterar credenciais).
- `/home/appuser/...`: caminho interno esperado pela imagem (usuário `appuser` do Dockerfile).
- ⚠️ **Não esqueça `--scope project`** — sem ele, vai para o escopo padrão e pode não ser o esperado (foi o primeiro erro cometido ao vivo na aula).

### Os dois problemas reais enfrentados na demo (e por quê)
1. **Container isolado não enxerga o kubeconfig da máquina** — porque o container tem seu próprio filesystem. Solução: montar como **volume** (`-v ~/.kube/config:/home/appuser/.kube/config:ro`), usando **caminho absoluto** (o `.mcp.json` não expande `~`).
2. **`localhost` dentro do container não é o `localhost` da máquina** — ao tentar acessar o cluster Kind/Minikube (que também roda em container), a chamada caía no endereço errado. Solução: **`--network host`** (Linux) para ligar o container direto na rede da máquina — alternativa: trocar `server:` no kubeconfig para `host.docker.internal`. Cluster remoto (EKS/GKE/AKS) **não precisa** disso.

### `.mcp.json` final (reconstituído)
```json
{
  "mcpServers": {
    "k8s": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "--network", "host",
        "-v", "/Users/SEU_USUARIO/.kube/config:/home/appuser/.kube/config:ro",
        "flux159/mcp-server-kubernetes:latest"
      ]
    }
  }
}
```

### Variante HTTP (em container)
```bash
docker run --rm -p 3001:3001 \
  -e ENABLE_UNSAFE_STREAMABLE_HTTP_TRANSPORT=1 \
  -e PORT=3001 -e HOST=0.0.0.0 \
  -v ~/.kube/config:/home/appuser/.kube/config:ro \
  flux159/mcp-server-kubernetes:latest
```
- Sem `-i` (não é stdio).
- `HOST=0.0.0.0`: essencial — sem isso a porta publicada não responde.
```bash
claude mcp add --transport http k8s-http http://localhost:3001/mcp
```
**Desafio proposto pela aula**: repetir esse fluxo HTTP de ponta a ponta.

## Troubleshooting (tabela da aula)
| Sintoma | Causa | Correção |
|---|---|---|
| Server no escopo errado / não aparece | Esqueceu `--scope project`/`user` | Refazer com `--scope`; conferir com `claude mcp list` |
| `connection refused` em `localhost:8080` | Kubeconfig não montado | Adicionar `-v ~/.kube/config:...:ro` |
| `connection refused` no endpoint correto | Rede do container isolada do Kind/Minikube | `--network host` ou `host.docker.internal` |
| `.mcp.json` não encontra o kubeconfig | Caminho usa `~` (não expande) | Usar caminho absoluto |
| `claude mcp add` monta args errados ao editar o JSON na mão | JSON sensível a vírgulas/flags separadas | Gerar via `claude mcp add ... -- docker run ...` e só então ajustar o `.mcp.json` |
| Container nem inicializa | Comando malformado (flag colada) | Revisar separação de cada flag; testar `docker run` isolado antes |
| HTTP publica porta mas não responde | Faltou `HOST=0.0.0.0` | Adicionar junto com `-p` |

## Cheatsheet de hardening
| Flag / prática | Para quê |
|---|---|
| `--rm` | Sem estado residual |
| `:ro` no kubeconfig | Server não altera credenciais |
| `--read-only` | Filesystem do container imutável |
| `--cap-drop=ALL` | Remove capabilities do Linux |
| `--security-opt=no-new-privileges` | Impede escalonamento de privilégios |
| `--memory` / `--cpus` | Limita blast radius de runaway |
| `-e` / `--env-file` | Segredos sem embutir na imagem/histórico |
| Pin de tag/digest | Mesmo binário em todo lugar |
| RBAC restrito | ServiceAccount de leitura, nunca admin |
| Montar só o necessário | Menos volumes = menos exposição |

```bash
# Exemplo com privilégio mínimo
docker run --rm -i \
  --read-only \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  --memory=256m --cpus=0.5 \
  -v /Users/SEU_USUARIO/.kube/config:/home/appuser/.kube/config:ro \
  flux159/mcp-server-kubernetes:latest
```

## Pegadinhas
- Editar o `.mcp.json` à mão é propenso a erro de formatação (vírgulas, flags coladas) — prefira gerar via `claude mcp add` e só então ajustar.
- Lembrar de remover entradas de escopo antigas (`user`/`local`) que ficam "fantasmas" sobrescrevendo o que você acabou de configurar no `project`.

## Links
- Repositório do server: https://github.com/Flux159/mcp-server-kubernetes
- Referência do `docker run`: https://docs.docker.com/reference/cli/docker/container/run/

## Dúvidas para revisar
- Aplicar o cheatsheet de hardening nos MCPs que eu já uso ou vou plugar no trabalho.
- Fazer o desafio: rodar a variante HTTP em container de ponta a ponta.
