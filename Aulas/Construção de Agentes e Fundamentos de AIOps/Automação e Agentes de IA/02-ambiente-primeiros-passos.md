# Ambiente primeiros passos

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 02 — Ambiente primeiros passos (32:12) |
| **Assunto** | Setup do ambiente LangChain (Python 3.12 + uv), por que usar um framework em vez do SDK direto do provider, estrutura básica de conexão com um LLM (`init_chat_model`), e diferença entre `invoke` e `stream` |
| **Data** | 29/10/2026 23:00 |
| **Tags** | langchain, uv, init_chat_model, system-message, human-message, invoke, stream, usage_metadata |

## Resumo da aula

Primeira aula prática do módulo. Define os requisitos de ambiente (Python 3.12, gerenciador de pacotes `uv`, contas de API em provedores de IA) e explica por que usar o **LangChain** em vez do SDK direto de cada provedor (evita lock-in/acoplamento). Demonstra a estrutura mínima de um projeto LangChain conectando a um LLM (Google Gemini, via AI Studio) com `init_chat_model`, e a diferença prática entre as duas formas de obter resposta: `invoke` (resposta completa de uma vez) e `stream` (resposta token a token, progressiva).

## Conceitos principais

### Por que LangChain em vez do SDK direto do provedor

Cada provedor (Anthropic, OpenAI, Google, AWS, Microsoft, Ollama) tem seu próprio SDK. Usar o SDK diretamente acopla o código àquele provedor específico — trocar de provedor exigiria reescrever a integração do zero. O LangChain fornece uma **camada de abstração**: trocar de Google para Anthropic, por exemplo, é só trocar o pacote de integração (`langchain-google-genai` → `langchain-anthropic`) e o import correspondente, mantendo o resto do código igual. Além disso, o LangChain já vem com integrações prontas para bancos de dados vetoriais, retrievers, storages e outros componentes usados na construção de agentes (RAG, MCP, etc.) — ver a página de integrações na documentação (`docs` → `Build` → `Integrations`).

### Requisitos de ambiente

- **Python 3.12** instalado.
- Gerenciador de pacotes **uv** (escolha do instrutor, um dos mais usados no mercado junto com pip).
- Contas de API nos provedores de IA (OpenAI, Anthropic, Google) — a aula usa inicialmente o **Google AI Studio**, por oferecer uma camada gratuita com créditos de uso.
- LangChain tem suporte oficial a **Python e TypeScript**; o curso usa Python, dado o foco em DevOps/Cloud.
- Não é necessário profundo conhecimento de programação — o próprio Claude Code/Codex/Cursor pode ajudar na implementação —, mas ter familiaridade com a estrutura ajuda a instruir melhor o agente de codificação.

### Estrutura básica de um projeto LangChain

Componentes típicos:
- `pyproject.toml` (configuração de dependências via `uv`).
- `README.md`, `CLAUDE.md`.
- Código em `src/app.py`.
- Pacote `langchain-core` sempre presente, mais o pacote específico do provedor (`langchain-google-genai`, `langchain-anthropic`, `langchain-openai`, `langchain-ollama`, `langchain-aws`, etc.).
- `python-dotenv` para carregar variáveis de ambiente de um arquivo `.env` (ex.: a API key do provedor).

### `init_chat_model` — conexão com o LLM (ainda não é um agente)

Ponto conceitual central da aula: `init_chat_model` cria apenas um **canal de comunicação com um chat/LLM** — não é ainda um agente autônomo. É o equivalente a "entrar no ChatGPT/Claude/Gemini e digitar uma pergunta", só que programaticamente.

```python
from langchain.chat_models import init_chat_model

model = init_chat_model("google_genai:gemini-3-flash")  # nome exato do provider/modelo varia — checar documentação
```

### Tipos de mensagem

- **SystemMessage**: a instrução de sistema/configuração inicial (equivalente ao System Prompt já estudado em Engenharia de Prompt/Contexto) — ex.: "Você é um assistente de DevOps, especialista em infraestrutura, automação e práticas de desenvolvimento."
- **HumanMessage**: a mensagem/pergunta do usuário.
- **AIMessage**: a mensagem de resposta gerada pela IA (tipo do objeto retornado pela chamada).

### `invoke` vs. `stream`

- **`invoke`**: dispara a chamada e espera a resposta **completa** de uma vez (após o tempo de processamento do modelo).
- **`stream`**: a resposta chega **gradativamente**, token a token, conforme o modelo a constrói (reflexo direto da arquitetura Transformer — geração sequencial de tokens por probabilidade estatística).

Quando usar cada um:
- **`invoke`**: quando se precisa do conteúdo completo da resposta para processar depois (típico em automações) — é o que será usado na maior parte do módulo, inclusive com agentes autônomos.
- **`stream`**: quando há interação em tempo real com um usuário (um chat), para dar a percepção de resposta mais rápida (como alguém digitando).

### Metadados da resposta — `usage_metadata`

Toda resposta de `invoke`/`stream` retorna, além do texto, metadados importantes: tipo da mensagem (`AIMessage`), e em `usage_metadata`: tokens de input, tokens de output, total, uso de cache e informações de reasoning. Esses dados são essenciais para acompanhar o **custo** de cada interação com o modelo. Também vêm outros metadados, como o `finish_reason` (ex.: `stop`) e o modelo exatamente utilizado.

### `disable_streaming`/function calling desabilitado

Na demo, a chamada de ferramentas (function calling) foi explicitamente desabilitada — ainda não é o momento de usar ferramentas; o foco é só a conexão básica com o LLM.

## Comandos e configurações

```bash
uv sync
uv run src/app.py
```

```python
# estrutura conceitual do exemplo (reconstruída da transcrição)
from dotenv import load_dotenv
from langchain.chat_models import init_chat_model
from langchain_core.messages import SystemMessage, HumanMessage
import os, sys

load_dotenv()
if not os.getenv("GOOGLE_API_KEY"):
    sys.exit("Configure o arquivo .env com a GOOGLE_API_KEY.")

SYSTEM_PROMPT = (
    "Você é um assistente de DevOps, especialista em infraestrutura, "
    "automação e práticas de desenvolvimento. Responda de forma clara, "
    "objetiva e concisa."
)

model = init_chat_model("google_genai:gemini-3-flash")  # exemplo ilustrativo

def responder(pergunta: str):
    resposta = model.invoke([
        SystemMessage(content=SYSTEM_PROMPT),
        HumanMessage(content=pergunta),
    ])
    print(resposta)

def responder_streaming(pergunta: str):
    for chunk in model.stream([
        SystemMessage(content=SYSTEM_PROMPT),
        HumanMessage(content=pergunta),
    ]):
        print(chunk.content, end="", flush=True)
```

```bash
# .env
GOOGLE_API_KEY=<chave gerada no Google AI Studio>
```

## Pegadinhas

- `init_chat_model` conecta ao LLM, mas **não é um agente autônomo** — confundir os dois conceitos nesse estágio gera expectativas erradas sobre o que o código faz.
- O nome exato do provider/modelo a passar para `init_chat_model` muda com frequência e varia por provedor — sempre checar a documentação do LangChain e do provedor antes de codificar de memória.
- Perguntas mais longas/detalhadas (ex.: "responda com no mínimo 3 parágrafos") aumentam significativamente o consumo de tokens de output — vale observar o `usage_metadata` para entender o impacto de custo de cada ajuste de prompt.
- Usar `stream` quando o processamento posterior precisa do conteúdo completo da resposta (típico em automações) é desnecessariamente complexo — `invoke` é a escolha correta nesse caso.

## Dúvidas para revisar

- Qual é a diferença de custo/latência prática entre Google Gemini, OpenAI e Anthropic para o mesmo tipo de pergunta de DevOps, testando com o mesmo projeto?
- Como ficaria a estrutura do projeto ao trocar de provedor (ex.: Google → Anthropic) na prática — quais linhas exatamente mudam?
- Em que ponto das próximas aulas (Chaining, Routing, Paralelização) esse canal básico de comunicação evolui para algo mais parecido com uma automação real de AIOps?
