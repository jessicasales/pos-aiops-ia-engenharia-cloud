# Primeiro Chatbot e Composição do Contexto

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 02 — Primeiro Chatbot e Composição do Contexto (29:10) |
| **Assunto** | Chamadas a LLM são stateless; implementação manual de memória de conversa com `MessagesPlaceholder` e lista de histórico; introdução ao Prompt Cache |
| **Data** | 30/10/2026 01:00 |
| **Tags** | stateless, messagesplaceholder, historico, memoria, prompt-cache, chatprompttemplate |

## Resumo da aula

Demonstra, com dois projetos comparativos, a diferença entre um chat **sem memória** (cada chamada ao modelo começa do zero, sem saber nada das interações anteriores) e um chat **com memória** (o histórico de mensagens é mantido manualmente em uma lista e reenviado a cada nova chamada). O ponto central: toda chamada a um LLM é **stateless** — a responsabilidade de manter o histórico/contexto é inteiramente da aplicação, não do serviço de IA. A aula também introduz o conceito de **Prompt Cache** como mitigador de custo para esse crescimento do histórico.

## Conceitos principais

### Chat sem memória — cada chamada começa do zero

Projeto `02-chat-devops-sem-memoria` (usando Gemini): um `ChatPromptTemplate` fixo com `SystemMessage` + `HumanMessage` é recriado em cada chamada da função `responder()`. Teste prático: perguntar "O que é Kubernetes?" (resposta correta) e depois "Como ele atua no fluxo DevOps?" — o modelo **não sabe a quem "ele" se refere**, porque a pergunta anterior e sua resposta não fazem parte da nova chamada. A cada interação, só duas mensagens são enviadas: `SystemMessage → HumanMessage`.

### Chat com memória — histórico mantido manualmente

Projeto `03-chat-devops-memoria` (trocando para Anthropic/Claude, só mudando a dependência e o import — reforçando a portabilidade já estudada): o template ganha um `MessagesPlaceholder("historico")` entre a mensagem de sistema e a pergunta atual:

```python
prompt = ChatPromptTemplate.from_messages([
    SystemMessage(SYSTEM_PROMPT),
    MessagesPlaceholder("historico"),
    ("human", "{pergunta}"),
])
```

A cada turno, a pergunta e a resposta são anexadas a uma lista (`historico.append(HumanMessage(pergunta)); historico.append(resposta)`), que é passada inteira na chamada seguinte. Teste: a mesma sequência de perguntas agora funciona corretamente — na segunda pergunta, o histórico já contém `HumanMessage → AIMessage` da primeira interação, totalizando 4 mensagens enviadas (`SystemMessage → HumanMessage → AIMessage → HumanMessage`), e o modelo entende corretamente que "ele" se refere ao Kubernetes.

Comando `limpar` no loop reinicia o histórico para uma lista vazia — equivalente a um `/new` em uma sessão do Claude Code.

### A lição central: chamadas a LLM são stateless

O modelo **não guarda histórico por conta própria** — cada `invoke()` é tratado como a primeira e única interação daquela chamada. Quem precisa manter e reenviar o contexto é a **implementação do agente/aplicação** (aqui, via uma lista Python simples — a forma mais "rústica" de fazer isso, propositalmente escolhida para que o conceito fique visível, antes de abstrações mais sofisticadas vistas em aulas futuras).

### Implicação de custo: a janela de contexto cresce — e isso custa

Como o histórico completo é reenviado a cada chamada, o volume de tokens de input cresce a cada novo turno da conversa — e isso se reflete diretamente no custo.

### Prompt Cache — mitigando o custo do histórico crescente

Os serviços de IA (Anthropic, Google, OpenAI) mantêm um **cache de processamento** das interações já enviadas: se uma sequência de mensagens já foi processada anteriormente, apenas a parte **nova** (a mensagem adicional) precisa ser processada de fato — o restante é recuperado do cache, tornando o processamento incremental muito mais barato do que reprocessar toda a conversa do zero a cada turno. Tema a ser detalhado em aulas futuras (implementação e configuração de prompt cache).

## Comandos e configurações

```toml
# 02-chat-devops-sem-memoria/pyproject.toml
[project]
name = "chat-devops-sem-memoria"
dependencies = [
    "langchain>=1.3.14",
    "langchain-google-genai>=4.4.0",
    "python-dotenv>=1.2.2",
]
[project.scripts]
chat-devops-sem-memoria = "src.app:main"
```

```python
# 02-chat-devops-sem-memoria/src/app.py (resumo)
model = init_chat_model("google_genai:gemini-3.8-flash")
prompt = ChatPromptTemplate.from_messages([
    SystemMessage(SYSTEM_PROMPT),
    ("human", "{pergunta}"),
])

def responder(pergunta: str) -> None:
    prompt_value = prompt.invoke({"pergunta": pergunta})
    mensagens = prompt_value.to_messages()
    resposta = model.invoke(mensagens, automatic_function_calling={"disable": True})
    print(resposta.text)
```

```toml
# 03-chat-devops-memoria/pyproject.toml
[project]
name = "chat-devops-memoria"
dependencies = [
    "langchain>=1.3.14",
    "langchain-anthropic>=1.4.8",
    "python-dotenv>=1.2.2",
]
```

```bash
# .env
ANTHROPIC_API_KEY=sua-chave-aqui
MODELO=claude-sonnet-5
```

```python
# 03-chat-devops-memoria/src/app.py (resumo)
model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))
prompt = ChatPromptTemplate.from_messages([
    SystemMessage(SYSTEM_PROMPT),
    MessagesPlaceholder("historico"),
    ("human", "{pergunta}"),
])

def novo_historico() -> list:
    return []

def responder(historico: list, pergunta: str) -> AIMessage:
    prompt_value = prompt.invoke({"historico": historico, "pergunta": pergunta})
    mensagens = prompt_value.to_messages()
    resposta = model.invoke(mensagens)
    return resposta

def main() -> None:
    historico = novo_historico()
    while True:
        pergunta = input("Você: ").strip()
        if not pergunta or pergunta.lower() == "sair":
            break
        if pergunta.lower() == "limpar":
            historico = novo_historico()
            continue
        resposta = responder(historico, pergunta)
        historico.append(HumanMessage(pergunta))
        historico.append(resposta)
```

```bash
cd 02-chat-devops-sem-memoria
uv sync
uv run chat-devops-sem-memoria

cd ../03-chat-devops-memoria
uv sync
uv run chat-devops-memoria
```

## Pegadinhas

- Assumir que o modelo "lembra" interações anteriores por padrão é um erro comum — sem gerenciamento explícito de histórico, cada chamada é totalmente isolada (stateless).
- Reenviar o histórico completo a cada turno aumenta o custo de tokens de input progressivamente — mitigado parcialmente pelo Prompt Cache dos provedores, mas ainda um fator a monitorar em conversas longas.
- A implementação manual com lista Python é deliberadamente "rústica" — o LangChain oferece abstrações mais sofisticadas de gerenciamento de histórico/middleware, exploradas em aulas futuras; usar a lista primeiro é didático, não a prática final recomendada.

## Dúvidas para revisar

- Quais são as abstrações mais sofisticadas de gerenciamento de histórico no LangChain (mencionadas como "a gente vai ver depois") e quando cada uma se justifica em vez da lista manual?
- Como o Prompt Cache é configurado na prática em cada provedor (Anthropic, Google, OpenAI) — é automático ou exige declaração explícita?
- Em que ponto o histórico de conversa começa a ficar grande demais e exige uma estratégia de resumo/truncamento, em vez de sempre reenviar tudo?
