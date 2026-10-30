# Agente LangChain Consumindo MCP via HTTP

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 09 — Agente LangChain Consumindo MCP via HTTP (21:18) |
| **Assunto** | Testar o MCP Server próprio com MCP Inspector, e migrar o agente `09-inventario-droplets` (tool LangChain) para `11-inventario-droplets-mcp` (MCPAdapter), em one-shot, sem SDD |
| **Data** | 30/10/2026 01:15 |
| **Tags** | mcp-inspector, docker-compose, mcp-adapter, streamable-http, one-shot, plan-mode, migracao-de-ferramenta |

## Resumo da aula

Aula final do capítulo: fecha o ciclo testando de fato o MCP Server construído nas aulas 05–08 (via MCP Inspector) e, em seguida, migrando o agente LangChain de Droplets (projeto `09-inventario-droplets`, que usava uma tool local) para consumir esse mesmo MCP Server via `MCPAdapter` — criando o projeto `11-inventario-droplets-mcp`. Diferente das aulas de construção do MCP (que usaram SDD completo com OpenSpec), essa migração do lado do agente é feita **em one-shot**, sem Spec Driven Development, por ser uma alteração simples e pontual.

## Conceitos principais

### Massa de teste própria antes de validar

Antes de testar, o instrutor criou sua própria massa de dados na DigitalOcean (um banco de dados gerenciado, um cluster Kubernetes, vários Droplets) — reforçando que cada pessoa deve criar sua própria massa de teste, não replicar exatamente a do instrutor, para efetivamente validar o comportamento com dados próprios.

### Subindo o MCP Server via Docker Compose

```bash
docker compose up -d --build
```

A forma mais simples de rodar o MCP (já preparado desde o boilerplate para suportar Docker) é via `docker compose`, habilitando o transporte HTTP (em vez de STDIO).

### Por que abrir a URL do MCP no browser não funciona

```text
http://localhost:8000/mcp
```

Abrir essa URL direto no navegador retorna erro de "método não permitido" — o endpoint fala o **protocolo MCP**, não responde a um GET HTTP comum. É necessária uma ferramenta que converse nesse protocolo para testar de fato.

### MCP Inspector — testando o MCP Server construído

```bash
npx @modelcontextprotocol/inspector
```

Ferramenta oficial do projeto MCP, já usada em aulas anteriores do curso (módulo de agentes de codificação), roda via `npx` e abre uma interface web. O servidor foi adicionado manualmente:

```text
Nome: digitalocean
Transporte: Streamable HTTP
URL: http://localhost:8000/mcp
```

Depois de conectar, a aba de **tools** listou as cinco ferramentas construídas (listagem de Droplets, shutdown, power-on, listagem de clusters K8s, listagem de bancos de dados); **resources** e **prompts** apareceram vazios, já que o projeto só implementou tools.

### Testes manuais no Inspector — confirmando cada comportamento do PRD

- `list_droplets` sem filtros → todos os Droplets.
- `list_droplets` com `region=<slug>` → só os da região.
- `list_droplets` com `status=off` → nenhum (confirmando que nenhum Droplet estava desligado ainda).
- `shutdown_droplet` com um `droplet_id` → pedido de desligamento aceito.
- `list_droplets` com `status=off` novamente → o Droplet recém-desligado aparece — confirmando na prática o comportamento assíncrono especificado no PRD 002 (aula 07): o aceite é imediato, a mudança de estado é observada depois, via nova consulta.
- `list_kubernetes_clusters` e a tool de bancos gerenciados → cada um retornando os recursos da conta.

Esse é o momento em que todo o comportamento especificado nos três PRDs (aulas 05–08) é validado de ponta a ponta, manualmente, antes de conectar qualquer agente.

### Migrando o agente: de tool LangChain para MCP

```bash
cp -r 09-inventario-droplets 11-inventario-droplets-mcp
```

O projeto `09-inventario-droplets` (construído nas aulas 02–04 deste capítulo, com a tool LangChain `listar_droplets`) foi copiado para `11-inventario-droplets-mcp`, como ponto de partida para a migração.

### Pedido ao agente de codificação — alteração única, sem SDD

```text
Esse projeto foi desenvolvido utilizando uma tool de LangChain, fazendo toda a conexão com a conta
da DigitalOcean e listando os droplets. Agora eu quero que ele use um MCP server que eu mesmo
desenvolvi. Esse MCP está disponibilizado na URL http://localhost:8000/mcp. Altere o agente de IA
para ter suporte a todas as ferramentas disponíveis no MCP Server.
```

Feito em **Plan Mode**, com a URL do MCP deliberadamente colada no final para que o próprio agente de codificação investigasse o servidor (via MCP Inspector/consulta direta) e descobrisse as ferramentas disponíveis — sem que o instrutor precisasse listá-las manualmente no prompt.

Durante o planejamento, o agente perguntou o que fazer com as ferramentas LangChain locais que já existiam — resposta: **removê-las**. O plano apresentado identificou corretamente: a pasta era uma cópia não versionada do projeto 09; o agente local falava com a DigitalOcean via PyDO; o objetivo era substituir por todas as ferramentas do MCP Server próprio (`http://localhost:8000/mcp`, Streamable HTTP, sem autenticação nesse ambiente de teste).

### Código resultante: `src/app.py` do exemplo 11

```python
import argparse
import asyncio
import os

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain.mcp import MCPAdapter
from langchain_anthropic import ChatAnthropic

load_dotenv()

if not os.getenv("ANTHROPIC_API_KEY"):
    raise SystemExit("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")

MCP_CONFIG = {
    "mcpServers": {
        "digitalocean": {
            "transport": "http",
            "url": os.getenv("MCP_URL", "http://localhost:8000/mcp"),
        }
    }
}

SYSTEM_PROMPT = """
Você é um assistente de operações que consulta a conta DigitalOcean usando as ferramentas
disponíveis. Não invente recursos. Só ligue ou desligue um Droplet quando o usuário pedir
explicitamente.
Você é especialista em DigitalOcean.
"""

async def executar(pergunta: str) -> None:
    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

    async with MCPAdapter(MCP_CONFIG) as adapter:
        tools = await adapter.list_tools()

        print("Ferramentas MCP disponíveis:")
        for tool in tools:
            print(f"- {tool.name}")

        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)

        print(f"\nPergunta: {pergunta}\n")

        resultado = await agent.ainvoke({"messages": [("human", pergunta)]})

        print("Resposta:")
        print(resultado["messages"][-1].text)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Consulta a conta DigitalOcean usando as ferramentas de um MCP server."
    )
    parser.add_argument("pergunta", help='Ex.: "Quais Droplets estão ativos?"')
    args = parser.parse_args()

    asyncio.run(executar(args.pergunta))

if __name__ == "__main__":
    main()
```

### A diferença central entre a versão LangChain e a versão MCP

Comparando `app.py` dos exemplos 9 e 11: no exemplo 9, o agente aponta diretamente para a tool `listar_droplets` (implementação própria LangChain, chamando PyDO); no exemplo 11, o agente usa `MCPAdapter` para se conectar ao MCP Server (mesmo padrão já usado no agente de Kubernetes da aula 05 do capítulo "Primeiros Agentes"), lista as tools publicadas (`adapter.list_tools()`), e passa essa lista inteira ao `create_agent`. O resto do fluxo (`ainvoke`, montagem da resposta) é idêntico. Ponto importante: o agente LangChain **não precisa mais de nenhuma credencial da DigitalOcean** — o `DIGITALOCEAN_TOKEN` fica só no `.env` do MCP Server; o agente só precisa de `ANTHROPIC_API_KEY`, opcionalmente `MODELO` e `MCP_URL`.

### Execuções de teste — comportamento one-shot e encadeamento de tools

```bash
uv run src/app.py "Quantos clusters k8s eu tenho na minha conta?"
uv run src/app.py "Quantas máquinas virtuais eu tenho na conta?"
uv run src/app.py "Quero que desligue a máquina aula-api-sfo"
```

- Primeira pergunta: resposta correta, identificando o cluster `DigitalOceanKS` da conta.
- O instrutor observa explicitamente que essa aplicação é **one-shot**: cada execução não mantém memória da anterior — a aplicação é encerrada ao fim de cada resposta. Evoluir isso exigiria adicionar uma interface (CLI persistente, chat) e gerenciamento de janela de contexto, como já visto em aulas anteriores do curso.
- Terceira pergunta, a mais interessante: o usuário passou o **nome** do Droplet (`aula-api-sfo`), não o ID — mas a tool de shutdown exige o ID (regra definida no PRD 002). O agente, sem instrução adicional, **encadeou as tools sozinho**: primeiro chamou `list_droplets` para encontrar o ID correspondente ao nome informado, e só então chamou `shutdown_droplet` com o ID correto — demonstrando exatamente o comportamento de agente autônomo decidindo a sequência de chamadas de ferramenta em tempo de execução, sem workflow determinístico programado para isso. O resultado foi confirmado no painel da DigitalOcean: o Droplet realmente apareceu desligado.

### Encerramento do capítulo

O instrutor fecha reforçando que agora o aluno conhece as **duas formas** de conectar ferramentas a um agente: implementação nativa em LangChain, e via MCP Server próprio — e que o próximo passo é prático: construir os próprios MCP Servers e conectá-los aos próprios agentes.

## Comandos e configurações

```bash
docker compose up -d --build
docker container ls
```

```bash
npx @modelcontextprotocol/inspector
```

```text
# Configuração manual no Inspector
Nome: digitalocean
Transporte: Streamable HTTP
URL: http://localhost:8000/mcp
```

```bash
cp -r 09-inventario-droplets 11-inventario-droplets-mcp
```

```text
# Pedido ao agente de codificação (Plan Mode)
Esse projeto foi desenvolvido utilizando uma tool de LangChain, fazendo toda a conexão com a conta
da DigitalOcean e listando os droplets. Agora eu quero que ele use um MCP server que eu mesmo
desenvolvi. Esse MCP está disponibilizado na URL http://localhost:8000/mcp. Altere o agente de IA
para ter suporte a todas as ferramentas disponíveis no MCP Server.
```

```bash
uv run src/app.py "Quantos clusters k8s eu tenho na minha conta?"
uv run src/app.py "Quantas máquinas virtuais eu tenho na conta?"
uv run src/app.py "Quero que desligue a máquina aula-api-sfo"
```

```python
# src/app.py (exemplo 11, completo)
import argparse
import asyncio
import os

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain.mcp import MCPAdapter
from langchain_anthropic import ChatAnthropic

load_dotenv()

if not os.getenv("ANTHROPIC_API_KEY"):
    raise SystemExit("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")

MCP_CONFIG = {
    "mcpServers": {
        "digitalocean": {
            "transport": "http",
            "url": os.getenv("MCP_URL", "http://localhost:8000/mcp"),
        }
    }
}

SYSTEM_PROMPT = """
Você é um assistente de operações que consulta a conta DigitalOcean usando as ferramentas
disponíveis. Não invente recursos. Só ligue ou desligue um Droplet quando o usuário pedir
explicitamente.
Você é especialista em DigitalOcean.
"""

async def executar(pergunta: str) -> None:
    model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

    async with MCPAdapter(MCP_CONFIG) as adapter:
        tools = await adapter.list_tools()

        print("Ferramentas MCP disponíveis:")
        for tool in tools:
            print(f"- {tool.name}")

        agent = create_agent(model=model, tools=tools, system_prompt=SYSTEM_PROMPT)

        print(f"\nPergunta: {pergunta}\n")

        resultado = await agent.ainvoke({"messages": [("human", pergunta)]})

        print("Resposta:")
        print(resultado["messages"][-1].text)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Consulta a conta DigitalOcean usando as ferramentas de um MCP server."
    )
    parser.add_argument("pergunta", help='Ex.: "Quais Droplets estão ativos?"')
    args = parser.parse_args()

    asyncio.run(executar(args.pergunta))

if __name__ == "__main__":
    main()
```

## Pegadinhas

- Abrir a URL de um MCP Server HTTP direto no navegador sempre retorna erro de método — o protocolo MCP não é um GET HTTP comum; é preciso usar um cliente MCP (MCP Inspector, ou um agente real) para testar.
- Migrar de tool LangChain para MCP remove **toda** necessidade de credencial de cloud no lado do agente — o token (`DIGITALOCEAN_TOKEN`) fica isolado no `.env` do MCP Server; o agente LangChain só precisa de `ANTHROPIC_API_KEY` e da URL do MCP. Isso reduz a superfície de exposição de segredos no código do agente.
- Uma aplicação one-shot (como os exemplos deste capítulo) não mantém contexto entre execuções — cada chamada de `uv run src/app.py "pergunta"` é isolada; se o usuário faz uma segunda pergunta referenciando a primeira, o agente não terá esse contexto, a menos que a aplicação seja evoluída com uma camada de histórico (CLI persistente, chat).
- Quando uma tool de ação exige um identificador (ID) que o usuário não forneceu diretamente (ex.: deu o nome em vez do ID), um agente bem instruído com acesso às tools de consulta pode encadear chamadas sozinho (consultar primeiro, agir depois) — mas isso depende do agente ter acesso à tool de consulta e da tarefa ser resolvível nesse encadeamento; não é garantido em todos os casos.
- Alterações pontuais e bem definidas (como trocar a fonte de uma ferramenta) não exigem necessariamente todo o ritual de Spec Driven Development com OpenSpec — o instrutor optou por uma alteração em one-shot, via Plan Mode, justamente porque o escopo era simples e bem contido.

## Dúvidas para revisar

- Como evoluir o exemplo 11 (one-shot) para manter histórico de conversa entre perguntas, reaproveitando os padrões de `st.session_state` (Streamlit) ou histórico manual já vistos no capítulo "Primeiros Agentes"?
- Em um MCP Server de produção, como lidar com a ausência de autenticação no transporte HTTP usada neste exemplo didático (`sem autenticação`) — qual seria o próximo passo de hardening?
- Vale a pena, como exercício, repetir essa migração para outro conjunto de ferramentas (ex.: o agente de pesquisa web com Tavily, aula 04) — convertendo uma ferramenta pronta em uma implementação MCP própria, só para fixar o padrão de migração?
