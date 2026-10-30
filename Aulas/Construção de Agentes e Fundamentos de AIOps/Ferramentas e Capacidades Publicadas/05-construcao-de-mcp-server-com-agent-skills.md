# Construção de MCP Server com Agent Skills

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 05 — Construção de MCP Server com Agent Skills (12:39) |
| **Assunto** | Setup inicial de um MCP Server em Python (FastMCP) do zero, usando boilerplate + OpenSpec + skill `build-mcp-server`, com 3 PRDs prontos para as próximas aulas |
| **Data** | 30/10/2026 01:15 |
| **Tags** | mcp-server, fastmcp, boilerplate, openspec, build-mcp-server, prd, spec-driven-development, stdio, http |

## Resumo da aula

Depois de criar ferramentas com LangChain, a aula inicia a construção de um **MCP Server do absoluto zero** — não mais consumindo um MCP pronto (como o `mcp-server-kubernetes` de aulas anteriores), mas construindo um próprio, em Python, usando **FastMCP**. O MCP a ser construído terá as mesmas funções da ferramenta `listar_droplets` (consulta de Droplets na DigitalOcean), mas poderá ser conectado tanto a um agente LangChain quanto a um agente de codificação (Claude Code, etc.) — essa portabilidade é justamente a vantagem central do MCP sobre uma tool LangChain nativa. Esta aula é só o **setup**: boilerplate, OpenSpec, skill de construção de MCP, e os três PRDs que guiarão as próximas três aulas (consulta de Droplets, controle de energia, consulta de Kubernetes/bancos de dados). Nenhum código de tool é escrito nesta aula.

## Conceitos principais

### Por que construir um MCP Server próprio, e não só consumir um pronto

O módulo anterior (agentes de codificação) já cobriu o conceito de MCP em profundidade — MCP Client, MCP Server, serviço conectado, tools/dados/prompts expostos via MCP, transporte STDIO/HTTP. Esta aula muda o ângulo: em vez de consumir um MCP pronto, constrói-se um do zero, replicando o objetivo da ferramenta LangChain de Droplets, mas com a vantagem de poder ser consumido por **qualquer** agente compatível com MCP — tanto um agente LangChain quanto um agente de codificação.

### SDKs oficiais de MCP e a escolha do FastMCP

O site oficial do protocolo (`modelcontextprotocol.io`) lista SDKs oficiais para várias linguagens: TypeScript, Python, C#, Go, Rust, Ruby, Java, Swift, PHP, Kotlin. A aula usa **Python**, e dentro do ecossistema Python, a biblioteca escolhida é o **FastMCP** — inspirado no FastAPI (framework web popular para construir APIs), o FastMCP oferece um padrão de framework (análogo a MVC) especificamente para construir MCP Servers. É um projeto open source, com documentação própria.

### Skills oficiais para construção de MCP

Em vez de codificar o MCP manualmente, a aula usa IA apoiada por **skills** especializadas — o plugin `mcp-server-dev` (Anthropic) instala três skills:
1. **`build-mcp-server`** — ponto de partida principal, usado nesta aula, para especificar e construir o MCP.
2. **`build-mcp-app`** — para construir no formato de aplicação interativa (ex.: com interface gráfica).
3. **`build-mcp-b`** (empacotamento) — para empacotar os MCPs construídos.

### Boilerplate `KubeDev/boilerplate-mcp-python`

```bash
git clone https://github.com/KubeDev/boilerplate-mcp-python.git
cd boilerplate-mcp-python
```

Um boilerplate pronto é usado para economizar tempo de setup inicial — já vem com estrutura de transporte (STDIO e HTTP), preparado para Docker, e uma tool de exemplo (`hello_world`) só para o projeto "nascer" com algo funcionando.

**`pyproject.toml`** — projeto gerenciado com `uv`, dependência principal `fastmcp>=4.1.0`, mais `pytest`, `pytest-asyncio` e `ruff` como dependências de desenvolvimento; `ruff` configurado com regras de lint (`E`, `F`, `I`, `UP`, `B`).

**`docker-compose.yml`** — sobe o server em modo HTTP dentro de um container na porta 8000, com healthcheck batendo em `/health`.

**`AGENTS.md`** — arquivo de instruções-base para o agente de codificação trabalhar no projeto, cobrindo:
- Comandos (`uv sync`, `uv run pytest`, `uv run ruff check . && uv run ruff format .`, `uv run mcp-server` para stdio, `uv run mcp-server --transport http`, `docker compose up --build`).
- Estrutura de pastas (`src/mcp_server/main.py`, `config.py`, `server.py`, `tools/`).
- Passo a passo para adicionar uma tool nova (criar módulo em `tools/`, registrar em `tools/__init__.py`, adicionar testes com `Client(transport=mcp)`).
- **Regras de projeto** importantes:
  - **Nunca escrever no stdout** em modo stdio (corrompe a sessão do protocolo) — usar `logging` (configurado para stderr) ou `ctx.info()`.
  - **Toda tool precisa de `ToolAnnotations`**: `title` + `read_only_hint=True` (leitura) ou `destructive_hint=True` (escrita/remoção) — validado por teste automatizado (`test_tools_have_review_annotations`), critério de revisão do diretório de conectores do Claude.
  - **Separar leitura de escrita**: nunca uma tool genérica com parâmetro `method`; preferir `create_x`, `update_x`, `delete_x`.
  - Nomes de tool em `snake_case`, até 64 caracteres.
  - **Docstring = descrição que vai para o contexto do modelo**: curta, diz o que faz e quando usar — não dar instruções de comportamento ao modelo ali.
  - Erros acionáveis via `fastmcp.exceptions.ToolError`, com mensagem que explica o que corrigir.
  - Respostas enxutas: retornar só o necessário, paginar listas grandes.
  - Configuração e segredos só via variáveis de ambiente.
  - Servidor HTTP roda em modo **stateless** (`stateless_http=True`) por padrão.

### Código inicial do boilerplate

**`src/mcp_server/__main__.py`** — ponto de entrada que escolhe o transporte (`--transport stdio|http` ou `MCP_TRANSPORT`), com logging sempre direcionado a `stderr` (porque, em stdio, o stdout é o canal do protocolo).

**`src/mcp_server/server.py`** — cria a instância `FastMCP`, expõe a rota `/health` (usada pelo healthcheck do Docker), e chama `tools.register_all(mcp)` para registrar as tools.

**Tool de exemplo `hello_world`** (`src/mcp_server/tools/hello.py`) — só existe para o projeto nascer com uma tool registrada; é removida ao começar a implementar as tools reais. Já demonstra o padrão de anotação exigido: `@mcp.tool(annotations=ToolAnnotations(title="Hello World", read_only_hint=True))`.

### Setup do fluxo de Spec Driven Development

```bash
openspec init                 # seleção de ferramentas: só Claude Code
npx skills add https://github.com/anthropics/claude-plugins-official --skill build-mcp-server
```

O projeto é inicializado com **OpenSpec** (SDD) e a skill `build-mcp-server` é instalada no nível do projeto (com symlink). O instrutor reforça que o fluxo específico (OpenSpec) não é obrigatório — o importante é ter **alguma** metodologia de desenvolvimento orientada por especificação, seja OpenSpec, seja outro fluxo já adotado pelo desenvolvedor.

### Os três PRDs que vão guiar as próximas aulas

Três PRDs prontos (fornecidos pelo instrutor, não escritos nesta aula) são copiados para `docs/prds/`, cada um correspondendo a uma aula futura:

| PRD | Título | Prioridade | Depende de | Aula |
|---|---|---|---|---|
| 001 | Consulta de droplets por região e estado | Alta | — | Aula 06 |
| 002 | Controle de energia de droplets | Alta | 001 | Aula 07 |
| 003 | Consulta de clusters Kubernetes e bancos de dados gerenciados | Média | — | Aula 08 |

**PRD 001 — pontos centrais**: expõe uma tool de listagem de Droplets com filtro opcional por região e por estado (`new`, `active`, `off`, `archive`, declarados como **enum** no schema da tool). Decisões de produto centrais: o filtro é responsabilidade do MCP (a API da DigitalOcean só filtra por tag/nome/tipo); o resultado deve ser **sempre completo**, mesmo que a conta tenha mais Droplets do que uma página da API retorna — esse é o ponto didático central da feature (evitar o erro silencioso de ler só a primeira página); a saída é sempre **resumida** (não o JSON completo do Droplet), para economizar contexto do LLM. Critérios de aceite cobrem: listagem completa mesmo com paginação, filtros corretos, combinação de filtros com E lógico, erro claro para estado inválido (listando os valores aceitos), resultado vazio explícito (não confundido com falha), e nenhuma exposição de token em erros de autenticação.

**PRD 002 — pontos centrais**: a única feature de **escrita** do projeto — ligar/desligar um Droplet. Decisões centrais: "parar" significa sempre **desligamento gracioso** (shutdown do SO), nunca corte forçado de energia (evita corrupção de dados); a ação na DigitalOcean é **assíncrona**, então a resposta da tool confirma apenas que o pedido foi **aceito**, nunca que já foi concluído — a conclusão deve ser verificada depois, consultando a listagem (PRD 001); identificação do Droplet por **ID**, nunca por nome (nomes podem repetir); **sem salvaguardas** (sem confirmação, sem allowlist) — decisão explícita do autor, justificada pela conta única de demonstração. Critérios de aceite cobrem o ciclo completo (desligar → consultar → ligar → consultar), confirmação de que o desligamento é sempre gracioso (verificável no histórico de ações do painel), e tratamento de "já está no estado pedido" sem erro.

**PRD 003 — pontos centrais**: a feature mais simples do conjunto (leitura sem filtro) — listar clusters Kubernetes (DOKS) e bancos de dados gerenciados da conta, em **duas consultas separadas** (atributos diferentes, misturar confundiria o agente). Mesma política de saída resumida e resultado completo do PRD 001. Ponto de segurança central: **nenhuma credencial** (kubeconfig, senha, string de conexão) deve aparecer nas respostas — dado sensível que não deve passar pelo contexto do LLM.

Os três PRDs seguem o mesmo template estruturado: Contexto (produto/área, estado atual, problema), Solução proposta (visão de produto, decisões, fora do escopo), Funcionalidades (user stories com Rules e Edge cases), Fluxo de negócio, Critérios de aceite (com razão de negócio e como verificar cada um), Métricas de sucesso, Riscos e dependências, Referências, e um Registro de decisões datado — um nível de detalhe bem acima do que foi visto em PRDs anteriores do curso, adequado a um MCP que será usado como material didático público.

### Ponto de chegada da aula

Ao final: boilerplate clonado, OpenSpec inicializado, skill `build-mcp-server` instalada, e os três PRDs copiados para `docs/prds/` — tudo pronto para o primeiro ciclo real de desenvolvimento guiado por especificação, que começa na próxima aula com o PRD 001.

## Comandos e configurações

```bash
# Clonar o boilerplate
git clone https://github.com/KubeDev/boilerplate-mcp-python.git
cd boilerplate-mcp-python

# Inicializar o Spec Driven Development (OpenSpec)
openspec init   # seleção de ferramentas: Claude Code

# Instalar a skill de construção de MCP Server
npx skills add https://github.com/anthropics/claude-plugins-official --skill build-mcp-server
```

```bash
# Comandos do boilerplate (via AGENTS.md)
uv sync                                   # instala dependências
uv run pytest                             # testes (cliente em memória, sem rede)
uv run ruff check . && uv run ruff format .
uv run mcp-server                         # stdio
uv run mcp-server --transport http        # HTTP em http://127.0.0.1:8000/mcp
docker compose up --build                 # HTTP em container (porta 8000)
```

```toml
# pyproject.toml (boilerplate)
[project]
name = "boilerplate-mcp-python"
version = "0.1.0"
description = "Boilerplate de servidor MCP em Python (FastMCP) com transporte stdio e HTTP"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "fastmcp>=4.1.0",
]

[project.scripts]
mcp-server = "mcp_server.__main__:main"

[dependency-groups]
dev = [
    "pytest>=9.1.1",
    "pytest-asyncio>=1.4.0",
    "ruff>=0.17.0",
]
```

```python
# src/mcp_server/server.py
from fastmcp import FastMCP
from starlette.requests import Request
from starlette.responses import JSONResponse

from mcp_server import tools

def create_server() -> FastMCP:
    mcp = FastMCP(name="mcp-server", version="0.1.0")

    @mcp.custom_route("/health", methods=["GET"])
    async def health(request: Request) -> JSONResponse:
        return JSONResponse({"status": "ok"})

    tools.register_all(mcp)
    return mcp

mcp = create_server()
```

```python
# src/mcp_server/tools/hello.py (tool de exemplo, removida depois)
from fastmcp import FastMCP
from mcp.types import ToolAnnotations

def register(mcp: FastMCP) -> None:
    @mcp.tool(annotations=ToolAnnotations(title="Hello World", read_only_hint=True))
    def hello_world(name: str = "World") -> str:
        """Return a greeting for the given name."""
        return f"Hello, {name}!"
```

Resumo estruturado dos três PRDs (texto completo em `docs/prds/` do projeto `boilerplate-mcp-python`):

| PRD | Feature | Tipo | Decisão central | Aula |
|---|---|---|---|---|
| 001 | Listar Droplets, filtro por região/estado | Leitura (com filtro) | Resultado sempre completo (sem erro silencioso de paginação); saída resumida; estados como enum | 06 |
| 002 | Ligar/desligar Droplet | Escrita (única do projeto) | Desligamento sempre gracioso; resposta confirma aceite, não conclusão (assincronia); sem salvaguardas | 07 |
| 003 | Listar clusters K8s e bancos gerenciados | Leitura (simples, sem filtro) | Duas consultas separadas; nenhuma credencial nas respostas | 08 |

## Pegadinhas

- Em modo STDIO, `print()`/stdout é o canal do próprio protocolo MCP — qualquer escrita acidental no stdout corrompe a sessão. Logs devem ir sempre para `stderr` via `logging` ou `ctx.info()`.
- O servidor HTTP roda em modo stateless por padrão (`stateless_http=True`) — só deve ser alterado se alguma tool específica precisar manter estado entre chamadas na mesma sessão.
- Nem toda API de cloud oferece os filtros que o MCP quer expor (ex.: a API da DigitalOcean não filtra por região/estado na listagem de Droplets) — identificar essa lacuna no PRD, antes de implementar, evita descobrir o problema tarde.
- O erro de ler só a primeira página de uma listagem paginada é silencioso — não gera exceção, só retorna dados incompletos; por isso o PRD 001 trata a completude como critério de aceite explícito e testável.
- Toda tool precisa das anotações corretas (`read_only_hint` ou `destructive_hint`) — isso não é só documentação, é validado por teste automatizado e é critério de revisão para listagem em diretórios de conectores.

## Dúvidas para revisar

- Como ficaria o teste automatizado (`test_tools_have_review_annotations`) que garante que toda tool tem as anotações corretas — vale a pena olhar sua implementação quando o projeto crescer?
- Que diferenças práticas existem entre expor o mesmo MCP Server via STDIO (para um agente de codificação local) e via HTTP (para um agente LangChain remoto), em termos de configuração de cliente?
- Os PRDs fornecidos nesta aula têm um nível de detalhe (critérios de aceite com "razão de negócio" e "como verificar", registro de decisões datado) bem além do que vimos em PRDs anteriores do curso — esse nível de rigor é recomendado para todo projeto, ou é proporcional ao fato de este MCP ser material didático público?
