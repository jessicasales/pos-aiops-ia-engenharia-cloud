# MCP Servers Prontos como Ferramentas

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 05 — MCP Servers Prontos como Ferramentas (17:49) |
| **Assunto** | Conectar um agente LangChain a um MCP Server de terceiros (Kubernetes) via `MCPAdapter`, eliminando a necessidade de implementar `tools` manualmente |
| **Data** | 30/10/2026 01:15 |
| **Tags** | mcp, mcp-adapter, mcp-server-kubernetes, streamable-http, create_agent, langchain-mcp, kind |

## Resumo da aula

Depois de implementar uma tool manual (aula anterior), a aula mostra a alternativa mais poderosa: conectar o agente a um **MCP Server já existente**, publicado por terceiros, sem escrever nenhuma função própria. O exemplo prático conecta um agente LangChain ao `mcp-server-kubernetes` (projeto público `Flux159/mcp-server-kubernetes`, fixado na versão 4.1.6), rodando localmente contra um cluster Kubernetes criado com `kind`. O agente passa a responder perguntas sobre o estado do cluster (pods, nodes, versão) consultando o MCP em tempo real, via protocolo HTTP.

## Conceitos principais

### O problema resolvido: lock-in da tool manual

A tool criada na aula anterior (`@tool` + função Python) funciona, mas só nesse projeto, só em Python, só com LangChain — é uma implementação específica daquele agente. O MCP (Model Context Protocol) resolve isso: é um padrão aberto de comunicação entre agentes, onde uma ferramenta é implementada **uma única vez** como um MCP Server e pode ser reutilizada por agentes de codificação (Claude Code, Codex), por agentes LangChain, ou por qualquer outra implementação compatível com o protocolo.

### Transporte: HTTP em vez de STDIO

O MCP pode rodar em dois modos de transporte: STDIO ou HTTP. A aula escolhe **HTTP** deliberadamente: como o objetivo é ter um agente que roda de forma autônoma e remota (em um servidor, cluster ou serviço de cloud gerenciado, não na máquina local), não faz sentido usar STDIO, que pressupõe um processo local acoplado. Com HTTP, o agente faz uma requisição direta ao MCP Server, independente de onde cada um esteja rodando.

### Subindo o cluster Kubernetes de teste

```bash
kind create cluster
kubectl get pods
kubectl get all -A
```

O `kind` cria um cluster Kubernetes local só para o agente ter algo a consultar — poderia ser qualquer outro cluster de estudo (k3d, nuvem, etc.). Nenhuma aplicação é implantada; o objetivo é apenas ter um cluster acessível.

### Subindo o MCP Server de Kubernetes

Script `scripts/subir-mcp-kubernetes`, que lê o token do `.env`, habilita o transporte Streamable HTTP, exige autenticação e restringe o catálogo a ferramentas somente leitura, antes de executar o `mcp-server-kubernetes` via `npx` (sem precisar clonar o repositório):

```bash
#!/usr/bin/env bash

set -a
. ./.env
set +a

if [ -z "$KUBERNETES_MCP_TOKEN" ]; then
  echo "Configure KUBERNETES_MCP_TOKEN no arquivo .env antes de executar."
  exit 1
fi

export ALLOW_ONLY_READONLY_TOOLS=true
export ENABLE_UNSAFE_STREAMABLE_HTTP_TRANSPORT=1
export HOST=127.0.0.1
export PORT=3001
export MCP_AUTH_TOKEN="$KUBERNETES_MCP_TOKEN"

exec npx -y mcp-server-kubernetes@4.1.6
```

Fica em execução em um terminal separado, aguardando conexões.

### `MCPAdapter` — o cliente MCP do LangChain

A peça nova no `app.py` é o `MCPAdapter`, importado de `langchain.mcp`. Ele é, na prática, o **MCP Client** do LangChain: faz a ponte de comunicação com o MCP Server, usando a mesma lógica de configuração já vista em agentes de codificação (Claude Code, Codex) — um objeto de configuração `mcpServers` com transporte, URL e headers de autenticação:

```python
async with MCPAdapter(MCP_CONFIG) as adapter:
    tools = await adapter.list_tools()

    print("Ferramentas MCP disponíveis:")
    for tool in tools:
        print(f"- {tool.name}")

    agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)
```

`adapter.list_tools()` lista todas as ferramentas publicadas pelo MCP Server (no caso de Kubernetes: get de pods, nodes, etc.), e essa lista é passada diretamente como `tools=` do `create_agent` — sem nenhuma função `@tool` escrita à mão.

### `src/tools.py` só com configuração, sem função nenhuma

Diferente da aula anterior, o arquivo não contém mais nenhuma função decorada. Contém apenas a validação do token e um dicionário de configuração, no mesmo formato JSON usado para configurar MCP em agentes de codificação:

```python
import os

from dotenv import load_dotenv

load_dotenv()

KUBERNETES_MCP_TOKEN = os.getenv("KUBERNETES_MCP_TOKEN")

if not KUBERNETES_MCP_TOKEN:
    raise SystemExit("Configure KUBERNETES_MCP_TOKEN no arquivo .env antes de executar.")

MCP_CONFIG = {
    "mcpServers": {
        "kubernetes": {
            "transport": "http",
            "url": os.getenv(
                "KUBERNETES_MCP_URL", "http://127.0.0.1:3001/mcp"
            ),
            "headers": {"X-MCP-AUTH": KUBERNETES_MCP_TOKEN},
        }
    }
}
```

### Execução assíncrona (`ainvoke`)

Toda a função `executar()` é assíncrona (`async def`), e a chamada ao agente usa `await agent.ainvoke(...)` em vez do `invoke` síncrono usado até então — necessário porque o `MCPAdapter` abre e mantém uma conexão assíncrona com o MCP Server:

```python
resultado = await agent.ainvoke({"messages": [("human", pergunta)]})
resposta = resultado["messages"][-1].text
```

O ponto de entrada do script usa `asyncio.run(executar())` dentro de `main()`.

### System Prompt com restrições explícitas de segurança

```python
SYSTEM_PROMPT = """
Você é um assistente de plataforma que consulta o estado do Kubernetes usando as ferramentas
disponíveis. Nunca altere recursos, consulte Secrets ou revele credenciais. Se uma informação não
estiver disponível, diga que não sabe.
"""
```

Mesmo com o catálogo de ferramentas restrito a somente leitura (`ALLOW_ONLY_READONLY_TOOLS=true` no server), o System Prompt reforça explicitamente as restrições de segurança (nunca alterar recursos, nunca consultar Secrets, nunca revelar credenciais) — uma camada adicional de segurança em texto, além da restrição técnica no servidor.

### Execução e comportamento observado

```bash
cd ../06-assistente-plataforma
uv sync
uv run assistente-plataforma
```

- Primeira execução: erro "Invalid Authentication Token" — causa identificada em tela: faltava preencher corretamente a `ANTHROPIC_API_KEY` e o `KUBERNETES_MCP_TOKEN` no `.env` (o mesmo token definido ao subir o MCP Server precisa ser repetido no `.env` do assistente).
- Após corrigir o `.env`: o assistente lista as ferramentas MCP disponíveis e aguarda a pergunta via `input()`.
- Pergunta "Quantos pods eu tenho em execução nesse momento?" → o agente chama a ferramenta correspondente do MCP e responde que há nove pods em execução, todos com status `Running`, distribuídos entre os namespaces `kube-system` e `local-path-storage`.
- Pergunta combinada "Quantos nodes eu tenho nesse cluster? Qual é a versão desse cluster Kubernetes?" → o agente responde que o cluster possui um node e que a versão é `1.36.1`.

### A observação final do instrutor: fundamentos reaproveitáveis

Depois de conhecer o conceito de MCP e MCP Server em agentes de codificação, configurar o mesmo protocolo em um agente LangChain segue a mesma lógica — muda a peça que implementa o cliente (aqui, o `MCPAdapter`), mas a estrutura de configuração (`mcpServers`, transporte, URL, headers) é essencialmente a mesma em qualquer ferramenta ou biblioteca.

### Gancho para a próxima etapa: interface do agente

A aula fecha apontando a próxima questão: até aqui, a interação com o agente ocorreu de forma "crua", direto no terminal via `uv run`. Mas a forma de interfaciar um agente de IA — via linha de comando (CLI) estruturada ou via interface gráfica — importa bastante quando o agente vai para produção ou precisa se integrar a outros sistemas. Esse é o tema das próximas aulas.

## Comandos e configurações

```bash
# Criação e verificação do cluster Kubernetes
kind create cluster
kubectl get pods
kubectl get all -A
```

```bash
# .env.example do assistente de plataforma
# Copie para .env e preencha — o .env está no .gitignore e nunca deve ser commitado.
ANTHROPIC_API_KEY=sua-chave-aqui

# Identificador do modelo usado pelo ChatAnthropic.
MODELO=claude-sonnet-5

# Endpoint Streamable HTTP do Kubernetes MCP e token configurado no server.
KUBERNETES_MCP_URL=http://127.0.0.1:3001/mcp
KUBERNETES_MCP_TOKEN=troque-este-token
```

```bash
# Subir o MCP Server (terminal 1)
./scripts/subir-mcp-kubernetes

# Subir o assistente (terminal 2)
cd ../06-assistente-plataforma
uv sync
uv run assistente-plataforma
```

```python
# src/app.py (resumido)
import asyncio
import os

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain.mcp import MCPAdapter
from langchain_anthropic import ChatAnthropic

from src.tools import MCP_CONFIG

load_dotenv()

if not os.getenv("ANTHROPIC_API_KEY"):
    raise SystemExit("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")

SYSTEM_PROMPT = """
Você é um assistente de plataforma que consulta o estado do Kubernetes usando as ferramentas
disponíveis. Nunca altere recursos, consulte Secrets ou revele credenciais. Se uma informação não
estiver disponível, diga que não sabe.
"""

async def executar() -> None:
    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

    async with MCPAdapter(MCP_CONFIG) as adapter:
        tools = await adapter.list_tools()

        print("Ferramentas MCP disponíveis:")
        for tool in tools:
            print(f"- {tool.name}")

        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)

        pergunta = input("\nPergunta: ")

        resultado = await agent.ainvoke({"messages": [("human", pergunta)]})
        resposta = resultado["messages"][-1].text

        print("Resposta:")
        print(resposta)

def main() -> None:
    asyncio.run(executar())

if __name__ == "__main__":
    main()
```

```python
# src/tools.py
import os

from dotenv import load_dotenv

load_dotenv()

KUBERNETES_MCP_TOKEN = os.getenv("KUBERNETES_MCP_TOKEN")

if not KUBERNETES_MCP_TOKEN:
    raise SystemExit("Configure KUBERNETES_MCP_TOKEN no arquivo .env antes de executar.")

MCP_CONFIG = {
    "mcpServers": {
        "kubernetes": {
            "transport": "http",
            "url": os.getenv(
                "KUBERNETES_MCP_URL", "http://127.0.0.1:3001/mcp"
            ),
            "headers": {"X-MCP-AUTH": KUBERNETES_MCP_TOKEN},
        }
    }
}
```

## Pegadinhas

- Erro "Invalid Authentication Token" na primeira execução: é preciso garantir que o `KUBERNETES_MCP_TOKEN` usado ao subir o MCP Server (script `subir-mcp-kubernetes`) seja exatamente o mesmo valor configurado no `.env` do assistente — são dois arquivos `.env` distintos (o do MCP Server e o do assistente) que precisam estar sincronizados nesse valor.
- Usar `MCPAdapter` como gerenciador de contexto assíncrono (`async with`) exige que toda a cadeia de chamadas a partir dali seja assíncrona (`async def executar()`, `await adapter.list_tools()`, `await agent.ainvoke(...)`) — misturar com código síncrono quebra o fluxo.
- STDIO não é a escolha certa quando o agente é pensado para rodar remotamente/autonomamente (servidor, cluster, cloud gerenciada); HTTP é a opção coerente com esse cenário, mesmo custando um pouco mais de configuração (host, porta, autenticação).
- `ALLOW_ONLY_READONLY_TOOLS=true` no servidor restringe tecnicamente o catálogo de ferramentas, mas isso não substitui as instruções explícitas de segurança no System Prompt (nunca alterar recursos, nunca revelar credenciais) — as duas camadas se complementam.

## Dúvidas para revisar

- Como ficaria a configuração do `MCP_CONFIG` para conectar simultaneamente a mais de um MCP Server (por exemplo, Kubernetes e um banco de dados) no mesmo agente?
- Que diferenças práticas existem entre expor o MCP Server via STDIO (processo local) e via HTTP (como feito na aula) em termos de deploy em produção?
- Como o agente decide qual das ferramentas listadas por `adapter.list_tools()` chamar para cada pergunta — isso depende só dos nomes/descrições das ferramentas publicadas pelo MCP Server?
