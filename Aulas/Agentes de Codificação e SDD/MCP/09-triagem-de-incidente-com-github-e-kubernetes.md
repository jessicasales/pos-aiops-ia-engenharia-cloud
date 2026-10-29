# Triagem de Incidente com GitHub e Kubernetes

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 09 — Triagem de Incidente com GitHub e Kubernetes (20:36) |
| **Assunto** | Fluxo ponta a ponta: issue no GitHub → investigação no cluster → correção → fechamento da issue, usando múltiplos MCPs juntos |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `aiops` `triagem` `incidente` `github-mcp` `kubernetes-mcp` `pat` `fine-grained-token` `loop-de-execução` |

## Resumo da aula

Capstone do capítulo: combinar o **MCP de Kubernetes** (via Docker Gateway) com o **MCP do GitHub** para um fluxo real de **AIOps**: usuário abre uma issue reportando "aplicação fora do ar" → o agente lê a issue, investiga o cluster, corrige, e fecha a issue documentando causa raiz e correção — tudo no mesmo loop de execução, sem intervenção manual passo a passo.

## Conceitos principais

### Por que trocar OAuth por Personal Access Token aqui
A autenticação **OAuth** usada nas aulas anteriores dá um nível de permissão baixo (majoritariamente leitura). Para esse cenário — criar/ler/comentar/fechar issues — é preciso um escopo maior: **Fine-grained PAT**.

### Criando o Fine-grained PAT
GitHub → foto do perfil → **Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens → Generate new token**.
- Nome livre (ex. "aula"); expiração curta para teste (7 dias — ajustar para produção).
- **Repository access: Only select repositories** → só o repositório do cenário (nunca a conta inteira).
- Permissões (Read and write, exceto Metadata):

| Permissão | Acesso | Por quê |
|---|---|---|
| Administration | Read and write | Administração de conteúdo do repo no cenário |
| Contents | Read and write | Editar manifesto, abrir branch para PR |
| Issues | Read and write | Ler a issue e postar comentário de diagnóstico |
| Metadata | Read-only | Obrigatória em todo fine-grained PAT |
| Pull requests | Read and write | Abrir PR com a correção |

**"O teto de permissão do token é o teto do blast radius do agente"** — em produção, corte tudo que a tarefa não usar.

### Configuração do GitHub MCP Server (container)
```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e", "GITHUB_TOOLSETS=issues,pull_requests",
        "-e", "GITHUB_READ_ONLY=1",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}" }
    }
  }
}
```
- **Comece em read-only** (`GITHUB_READ_ONLY=1`) para investigar; só mude para `0` e reconecte quando for **agir** (decisão explícita, por exceção).
- `GITHUB_TOOLSETS=issues,pull_requests` recorta a superfície de tools à triagem.
- Token sempre por variável de ambiente, nunca cravado no arquivo.

### Fluxo simulado na aula
1. Deploy da aplicação no cluster (DigitalOcean, remoto — necessário para o Docker Gateway enxergar).
2. "Semear o caos": alterar propositalmente o `Secret` do manifesto (host do Postgres errado) → aplicação para de responder.
3. Criar manualmente uma issue no GitHub: "Aplicação encontros-tech não está no ar" (simulando usuário, Prometheus, Jira, Trello etc.).
4. Prompt ao agente (deliberadamente "pobre"/não estruturado, para mostrar o uso cru):
   ```text
   Verifique se existe alguma issue em aberto no repositório. Caso exista, verifique
   o incidente e resolva utilizando o acesso ao Kubernetes. O manifesto pode ser
   alterado. Não faça alterações de código e só conclua quando resolver a issue.
   Após a conclusão, faça um registro na issue com a causa raiz do problema e o
   que foi feito para corrigir. Depois feche a issue.
   ```
5. O agente: encontrou a issue via MCP do GitHub → investigou o cluster via MCP de Kubernetes (logs, describe) → identificou a causa raiz (host incorreto no Secret) → corrigiu o manifesto → reaplicou → validou → comentou a issue com sintoma/diagnóstico/causa raiz/correção/validação → **fechou a issue**.

### A lição central
O agente de codificação, operando em **loop de execução** com múltiplas ferramentas conectadas via MCP, consegue reproduzir manualmente o ciclo inteiro de troubleshooting: ler o chamado → investigar → corrigir → documentar → fechar. Isso **só é possível com ferramentas que não existem nativamente** no agente — aqui, a combinação de dois MCPs (Kubernetes + GitHub).

## Pegadinhas
- O prompt usado foi deliberadamente simples/não estruturado — próximas aulas (Spec Driven Development etc.) tratam de estruturar esse fluxo em algo mais confiável (semi-autônomo → AIOps).
- Confirme que a imagem usada no Deployment é a mesma publicada via `docker-compose push` — descompasso entre as duas é fonte comum de erro.

## Links
- Repositório do cenário (fazer fork): https://github.com/KubeDev/encontros-tech
- GitHub MCP Server: https://github.com/github/github-mcp-server

## Dúvidas para revisar
- Repetir esse fluxo com outro projeto/sistema de tickets (Jira, Notion) para fixar o padrão.
- Pensar em como estruturar esse prompt de triagem como uma skill ou workflow (Spec Driven Development), em vez de escrito "na hora".
