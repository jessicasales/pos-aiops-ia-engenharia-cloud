# Primeira Ferramenta no Agente

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 04 — Primeira Ferramenta no Agente (19:25) |
| **Assunto** | Criação de uma `tool` com `@tool` do LangChain para o agente consultar runbooks dinamicamente, substituindo a injeção fixa de contexto da aula anterior |
| **Data** | 30/10/2026 01:15 |
| **Tags** | tool, langchain-tools, create_agent, consultar_runbook, mcp, memoria-de-longo-prazo, agente-autonomo |

## Resumo da aula

Evolução direta da aula anterior: em vez de carregar o runbook inteiro e injetá-lo fixo no prompt (abordagem "engessada"), o agente agora recebe uma **ferramenta** (`tool`) que ele mesmo decide chamar, em tempo real, para consultar o runbook correto conforme o ID informado na pergunta. É a primeira vez no curso que o agente sai de um fluxo determinístico (sempre a mesma informação no prompt) para um fluxo onde ele decide, dinamicamente, quando e como buscar uma informação externa — o comportamento central que diferencia um agente de uma simples chamada de chat. O projeto de referência é `05-agente-runbook-tool` (comparado lado a lado com `04-agente-runbook`, da aula anterior), ambos no repositório público `KubeDev/exemplos-langchain-devops`.

## Conceitos principais

### Tool — o recurso central de um agente autônomo

Uma **tool** (ferramenta) é um componente do harness de um agente que o conecta a um recurso ou informação externa — uma chamada de API, uma consulta a banco de dados, a leitura de um arquivo, etc. É o mesmo recurso já usado em ferramentas de codificação como Claude Code e Codex. No LangChain, toda tool é uma função Python simples marcada com o decorator `@tool`.

### System Prompt muito mais enxuto com tool

Comparando os dois projetos:
- **Sem tool** (`04-agente-runbook`): o System Prompt carrega a variável `{contexto}` com o runbook inteiro colado dentro; o prompt completo é montado via `ChatPromptTemplate` e passado ao `invoke`.
- **Com tool** (`05-agente-runbook-tool`): o System Prompt não carrega mais nenhum conteúdo de runbook — só orienta o agente a usar a ferramenta `consultar_runbook` quando a pergunta mencionar um runbook interno. O prompt fica "muito mais otimizado, direcionado realmente ao que ele deve fazer".

### `create_agent` recebendo `tools` e `system_prompt` diretamente

```python
model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

agent = create_agent(
    model=model,
    tools=[consultar_runbook],
    system_prompt=SYSTEM_PROMPT,
)
```

Diferente da aula anterior (`tools=[]`, prompt completo montado via `ChatPromptTemplate` e enviado no `invoke`), aqui o `create_agent` recebe o `system_prompt` como parâmetro próprio, e a lista `tools` com a função real. A chamada final fica simples:

```python
resultado = agent.invoke({"messages": [("human", pergunta)]})
```

### ID do runbook como parâmetro dinâmico (via CLI)

A pergunta não contém mais o runbook inteiro, só o **ID**, recebido via argumento de linha de comando (`argparse`) e formatado na string da pergunta:

```python
PERGUNTA = "Analise o runbook {runbook_id}, de um resumo em 1 parágrafo."
...
pergunta = PERGUNTA.format(runbook_id=args.runbook_id)
```

Isso é o que torna a consulta dinâmica: vários runbooks diferentes (`RB-274`, `RB-381`, `RB-905`) passam a estar disponíveis, e o agente decide qual carregar.

### Anatomia da tool `consultar_runbook`

```python
from pathlib import Path

from langchain.tools import tool
from langchain_community.document_loaders import TextLoader

RUNBOOKS_PATH = Path(__file__).resolve().parent.parent / "dados" / "runbooks"
RUNBOOKS = {
    "RB-274": RUNBOOKS_PATH / "RB-274.md",
    "RB-381": RUNBOOKS_PATH / "RB-381.md",
    "RB-905": RUNBOOKS_PATH / "RB-905.md",
}

@tool
def consultar_runbook(runbook_id: str) -> str:
    """Carrega um runbook interno pelo identificador informado na pergunta.

    Args:
        runbook_id: Identificador do runbook, como RB-274, RB-381 ou RB-905.
    """
    runbook_id = runbook_id.upper()
    print(f"Ferramenta: consultar_runbook(runbook_id={runbook_id!r})")

    caminho = RUNBOOKS.get(runbook_id)

    if caminho is None:
        return f"Runbook {runbook_id} não encontrado."

    loader = TextLoader(caminho, encoding="utf-8")
    documentos = loader.load()

    return "\n\n".join(documento.page_content for documento in documentos)
```

Pontos-chave:
- Uma tool é **só uma função** que recebe (ou não) parâmetros e retorna um resultado — pode ser uma chamada de API, um SELECT no banco, qualquer coisa.
- O decorator `@tool` sinaliza ao LangChain que aquela função é uma ferramenta disponível para o agente.
- A **docstring** (entre `"""..."""`) não é um comentário qualquer: é a descrição que o agente lê, no momento da inicialização, para saber **o que** a ferramenta faz e **quais argumentos** ela espera. Sem essa documentação, o agente não sabe quando nem como chamá-la.
- `RUNBOOKS` é um dicionário que mapeia cada ID ao caminho do arquivo Markdown correspondente; um ID fora do catálogo retorna a string "Runbook {id} não encontrado" — e é o próprio agente que recebe essa informação e monta a resposta final a partir dela.

### Boa prática: separar a tool em arquivo próprio

A função foi colocada em `src/tools.py`, separado do `app.py`, e importada com `from src.tools import consultar_runbook`. O instrutor reforça que isso não é obrigatório (poderia estar tudo em `app.py`), mas é boa prática de organização: dividir responsabilidades em arquivos separados conforme o papel de cada parte do código. Múltiplas tools podem ser adicionadas à mesma lista `tools=[...]`.

### Execução e comportamento observado

Comandos (dentro de `05-agente-runbook-tool`, após `uv sync` e `.env` configurado):

```bash
uv run agente-runbook-tool RB-274
uv run agente-runbook-tool RB-381
uv run agente-runbook-tool RB-905
uv run agente-runbook-tool RB-200
```

- `RB-274`, `RB-381`, `RB-905`: a tool é chamada com o ID correspondente (`Ferramenta: consultar_runbook(runbook_id='RB-274')` aparece no terminal), o runbook é carregado em tempo real, e o agente devolve um resumo correto do conteúdo.
- `RB-200` (ID inexistente no catálogo): o agente consulta a ferramenta, recebe "Runbook RB-200 não foi encontrado na base de runbook interno", e constrói a resposta final informando exatamente isso ao usuário — a tratativa de erro está na própria função da ferramenta, não em código adicional no agente.

### Do determinístico ao imprevisível (o salto conceitual da aula)

Esse é o ponto central da aula: ao sair de um fluxo onde a informação já é conhecida e fixa (abordagem anterior) para um fluxo onde o agente recebe uma instrução, decide usar a ferramenta, e obtém o resultado baseado em parâmetros que ele mesmo interpreta — o comportamento deixa de ser previsível/determinístico e passa a ter a imprevisibilidade característica de um agente de IA: ele pode encontrar a informação, pode não encontrar, e cabe ao desenvolvedor decidir como tratar cada caso (ex.: pedir o código novamente), evoluindo o agente de forma incremental.

### Limitação apontada: tool do LangChain é específica do LangChain

O recurso de `tool` demonstrado é estruturado para ser usado junto com o LangChain — é parte do framework. Se o desenvolvedor quiser reutilizar a mesma ferramenta externa em múltiplas plataformas/agentes diferentes, teria que reimplementá-la em cada uma. É exatamente esse problema que o **MCP (Model Context Protocol)** resolve: um padrão aberto de comunicação entre agentes, onde se cria um MCP Server uma única vez e ele pode ser consumido por várias ferramentas/agentes, inclusive um agente LangChain. Gancho explícito para a próxima aula, que coloca em prática um agente de IA consumindo um MCP Server.

## Comandos e configurações

```bash
# .env do agente com ferramenta
# Copie para .env e preencha — o .env está no .gitignore e nunca deve ser commitado.
ANTHROPIC_API_KEY=sua-chave-aqui

# Identificador do modelo usado pelo ChatAnthropic.
MODELO=claude-sonnet-5
```

```bash
# Comandos para executar o agente com ferramenta (dentro de 05-agente-runbook-tool)
uv run agente-runbook-tool RB-274
uv run agente-runbook-tool RB-381
uv run agente-runbook-tool RB-905
uv run agente-runbook-tool RB-200
```

```python
# src/app.py (agente com ferramenta, resumido)
import argparse
import os

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic

from src.tools import consultar_runbook

load_dotenv()

if not os.getenv("ANTHROPIC_API_KEY"):
    raise SystemExit("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")

PERGUNTA = "Analise o runbook {runbook_id}, de um resumo em 1 parágrafo."

SYSTEM_PROMPT = """
Você é um agente de operações responsável por orientar a resposta a incidentes.
Quando a pergunta mencionar um runbook interno, use a ferramenta consultar_runbook
com o identificador informado. Responda somente com o procedimento retornado pela ferramenta.
"""

model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

agent = create_agent(
    model=model,
    tools=[consultar_runbook],
    system_prompt=SYSTEM_PROMPT,
)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Consulta runbooks internos usando um agente com ferramenta."
    )
    parser.add_argument("runbook_id")
    args = parser.parse_args()

    pergunta = PERGUNTA.format(runbook_id=args.runbook_id)
    print(f"Pergunta: {pergunta}\n")

    resultado = agent.invoke({"messages": [("human", pergunta)]})

    print("\nResposta:")
    print(resultado["messages"][-1].text)

if __name__ == "__main__":
    main()
```

```python
# src/tools.py
from pathlib import Path

from langchain.tools import tool
from langchain_community.document_loaders import TextLoader

RUNBOOKS_PATH = Path(__file__).resolve().parent.parent / "dados" / "runbooks"
RUNBOOKS = {
    "RB-274": RUNBOOKS_PATH / "RB-274.md",
    "RB-381": RUNBOOKS_PATH / "RB-381.md",
    "RB-905": RUNBOOKS_PATH / "RB-905.md",
}

@tool
def consultar_runbook(runbook_id: str) -> str:
    """Carrega um runbook interno pelo identificador informado na pergunta.

    Args:
        runbook_id: Identificador do runbook, como RB-274, RB-381 ou RB-905.
    """
    runbook_id = runbook_id.upper()
    print(f"Ferramenta: consultar_runbook(runbook_id={runbook_id!r})")

    caminho = RUNBOOKS.get(runbook_id)

    if caminho is None:
        return f"Runbook {runbook_id} não encontrado."

    loader = TextLoader(caminho, encoding="utf-8")
    documentos = loader.load()

    return "\n\n".join(documento.page_content for documento in documentos)
```

## Pegadinhas

- Esquecer a docstring (ou escrevê-la de forma vaga) na função decorada com `@tool` compromete a capacidade do agente de saber quando e como chamar aquela ferramenta — a docstring não é documentação "só para humanos", é lida pelo próprio agente na inicialização.
- A tratativa de "não encontrado" precisa estar dentro da própria função da ferramenta (retornando uma string explicativa), e não como uma verificação externa no código do agente — é assim que o agente consegue formular uma resposta coerente mesmo em caso de falha.
- O recurso de `tool` apresentado é específico do LangChain: reaproveitar a mesma funcionalidade externa em outra plataforma ou outro agente exigiria reimplementação, a menos que se use um padrão aberto como o MCP.

## Dúvidas para revisar

- Como fica a implementação equivalente usando um MCP Server, de forma que a mesma ferramenta `consultar_runbook` possa ser consumida por agentes de plataformas diferentes (tema da próxima aula)?
- É possível e recomendável adicionar múltiplas tools (ex.: consulta a banco de dados, chamada de API externa) à mesma lista `tools=[...]` de um único agente? Quais cuidados isso exige?
- Qual seria a abordagem para o agente, ao receber um ID de runbook inválido, pedir automaticamente ao usuário que informe um ID correto, em vez de apenas reportar que não encontrou?
