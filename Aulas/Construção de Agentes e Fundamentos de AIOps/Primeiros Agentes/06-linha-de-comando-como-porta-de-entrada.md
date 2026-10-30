# Linha de Comando como Porta de Entrada

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 06 — Linha de Comando como Porta de Entrada (14:19) |
| **Assunto** | Transformar o assistente de plataforma em uma CLI de verdade com Typer, recebendo pergunta e namespace como parâmetros, sem interação via `input()` |
| **Data** | 30/10/2026 01:15 |
| **Tags** | typer, cli, argumento, option, help-automatico, automacao-devops |

## Resumo da aula

Até aqui, todos os agentes eram iniciados com `uv run <app>` e a pergunta era digitada interativamente via `input()` depois da inicialização — ao estilo "cru" de terminal. A aula mostra como transformar isso em uma **CLI real**, ao estilo de Claude Code (`uv run app "pergunta"`), usando a biblioteca **Typer**. A pergunta passa a ser um argumento da linha de comando e o namespace do Kubernetes uma opção (`--namespace`), eliminando qualquer interação durante a execução — essencial para uso em scripts, pipelines e automações.

## Conceitos principais

### O problema: inicialização interativa não serve para automação

```bash
uv run assistente-plataforma "Liste os pods do cluster"
```

Essa chamada, com a versão da aula anterior (`06-assistente-plataforma`), **não funciona** — o CLI daquele projeto não está preparado para receber a pergunta como parâmetro de inicialização; ele só a lê via `input()` depois de já estar rodando. Isso é inviável para pipelines e scripts de automação, onde se quer passar todas as instruções de uma vez, em um único comando.

### Typer — biblioteca recomendada para CLIs em Python

O instrutor recomenda **Typer** como a ferramenta a usar sempre que for criar uma interface de CLI em Python: além de obter parâmetros de inicialização, ele entrega uma interface mais rica e visualmente mais agradável, e facilita bastante a implementação. Recomendação prática: ao especificar isso em um ADR ou TRD para a IA gerar o código, é importante entender os recursos do Typer (o que pode e o que não pode) para documentar corretamente o contrato de inicialização — a implementação em si a IA faz, mas o contrato (argumentos, opções, comportamento) precisa estar bem especificado.

### `executar()` sem `input()` — recebe parâmetros diretamente

Comparando com a aula anterior, a única mudança estrutural relevante é que `executar()` passa a receber `pergunta` e `namespace` como parâmetros de função, em vez de coletar a pergunta via `input()`. Toda a lógica de `MCPAdapter`, listagem de tools e `create_agent` permanece igual.

```python
async def executar(pergunta: str, namespace: str | None = None) -> str:
    load_dotenv()

    if not os.getenv("ANTHROPIC_API_KEY"):
        raise ConfigurationError(
            "Configure ANTHROPIC_API_KEY no arquivo .env antes de executar."
        )

    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))
    solicitacao = compor_solicitacao(pergunta, namespace)

    async with MCPAdapter(mcp_config()) as adapter:
        tools = await adapter.list_tools()
        print(f"Catálogo MCP: {len(tools)} ferramentas", file=sys.stderr, flush=True)
        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)
        resultado = await agent.ainvoke({"messages": [("human", solicitacao)]})

    return resultado["messages"][-1].text
```

### `compor_solicitacao` — injetando o namespace como contexto adicional

```python
def compor_solicitacao(pergunta: str, namespace: str | None) -> str:
    if namespace:
        return f"{pergunta}\nContexto adicional: namespace Kubernetes {namespace}."
    return pergunta
```

O namespace informado via CLI não é passado "por fora" para o MCP — ele é **concatenado na própria pergunta** como contexto adicional, dentro do texto enviado ao agente. É o agente que usa essa informação para filtrar o escopo da consulta no cluster.

### `@app.command()` — declarando o comando principal com Typer

```python
app = typer.Typer(add_completion=False)

@app.command()
def main(
    pergunta: Annotated[str, typer.Argument(help="solicitação em linguagem natural")],
    namespace: Annotated[
        str | None,
        typer.Option(help="namespace usado como contexto adicional da solicitação"),
    ] = None,
) -> None:
    """Consulta o Kubernetes em linguagem natural por meio de um agente."""
    try:
        resposta = asyncio.run(executar(pergunta, namespace))
    except ConfigurationError as error:
        print(f"Erro de configuração: {error}", file=sys.stderr)
        raise typer.Exit(1) from error
    except Exception as error:
        print(f"Falha durante a execução: {type(error).__name__}", file=sys.stderr)
        raise typer.Exit(1) from error

    print(resposta)

if __name__ == "__main__":
    app()
```

Pontos-chave:
- `typer.Typer()` cria a aplicação CLI; `@app.command()` marca `main` como o comando de inicialização.
- `typer.Argument(...)` define `pergunta` como um **argumento posicional obrigatório** (passado direto, sem flag).
- `typer.Option(...)` define `namespace` como uma **opção nomeada** (`--namespace valor`), opcional (default `None`).
- O texto passado em `help=` de cada parâmetro alimenta automaticamente a ajuda (`--help`) gerada pelo Typer — não é preciso escrever a documentação de uso manualmente.
- Tratamento de erros explícito: `ConfigurationError` (erro de configuração, ex.: variável de ambiente ausente) e qualquer outra `Exception` (falha durante execução) são capturadas separadamente, cada uma terminando o processo com `typer.Exit(1)` e uma mensagem em `stderr`.

### Execução e comportamento observado

```bash
cd 07-assistente-plataforma-cli
uv sync

uv run assistente-plataforma-cli "Liste os pods em execução" --namespace default
# → nenhum pod listado (namespace default vazio)

uv run assistente-plataforma-cli "Liste os pods em execução" --namespace kube-system
# → lista os pods existentes nesse namespace (demora um pouco mais, pois há mais pods)
```

A diferença de comportamento entre os dois namespaces confirma que o contexto adicional (`compor_solicitacao`) está realmente direcionando o agente a filtrar a consulta pelo namespace certo.

```bash
uv run assistente-plataforma-cli --help
```

A ajuda gerada automaticamente lista o argumento `pergunta` (marcado como obrigatório, "solicitação em linguagem natural") e a opção `--namespace` ("namespace usado como contexto adicional da solicitação") — exatamente os textos declarados em `help=` no código.

### Por que isso importa para DevOps e automação

Uma interface de CLI bem estruturada (com argumentos e opções claros) é o que permite plugar um agente de IA dentro de uma pipeline, de um script de automação, ou de qualquer outro processo não-interativo — passando todos os parâmetros necessários em um único comando, sem esperar entrada do usuário durante a execução. Essa é a motivação central de toda a aula.

### Gancho para a próxima aula: interface humana ≠ interface de automação

O instrutor fecha fazendo a distinção importante: CLI é ótimo para automação e pipelines, mas não é a interface certa quando o objetivo é interação humana direta com o agente — nesse caso, uma interface web/gráfica faz mais sentido. É o tema da próxima aula: abandonar o terminal e trabalhar com interface web.

## Comandos e configurações

```bash
# Tentativa que falha com a versão sem CLI (06-assistente-plataforma)
uv run assistente-plataforma "Liste os pods do cluster"
```

```bash
# 07-assistente-plataforma-cli
uv sync
uv run assistente-plataforma-cli "Liste os pods em execução" --namespace default
uv run assistente-plataforma-cli "Liste os pods em execução" --namespace kube-system
uv run assistente-plataforma-cli --help
```

```python
# src/app.py (07-assistente-plataforma-cli, resumido)
import asyncio
import os
import sys
from typing import Annotated

import typer
from dotenv import load_dotenv

from langchain.agents import create_agent
from langchain.mcp import MCPAdapter
from langchain_anthropic import ChatAnthropic

from src.tools import ConfigurationError, mcp_config

SYSTEM_PROMPT = """
Você é um assistente de plataforma que consulta o estado do Kubernetes usando as ferramentas
disponíveis. Nunca altere recursos, consulte Secrets ou revele credenciais. Se uma informação não
estiver disponível, diga que não sabe.
"""

def compor_solicitacao(pergunta: str, namespace: str | None) -> str:
    if namespace:
        return f"{pergunta}\nContexto adicional: namespace Kubernetes {namespace}."
    return pergunta

async def executar(pergunta: str, namespace: str | None = None) -> str:
    load_dotenv()

    if not os.getenv("ANTHROPIC_API_KEY"):
        raise ConfigurationError(
            "Configure ANTHROPIC_API_KEY no arquivo .env antes de executar."
        )

    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))
    solicitacao = compor_solicitacao(pergunta, namespace)

    async with MCPAdapter(mcp_config()) as adapter:
        tools = await adapter.list_tools()
        print(f"Catálogo MCP: {len(tools)} ferramentas", file=sys.stderr, flush=True)
        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)
        resultado = await agent.ainvoke({"messages": [("human", solicitacao)]})

    return resultado["messages"][-1].text

app = typer.Typer(add_completion=False)

@app.command()
def main(
    pergunta: Annotated[str, typer.Argument(help="solicitação em linguagem natural")],
    namespace: Annotated[
        str | None,
        typer.Option(help="namespace usado como contexto adicional da solicitação"),
    ] = None,
) -> None:
    """Consulta o Kubernetes em linguagem natural por meio de um agente."""
    try:
        resposta = asyncio.run(executar(pergunta, namespace))
    except ConfigurationError as error:
        print(f"Erro de configuração: {error}", file=sys.stderr)
        raise typer.Exit(1) from error
    except Exception as error:
        print(f"Falha durante a execução: {type(error).__name__}", file=sys.stderr)
        raise typer.Exit(1) from error

    print(resposta)

if __name__ == "__main__":
    app()
```

## Pegadinhas

- Passar a pergunta como argumento posicional direto numa CLI que ainda usa `input()` simplesmente não funciona — é preciso reestruturar a aplicação com uma biblioteca de CLI (Typer) para aceitar parâmetros de inicialização.
- O namespace não é enviado "separadamente" ao MCP/agente — ele entra como texto concatenado na própria pergunta (`compor_solicitacao`), então a qualidade da resposta depende do agente interpretar corretamente esse contexto adicional dentro da mensagem.
- Erros de configuração (`ConfigurationError`) e falhas de execução genéricas (`Exception`) são tratados em blocos `except` separados, cada um com sua própria mensagem — misturar os dois tipos perderia a clareza de diagnóstico ao rodar em pipeline.
- CLI é a interface certa para automação/pipeline, não necessariamente para uso humano direto — o instrutor é explícito sobre essa distinção de público antes de passar para a próxima aula.

## Dúvidas para revisar

- Como estruturar múltiplos comandos Typer (`@app.command()` repetido) no mesmo app, por exemplo, um comando para consultar pods e outro para consultar nodes, cada um com seus próprios argumentos/opções?
- Vale a pena documentar o contrato de uma CLI feita com Typer (argumentos, opções, exit codes) em um ADR/TRD antes de pedir a implementação para a IA, como sugerido na aula — como isso ficaria formalizado?
- Como adaptar essa mesma CLI para rodar dentro de uma pipeline de CI/CD, capturando o `stdout` (resposta) e o `exit code` para decisões automatizadas?
