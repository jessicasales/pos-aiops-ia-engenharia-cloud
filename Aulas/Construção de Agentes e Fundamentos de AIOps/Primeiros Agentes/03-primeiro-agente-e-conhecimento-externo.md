# Primeiro Agente e Conhecimento Externo

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 03 — Primeiro Agente e Conhecimento Externo (21:27) |
| **Assunto** | `create_agent` do LangChain (primeiro agente real, ainda sem ferramentas); memória de longa duração via `TextLoader` carregando um runbook para o System Prompt |
| **Data** | 30/10/2026 01:15 |
| **Tags** | create_agent, langchain-agents, textloader, memoria-de-longa-duracao, runbook, documentloader |

## Resumo da aula

Primeiro contato real com `create_agent` do LangChain — a função que efetivamente cria um **agente** (diferente de `ChatAnthropic`/`init_chat_model`, que só conecta a um LLM). O agente desta aula ainda não tem ferramentas (`tools=[]`), mas introduz o conceito de **memória de longa duração**: um documento externo (um runbook de operações) persistido em disco, carregado via `TextLoader` e injetado no System Prompt. A aula demonstra, com e sem o carregamento do documento, como o agente só consegue responder corretamente quando a informação está de fato presente no contexto enviado.

## Conceitos principais

### Janela de contexto (sessão) vs. memória de longa duração (entre sessões)

- **Janela de contexto** (aula anterior): lista temporária de mensagens, válida apenas durante aquela sessão/execução.
- **Memória de longa duração**: informação persistida em algum lugar (arquivo, banco de dados, web) e consumida quando necessário, **atravessando sessões** — já vista na prática com Claude Code/Codex ao usar documentos de especificação (PRD, TRD, etc.) em SDD. Esta aula mostra a versão "crua" disso com um agente LangChain.

### `create_agent` — a diferença real entre chat e agente

```python
model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))
agent = create_agent(model=model, tools=[])
```

- **`ChatAnthropic`/`init_chat_model`**: conexão simples com o LLM — você invoca o modelo diretamente, recebendo resposta.
- **`create_agent`** (pacote `langchain.agents`): cria um **agente real**, que internamente executa o loop de agente (análise → ação → observação), mesmo que aqui ainda sem ferramentas. É esse objeto (`agent`) que é invocado, não mais o modelo diretamente.

### `TextLoader` — carregando documentos de texto

```python
from langchain_community.document_loaders import TextLoader

def carregar_documento() -> str:
    loader = TextLoader(RUNBOOK_PATH, encoding="utf-8")
    documentos = loader.load()
    return "\n\n".join(documento.page_content for documento in documentos)
```

`TextLoader` é a classe do LangChain para carregar arquivos de texto plano (aqui, um Markdown) — retorna uma lista de objetos `Document`, cada um com `page_content` (o texto) e `metadata` (ex.: `source`, o caminho do arquivo). Será reutilizado em aulas futuras de RAG, com outros tipos de loader para outros formatos.

### Injeção da memória de longa duração no System Prompt

```python
SYSTEM_PROMPT = """
Você é um agente de operações responsável por orientar a resposta a incidentes.
Responda somente com informações presentes no CONTEXTO EXTERNO abaixo.
Se o contexto não contiver o procedimento pedido, diga que não encontrou essa informação.

CONTEXTO EXTERNO:
{contexto}
"""
```

A variável `{contexto}` é preenchida com o texto do runbook carregado (ou com string vazia, se a chamada a `carregar_documento()` estiver comentada). Instrução explícita para o agente **não inventar** informação fora do contexto fornecido — importante para confiabilidade operacional.

### Demonstração comparativa

**Sem carregar o documento** (`contexto = ""`): pergunta "Segundo o runbook RB-274, qual é o procedimento para estabilizar a catalog-api quando o alerta OPS-4821 dispara?" → o agente responde corretamente que **não encontrou** essa informação no contexto fornecido (comportamento esperado e desejado, graças à instrução do System Prompt).

**Com o documento carregado** (`contexto = carregar_documento()`): o `TextLoader` carrega o runbook (823 caracteres, 1 `Document`), a mensagem de sistema passa a conter "RB-274", e o agente responde corretamente com o procedimento completo: suspender implantações, registrar a revisão via `kubectl rollout history`, reverter com `kubectl rollout undo`, acompanhar com `kubectl rollout status`, encerrar a contenção só após erro < 2% por 10 minutos, e a restrição explícita de **não reiniciar pods individualmente** (ação que apagaria a relação entre a falha e a revisão a ser registrada no incidente).

### A ressalva importante: isso ainda não é "inteligente" o suficiente

O instrutor antecipa a crítica óbvia: isso não foi realmente "carregar uma memória de longa duração de forma autônoma" — foi simplesmente pegar um texto e colar no prompt, de forma fixa e manual (a chamada a `carregar_documento()` precisa ser descomentada manualmente no código). Um agente de verdade deveria ter a **capacidade de decidir quando** carregar aquele documento, em tempo real, conforme a necessidade da tarefa — e não tê-lo sempre fixo no prompt. Essa capacidade é o gancho direto para a próxima aula: **chamada de ferramenta (tool calling)**.

## Comandos e configurações

```python
# src/app.py (resumo)
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic
from langchain_community.document_loaders import TextLoader
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

RUNBOOK_PATH = Path(__file__).resolve().parent.parent / "dados" / "runbook.md"
RUNBOOK_ID = "RB-274"
PERGUNTA = (
    "Segundo o runbook RB-274, qual é o procedimento para estabilizar a catalog-api "
    "quando o alerta OPS-4821 dispara?"
)

SYSTEM_PROMPT = """
Você é um agente de operações responsável por orientar a resposta a incidentes.
Responda somente com informações presentes no CONTEXTO EXTERNO abaixo.
Se o contexto não contiver o procedimento pedido, diga que não encontrou essa informação.

CONTEXTO EXTERNO:
{contexto}
"""

model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))
agent = create_agent(model=model, tools=[])

prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    MessagesPlaceholder("historico"),
    ("human", "{pergunta}"),
])

def carregar_documento() -> str:
    loader = TextLoader(RUNBOOK_PATH, encoding="utf-8")
    documentos = loader.load()
    return "\n\n".join(documento.page_content for documento in documentos)

def main() -> None:
    contexto = ""
    # contexto = carregar_documento()
    historico = []
    mensagens = prompt.invoke(
        {"contexto": contexto, "historico": historico, "pergunta": PERGUNTA}
    ).to_messages()
    resultado = agent.invoke({"messages": mensagens})
    print(resultado["messages"][-1].text)
```

```markdown
<!-- dados/runbook.md -->
# RB-274 — Estabilização da catalog-api

## Alerta relacionado
`OPS-4821` — taxa de erros HTTP 5xx acima de 12% por cinco minutos após uma implantação.

## Procedimento
1. Suspender novas implantações da `catalog-api` no ambiente afetado.
2. Registrar no incidente o identificador da revisão retornado por
   `kubectl -n catalog rollout history deployment/catalog-api`.
3. Reverter a implantação com `kubectl -n catalog rollout undo deployment/catalog-api`.
4. Acompanhar a estabilização com
   `kubectl -n catalog rollout status deployment/catalog-api --timeout=180s`.
5. Encerrar a contenção somente depois que a taxa de erros permanecer abaixo de 2% durante dez minutos.

## Restrição
Não reiniciar pods individualmente. Essa ação apaga a relação entre a falha e a revisão que
precisa ser registrada no incidente.
```

```bash
cd 04-agente-runbook
uv sync
uv run agente-runbook
```

## Pegadinhas

- Esquecer de descomentar a chamada a `carregar_documento()` faz o agente responder, corretamente, que não tem a informação — não é um bug, é o comportamento esperado quando o contexto está vazio.
- Injetar um documento fixo e sempre presente no System Prompt não é "memória de longa duração de verdade" no sentido pleno de um agente — é uma simulação simplificada; o próximo passo real é dar ao agente a capacidade de decidir **quando** buscar essa informação (tool calling).
- O System Prompt instruindo "responda somente com informações do CONTEXTO EXTERNO" é essencial para evitar que o modelo "invente" um procedimento plausível, mas incorreto, quando a informação realmente não está disponível.

## Dúvidas para revisar

- Como ficaria a implementação com `create_agent` e uma `tool` que carrega o runbook sob demanda, em vez de sempre no System Prompt (tema da próxima aula)?
- Em um cenário real com múltiplos runbooks, como o agente decidiria qual runbook carregar para uma pergunta específica — isso já é RAG, ou ainda é algo mais simples?
- Qual é o impacto de sempre injetar o runbook inteiro no prompt (mesmo quando não relevante para a pergunta) em termos de custo e janela de contexto, comparado a buscar só o trecho necessário?
