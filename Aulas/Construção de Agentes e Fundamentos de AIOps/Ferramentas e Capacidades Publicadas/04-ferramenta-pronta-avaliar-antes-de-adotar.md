# Ferramenta Pronta: Avaliar Antes de Adotar

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 04 — Ferramenta Pronta: Avaliar Antes de Adotar (15:27) |
| **Assunto** | Usar uma ferramenta LangChain já publicada (`TavilySearch`, busca na web) em vez de implementar do zero, e os cuidados de segurança antes de adotar uma ferramenta de terceiros |
| **Data** | 30/10/2026 01:15 |
| **Tags** | langchain-integrations, tavily, ferramenta-pronta, seguranca, busca-web, nao-reinventar-a-roda |

## Resumo da aula

Depois de construir uma ferramenta do zero (inventário de Droplets), a aula mostra o outro lado da moeda: nem toda ferramenta precisa ser criada do zero — o LangChain mantém um catálogo extenso de integrações/ferramentas prontas (documentação oficial), cobrindo categorias como produtividade, banco de dados, finanças, e busca na web. A demonstração prática usa o **TavilySearch**, do pacote `langchain-tavily`, para dar a um agente a capacidade de pesquisar na internet — construindo um "assistente de pesquisa sobre DevOps e cloud" em poucas linhas de código, sem implementar nenhuma lógica de busca própria.

## Conceitos principais

### Catálogo de integrações do LangChain — não reinventar a roda

A documentação do LangChain tem uma seção de integrações com dezenas de ferramentas prontas: conexão com Amazon Bedrock, Google Search, Gmail, bancos de dados, finanças, web browsing, entre outras — algumas pagas, outras gratuitas ou com free tier. A recomendação central da aula: antes de implementar uma ferramenta própria, vale a pena verificar se já existe algo pronto que atenda a necessidade — tanto no catálogo oficial do LangChain quanto em projetos open source da comunidade.

### Cuidado de segurança ao adotar ferramentas de terceiros

Mesmo recomendando reaproveitar ferramentas prontas, o instrutor reforça a mesma cautela já mencionada para MCP Servers de terceiros: é preciso verificar se o código é seguro antes de conectá-lo a um agente — se não há nada malicioso enviando informações para terceiros, uso indevido de processamento, etc. Ferramentas listadas na documentação oficial do LangChain são, de forma geral, consideradas confiáveis — mas a avaliação de segurança não deve ser pulada em nenhum caso, especialmente com pacotes fora do catálogo oficial.

### Tavily — serviço de busca voltado a agentes de IA

Tavily é descrito como um serviço bastante usado não só com LangChain, mas também em ferramentas low-code como n8n — propõe-se especificamente a conectar agentes de IA à internet, fornecendo busca e visualização de páginas. É um serviço pago, mas com camada gratuita suficiente para testes e projetos pequenos (o instrutor relata nunca ter pagado, usando a conta gratuita para buscas pessoais de notícias).

### `TavilySearch` — a ferramenta pronta em código

```python
import argparse
import os
from datetime import date

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic
from langchain_tavily import TavilySearch

load_dotenv()

for chave in ("ANTHROPIC_API_KEY", "TAVILY_API_KEY"):
    if not os.getenv(chave):
        raise SystemExit(f"Configure {chave} no arquivo .env antes de executar.")

SYSTEM_PROMPT = f"""
Você é um assistente de pesquisa sobre DevOps e cloud.
A data de hoje é {date.today().isoformat()}.
Use a ferramenta disponível para responder e cite as fontes que consultou.
"""

# A ferramenta pronta: vem do pacote e usa a TAVILY_API_KEY.
busca = TavilySearch(max_results=5)

model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

agent = create_agent(
    model=model,
    tools=[busca],
    system_prompt=SYSTEM_PROMPT,
)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Pesquisa sobre DevOps e cloud usando uma ferramenta pronta."
    )
    parser.add_argument("pergunta")
    args = parser.parse_args()

    print(f"Pergunta: {args.pergunta}\n")

    resultado = agent.invoke({"messages": [("human", args.pergunta)]})

    # A ferramenta pronta não tem corpo nosso para imprimir a chamada:
    # a chamada pedida pelo modelo é lida das mensagens.
    # Esses argumentos são o que sai do seu ambiente e vai para o Tavily.
    for mensagem in resultado["messages"]:
        for chamada in getattr(mensagem, "tool_calls", []):
            print(f"Ferramenta: {chamada['name']}({chamada['args']})")

    print("\nResposta:")
    print(resultado["messages"][-1].text)

if __name__ == "__main__":
    main()
```

Pontos-chave:
- `TavilySearch(max_results=5)` já vem pronta, encapsulada para LangChain, com autenticação via `TAVILY_API_KEY` — nenhuma função `@tool` própria é escrita; o objeto `busca` já é uma tool válida, usada diretamente em `tools=[busca]`.
- Por debaixo dos panos, funciona de forma análoga à ferramenta `listar_droplets` (que fazia chamadas à API da DigitalOcean): a diferença é que, aqui, toda essa implementação de chamada de API já vem embutida no pacote.
- Como a ferramenta pronta não tem código próprio para imprimir a chamada feita (diferente de `consultar_droplets`, que tinha um `print` manual), o código lê as chamadas de ferramenta diretamente das mensagens retornadas pelo agente (`mensagem.tool_calls`) — útil para auditoria/observabilidade de uma ferramenta "caixa-preta".

### System Prompt com a data atual — contexto temporal para busca

```python
SYSTEM_PROMPT = f"""
Você é um assistente de pesquisa sobre DevOps e cloud.
A data de hoje é {date.today().isoformat()}.
Use a ferramenta disponível para responder e cite as fontes que consultou.
"""
```

Injetar a data atual no System Prompt orienta o modelo a formular buscas mais "temporalmente assertivas" — ex.: incluir o ano atual na query de busca em vez de usar um ano desatualizado do próprio conhecimento do modelo. O instrutor pondera que, numa aplicação de produção que roda continuamente, seria mais robusto usar uma **ferramenta** para o agente consultar a data em tempo real, em vez de fixá-la no System Prompt no momento da inicialização — mas para o exemplo didático, a abordagem simples foi suficiente.

### `pyproject.toml` — dependência do pacote da ferramenta pronta

```toml
[project]
name = "pesquisa-web-devops"
version = "0.1.0"
description = "Exemplo didatico: ferramenta pronta de busca na web (Tavily) no agente"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "langchain>=1.4.3",
    "langchain-anthropic>=1.7.5",
    "langchain-tavily>=0.2.18",
    "python-dotenv>=1.2.4",
]

[project.scripts]
pesquisa-web-devops = "src.app:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src"]
```

O pacote `langchain-tavily` entra como qualquer outra dependência — não há diferença estrutural entre consumir uma ferramenta pronta e uma biblioteca comum.

### Execução e comportamento observado

```bash
cd 10-pesquisa-web-devops
uv run src/app.py "O que é Kubernetes e AIOps? Como eles se conectam? Posso usar um e o outro juntos?"
```

O agente realizou **três buscas** distintas (visíveis nas linhas `Ferramenta: tavily_search(...)`), cada uma incluindo o ano atual na query (por conta da data injetada no System Prompt) — por exemplo, "o que é Kubernetes, definição e conceitos de 2026" e "como AIOps e Kubernetes se integram". A resposta final sintetizou as buscas em uma explicação de Kubernetes (orquestração de containers, reconciliação automática, uso crescente também para bancos de dados em 2026) e de AIOps (IA/ML aplicada a operações de TI, incluindo uso crescente de LLMs/agentes sobre telemetria para detecção, correlação, triagem e remediação de incidentes), encerrando com a lista de fontes consultadas — cumprindo a instrução do System Prompt de citar as fontes.

### A lição central: mix entre ferramentas próprias e prontas

O instrutor fecha reforçando que, na prática, o desenvolvedor vai fazer um **mix**: criar ferramentas próprias quando necessário (como o inventário de Droplets), e reaproveitar ferramentas prontas do ecossistema (LangChain, comunidade open source) sempre que possível — isso vale tanto para tools LangChain quanto, como será visto nas próximas aulas, para MCP Servers construídos do zero.

## Comandos e configurações

```bash
# .env
# Copie para .env e preencha — o .env está no .gitignore e nunca deve ser commitado.
ANTHROPIC_API_KEY=sua-chave-aqui

# Chave da ferramenta pronta de busca. Crie em https://app.tavily.com
TAVILY_API_KEY=sua-chave-aqui

MODELO=claude-sonnet-5
```

```bash
cd 10-pesquisa-web-devops
uv run src/app.py "O que é Kubernetes e AIOps? Como eles se conectam? Posso usar um e o outro juntos?"
```

```python
# src/app.py
import argparse
import os
from datetime import date

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic
from langchain_tavily import TavilySearch

load_dotenv()

for chave in ("ANTHROPIC_API_KEY", "TAVILY_API_KEY"):
    if not os.getenv(chave):
        raise SystemExit(f"Configure {chave} no arquivo .env antes de executar.")

SYSTEM_PROMPT = f"""
Você é um assistente de pesquisa sobre DevOps e cloud.
A data de hoje é {date.today().isoformat()}.
Use a ferramenta disponível para responder e cite as fontes que consultou.
"""

busca = TavilySearch(max_results=5)

model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

agent = create_agent(
    model=model,
    tools=[busca],
    system_prompt=SYSTEM_PROMPT,
)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Pesquisa sobre DevOps e cloud usando uma ferramenta pronta."
    )
    parser.add_argument("pergunta")
    args = parser.parse_args()

    print(f"Pergunta: {args.pergunta}\n")

    resultado = agent.invoke({"messages": [("human", args.pergunta)]})

    for mensagem in resultado["messages"]:
        for chamada in getattr(mensagem, "tool_calls", []):
            print(f"Ferramenta: {chamada['name']}({chamada['args']})")

    print("\nResposta:")
    print(resultado["messages"][-1].text)

if __name__ == "__main__":
    main()
```

## Pegadinhas

- Fixar a data atual diretamente no System Prompt funciona bem para um script executado pontualmente, mas é frágil para uma aplicação de longa duração (a data fica "congelada" no momento da inicialização do processo) — para esse cenário, uma ferramenta que consulte a data em tempo real é mais robusta.
- Com uma ferramenta pronta, não há corpo de código próprio para instrumentar/logar as chamadas internamente — a única forma de auditar o que foi enviado para o serviço externo é ler os `tool_calls` nas mensagens retornadas pelo agente, após a execução.
- Nem toda ferramenta listada na documentação do LangChain tem o mesmo nível de confiança ou suporte — algumas vêm de projetos de terceiros/comunidade; a avaliação de segurança antes de conectar qualquer ferramenta de terceiros a um agente é indispensável, exatamente como já reforçado para MCP Servers externos.
- Ferramentas de busca pagas geralmente têm camada gratuita limitada por número de chamadas/mês — vale monitorar o uso para não ser surpreendido por limites ou custo.

## Dúvidas para revisar

- Quais critérios objetivos usar para decidir entre adotar uma ferramenta pronta (ex.: TavilySearch) e implementar uma própria, quando ambas resolvem o mesmo problema (ex.: busca na web)?
- Como auditar de forma sistemática o código de uma ferramenta de terceiros antes de conectá-la a um agente de produção — existe uma checklist de segurança recomendável?
- Faria sentido, no projeto de pesquisa web, trocar a data fixa no System Prompt por uma ferramenta própria de "obter data atual", e como isso mudaria o comportamento do agente em uma aplicação de longa duração?
