# Interface Conversacional e Retorno Parcial

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 07 — Interface Conversacional e Retorno Parcial (15:24) |
| **Assunto** | Interface de chat com Streamlit para o assistente de plataforma, com histórico de conversa em `session_state` e streaming de texto filtrado via `astream` |
| **Data** | 30/10/2026 01:15 |
| **Tags** | streamlit, chat-interface, session-state, astream, streaming, langgraph-node |

## Resumo da aula

Depois da CLI (aula anterior, voltada para automação), a aula apresenta a alternativa para interação **humana** direta com o agente: uma interface de chat construída com **Streamlit**, biblioteca Python que permite criar interfaces gráficas sem escrever HTML. O mesmo assistente de plataforma (Kubernetes via MCP) ganha uma interface de chat real, com histórico de conversa persistido na sessão e streaming de texto — exibindo apenas a resposta do modelo, nunca as chamadas internas de ferramentas.

## Conceitos principais

### Streamlit — interface gráfica em Python, sem HTML

Para quem não domina HTML/CSS/JavaScript, a biblioteca Streamlit permite construir interfaces gráficas inteiramente em código Python. É indicada especialmente para sistemas internos, relatórios, e aplicações do tipo chatbot — o próprio site do Streamlit tem exemplos de réplicas de ChatGPT, dashboards com gráficos, to-do lists, assistentes de Q&A com upload de arquivos, entre outros. Para projetos mais complexos, eventualmente é necessário recorrer a HTML "puro", mas para interfaces de uso interno e MVPs, o Streamlit cobre muito bem.

Observação prática reforçada pelo instrutor: ao especificar o projeto em um TRD/ADR para a IA gerar o código, a biblioteca de interface (Typer para CLI, Streamlit para interface gráfica) é uma decisão que deve constar da especificação técnica.

### `pyproject.toml` — nova dependência

```toml
[project]
name = "assistente-plataforma-chat"
version = "0.1.0"
description = "Exemplo didatico: interface conversacional com streaming para um assistente de plataforma"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "langchain-anthropic>=1.4.8",
    "langchain[mcp]>=1.4.0",
    "python-dotenv>=1.2.2",
    "streamlit>=1.64.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src"]
```

A única mudança estrutural em relação aos exemplos anteriores é a troca do Typer pelo `streamlit` como camada de interface — o restante do stack do agente (LangChain, MCP, Anthropic) permanece o mesmo.

### `st.session_state` — a janela de contexto da conversa

```python
if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])
```

`st.session_state.messages` funciona como a janela de contexto da conversa — armazena o histórico de mensagens (usuário e assistente) durante a sessão, de forma análoga ao padrão já visto com `historico`/`MessagesPlaceholder` em aulas anteriores. A cada execução do script (padrão do Streamlit: o script roda do início a cada interação), o histórico é redesenhado na tela a partir desse estado.

### `st.chat_input` e o fluxo de uma nova pergunta

```python
if prompt := st.chat_input("Pergunte sobre o cluster Kubernetes"):
    st.session_state.messages.append({"role": "user", "content": prompt})

    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        try:
            answer = st.write_stream(responder(st.session_state.messages))
        except Exception as error:
            print(
                f"[aplicação] falha ao responder: {type(error).__name__}",
                file=sys.stderr,
                flush=True,
            )
            answer = "Não foi possível consultar o cluster. Verifique o terminal da aplicação."
        st.markdown(answer)

    st.session_state.messages.append({"role": "assistant", "content": answer})
```

`st.chat_input(...)` é a caixa de texto de entrada do chat. Ao receber uma pergunta: adiciona a mensagem do usuário ao histórico, exibe-a na tela, e chama `st.write_stream(responder(...))` para exibir a resposta do assistente progressivamente (streaming), em vez de esperar a resposta completa. Qualquer falha na consulta é tratada com uma mensagem amigável na interface, enquanto o detalhe técnico do erro vai para o terminal (`stderr`).

### `responder()` — o mesmo agente, agora assíncrono gerador

```python
async def responder(messages: list[dict[str, str]]):
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        raise RuntimeError("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")

    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

    async with MCPAdapter(mcp_config()) as adapter:
        tools = await adapter.list_tools()

        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)

        async for text in stream_agent_text(agent, messages):
            yield text
```

Mesma estrutura de sempre (modelo, `MCPAdapter`, `create_agent`), mas agora como um **generator assíncrono**, que vai produzindo (`yield`) fragmentos de texto conforme o agente responde — é isso que `st.write_stream` consome para exibir a resposta token a token.

### System Prompt adaptado para conversa com histórico

```python
SYSTEM_PROMPT = """
Você é um assistente de plataforma que consulta o estado do Kubernetes usando as ferramentas
disponíveis. Nunca altere recursos, consulte Secrets ou revele credenciais. Se uma informação não
estiver disponível, diga que não sabe. Considere o histórico da conversa ao interpretar referências
como "eles", "o anterior" e "esse namespace".
"""

```

Reforça explicitamente que o agente deve usar o histórico da conversa para resolver referências contextuais ("eles", "o anterior", "esse namespace") — necessário porque, numa interface de chat real, perguntas de acompanhamento costumam ser incompletas sem o contexto das trocas anteriores.

### `src/chat.py` — filtrando o stream para só texto do modelo

```python
from collections.abc import AsyncIterator
from typing import Any

def text_from_stream_part(part: dict[str, Any]) -> str:
    """Retorna somente texto do modelo; eventos de ferramenta nunca chegam à UI."""
    if part.get("type") != "messages":
        return ""

    token, metadata = part["data"]
    if metadata.get("langgraph_node") != "model":
        return ""

    return token.text

async def stream_agent_text(
    agent: Any,
    messages: list[dict[str, str]],
) -> AsyncIterator[str]:
    async for part in agent.astream(
        {"messages": messages},
        stream_mode="messages",
        version="v2",
    ):
        text = text_from_stream_part(part)
        if text:
            yield text
```

Ponto técnico central da aula: `agent.astream(..., stream_mode="messages", version="v2")` emite eventos de várias naturezas durante a execução do agente — incluindo chamadas de ferramenta e seus resultados internos (ex.: a consulta ao MCP de Kubernetes). `text_from_stream_part` filtra esse fluxo para deixar passar **apenas** os fragmentos de texto originados do nó `model` (o próprio LLM respondendo), descartando tudo que vem de outros nós (como chamadas/resultados de tools). Isso garante que o usuário final veja só a resposta em linguagem natural, nunca o "backstage" de chamadas de ferramenta.

### `src/tools.py` — mesma configuração MCP de sempre

```python
import os

def mcp_config() -> dict:
    token = os.getenv("KUBERNETES_MCP_TOKEN")

    if not token:
        raise RuntimeError(
            "Configure KUBERNETES_MCP_TOKEN no arquivo .env antes de executar."
        )

    return {
        "mcpServers": {
            "kubernetes": {
                "transport": "http",
                "url": os.getenv(
                    "KUBERNETES_MCP_URL", "http://127.0.0.1:3001/mcp"
                ),
                "headers": {"X-MCP-AUTH": token},
            }
        }
    }
```

Idêntica, em estrutura, às configurações MCP das duas aulas anteriores.

### Execução: rodar via Streamlit, não via `uv run app.py` direto

```bash
docker container ls
kind create cluster
```

```bash
# Terminal 1: subir o MCP server
./scripts/subir-mcp-kubernetes
```

```bash
# Terminal 2: subir a interface
cd 08-assistente-plataforma-chat
uv sync
uv run streamlit run src/app.py
```

Ponto importante: como a aplicação usa Streamlit, ela precisa ser iniciada sempre através do comando `streamlit run`, nunca executando o script Python diretamente — é o Streamlit que monta toda a estrutura da interface "por debaixo dos panos" e abre o endereço local no navegador.

### Comportamento observado no chat

- Pergunta "Quantos pods eu tenho em execução nesse momento?" → a mensagem do usuário entra no histórico, aparece na tela, e a resposta do assistente é montada progressivamente via streaming.
- Perguntas subsequentes na mesma sessão se empilham no histórico visível (ex.: "Quantos namespaces eu tenho nesse momento? Qual é a versão do Kubernetes atual?") → o assistente responde que o cluster tem **5 namespaces** e que a versão do Kubernetes é **1.36.1** — demonstrando que o contexto de conversa (`session_state.messages`) é mantido entre as perguntas.

### Conclusão da aula: duas opções de interface, cada uma para seu público

O instrutor fecha reforçando a visão de conjunto construída nas últimas duas aulas: **Typer** para CLI (voltado a automação, scripts, pipelines) e **Streamlit** para interface gráfica (voltado a interação humana direta) são as duas opções demonstradas no curso até aqui, e nada impede criar as duas camadas de interface para o mesmo agente.

## Comandos e configurações

```toml
# pyproject.toml
[project]
name = "assistente-plataforma-chat"
version = "0.1.0"
description = "Exemplo didatico: interface conversacional com streaming para um assistente de plataforma"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "langchain-anthropic>=1.4.8",
    "langchain[mcp]>=1.4.0",
    "python-dotenv>=1.2.2",
    "streamlit>=1.64.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src"]
```

```bash
# .env
# Copie para .env e preencha — o .env está no .gitignore e nunca deve ser commitado.
ANTHROPIC_API_KEY=sua-chave-aqui
MODELO=claude-sonnet-5
KUBERNETES_MCP_URL=http://127.0.0.1:3001/mcp
KUBERNETES_MCP_TOKEN=troque-este-token
```

```bash
docker container ls
kind create cluster
./scripts/subir-mcp-kubernetes      # terminal 1

cd 08-assistente-plataforma-chat
uv sync
uv run streamlit run src/app.py     # terminal 2
```

```python
# src/app.py (resumido)
import os
import sys

import streamlit as st
from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain.mcp import MCPAdapter
from langchain_anthropic import ChatAnthropic

from src.chat import stream_agent_text
from src.tools import mcp_config

load_dotenv()

SYSTEM_PROMPT = """
Você é um assistente de plataforma que consulta o estado do Kubernetes usando as ferramentas
disponíveis. Nunca altere recursos, consulte Secrets ou revele credenciais. Se uma informação não
estiver disponível, diga que não sabe. Considere o histórico da conversa ao interpretar referências
como "eles", "o anterior" e "esse namespace".
"""

async def responder(messages: list[dict[str, str]]):
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        raise RuntimeError("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")

    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

    async with MCPAdapter(mcp_config()) as adapter:
        tools = await adapter.list_tools()
        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)

        async for text in stream_agent_text(agent, messages):
            yield text

if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Pergunte sobre o cluster Kubernetes"):
    st.session_state.messages.append({"role": "user", "content": prompt})

    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        try:
            answer = st.write_stream(responder(st.session_state.messages))
        except Exception as error:
            print(
                f"[aplicação] falha ao responder: {type(error).__name__}",
                file=sys.stderr,
                flush=True,
            )
            answer = "Não foi possível consultar o cluster. Verifique o terminal da aplicação."
        st.markdown(answer)

    st.session_state.messages.append({"role": "assistant", "content": answer})
```

```python
# src/chat.py
from collections.abc import AsyncIterator
from typing import Any

def text_from_stream_part(part: dict[str, Any]) -> str:
    """Retorna somente texto do modelo; eventos de ferramenta nunca chegam à UI."""
    if part.get("type") != "messages":
        return ""

    token, metadata = part["data"]
    if metadata.get("langgraph_node") != "model":
        return ""

    return token.text

async def stream_agent_text(
    agent: Any,
    messages: list[dict[str, str]],
) -> AsyncIterator[str]:
    async for part in agent.astream(
        {"messages": messages},
        stream_mode="messages",
        version="v2",
    ):
        text = text_from_stream_part(part)
        if text:
            yield text
```

```python
# src/tools.py
import os

def mcp_config() -> dict:
    token = os.getenv("KUBERNETES_MCP_TOKEN")

    if not token:
        raise RuntimeError(
            "Configure KUBERNETES_MCP_TOKEN no arquivo .env antes de executar."
        )

    return {
        "mcpServers": {
            "kubernetes": {
                "transport": "http",
                "url": os.getenv(
                    "KUBERNETES_MCP_URL", "http://127.0.0.1:3001/mcp"
                ),
                "headers": {"X-MCP-AUTH": token},
            }
        }
    }
```

## Pegadinhas

- Uma aplicação Streamlit precisa ser iniciada com `streamlit run <arquivo>`, nunca com `uv run app.py`/`python app.py` direto — a execução "nua" não monta a interface.
- Sem o filtro `text_from_stream_part`, o `astream` do agente exporia ao navegador eventos internos (chamadas de ferramenta, resultados brutos do MCP), não só a resposta final em texto — o filtro por `metadata.get("langgraph_node") != "model"` é o que garante que só a fala do modelo chega à UI.
- O System Prompt precisa instruir explicitamente o agente a considerar o histórico da conversa para resolver referências contextuais ("eles", "esse namespace") — sem isso, perguntas de acompanhamento mais curtas podem ser mal interpretadas, mesmo com o histórico técnicamente disponível em `session_state.messages`.
- Erros durante a consulta (ex.: falha de conexão com o MCP) são capturados e substituídos por uma mensagem amigável na interface, mas o erro real é sempre impresso em `stderr` para quem está rodando a aplicação — útil para diagnóstico sem expor detalhes técnicos ao usuário final.

## Dúvidas para revisar

- Como adaptar `text_from_stream_part` para também expor, de forma controlada, um indicador visual de "consultando ferramenta..." enquanto o agente chama o MCP, sem vazar o conteúdo técnico da chamada?
- Streamlit reexecuta o script inteiro a cada interação — que cuidados são necessários para evitar reconectar o `MCPAdapter` ou recriar o agente a cada mensagem, em vez de reaproveitar entre interações?
- Quais seriam os critérios para decidir, num projeto real, se vale a pena oferecer as duas interfaces (CLI e chat) para o mesmo agente, ou escolher só uma?
