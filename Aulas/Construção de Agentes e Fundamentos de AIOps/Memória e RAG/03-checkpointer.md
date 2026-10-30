# Checkpointer

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 03 — Checkpointer, Thread e Backend de Persistência (29:53) |
| **Assunto** | Implementação de memória de curto prazo com LangChain/LangGraph: `thread_id`, `checkpointer` (`InMemorySaver` e `PostgresSaver`), e troca de backend sem mudar o resto do agente |
| **Data** | 30/10/2026 01:15 |
| **Tags** | checkpointer, thread, thread-id, inmemorysaver, postgressaver, langgraph, memoria-de-curto-prazo, flask |

## Resumo da aula

Primeira aula prática do capítulo, implementando memória de curto prazo com LangChain. Três conceitos centrais: **thread** (a sessão/conversa, identificada por um `thread_id`), **checkpointer** (o componente do LangGraph que grava e recupera o estado da sessão) e **backend** (onde esse checkpoint é persistido — memória, PostgreSQL, SQLite, DynamoDB, MongoDB, Redis, entre outros). A demonstração usa uma aplicação web em Flask (`12-agente-memoria-persistente`) que implementa um chat com múltiplas sessões, primeiro com checkpoint em memória (perdido ao reiniciar o processo) e depois com PostgreSQL (persistente entre reinícios).

## Conceitos principais

### Thread — a sessão, com seu identificador único

**Thread** é o termo usado no LangChain/LangGraph para a sequência de interação — a sessão, equivalente ao conceito já visto de "thread/sessão" no Claude Code. Toda thread tem um **`thread_id`** — normalmente um UUID — que funciona como chave primária para identificar aquela sessão específica.

### Checkpointer — o componente que grava e recupera o estado

O **checkpointer** é o objeto do LangGraph responsável por gravar e recuperar os checkpoints do estado do agente — na prática, os dados de memória de curto prazo de cada sessão. Ao criar uma sessão, o `thread_id` é passado ao checkpointer, que cria o estado correspondente; a cada nova mensagem, ele recupera o estado anterior e o disponibiliza para a próxima chamada do agente.

### Backend — onde o checkpoint é persistido

O checkpoint, por si só, precisa ser persistido em algum lugar. A documentação do LangChain lista vários **backends** possíveis, cada um com seu próprio pacote: em memória (`in-memory`), SQLite, PostgreSQL, DynamoDB, MongoDB, CosmosDB, Redis, entre outros (`https://docs.langchain.com/oss/python/integrations/checkpointers/index`).

### Por que o LangGraph aparece num projeto LangChain

Observação técnica importante: os checkpointers vêm do pacote **LangGraph** (`langgraph.checkpoint.*`), mesmo em um projeto que usa `langchain.agents.create_agent` — porque o LangGraph é usado "por debaixo dos panos" pelo LangChain. Não é um erro de configuração; é esperado que algumas peças do ecossistema venham de pacotes irmãos do LangChain.

### `src/checkpointer.py` — escolha de backend via variável de ambiente

```python
"""Escolha do checkpointer de memória ou PostgreSQL pelo ambiente."""

import os

from dotenv import load_dotenv
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.checkpoint.postgres import PostgresSaver

load_dotenv()

BACKEND = os.getenv("CHECKPOINTER_BACKEND", "memory").lower()
if BACKEND not in {"memory", "postgres"}:
    raise ValueError("CHECKPOINTER_BACKEND deve ser memory ou postgres.")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://aula:aula@localhost:55432/memoria")

# Compartilhado pelas requisições deste processo; um restart cria outro saver vazio.
memory_saver = InMemorySaver()

def memory_checkpointer():
    """Devolve o saver que preserva threads enquanto o processo vive."""
    return memory_saver

def postgres_checkpointer():
    """Fornece o contexto de conexão do checkpointer PostgreSQL."""
    return PostgresSaver.from_conn_string(DATABASE_URL)
```

Ponto central: **trocar o backend é trocar apenas essa peça** — `InMemorySaver()` para memória, `PostgresSaver.from_conn_string(DATABASE_URL)` para PostgreSQL. O resto do agente (modelo, tools, system prompt, lógica de invocação) não muda.

### `src/agent.py` — os três elementos da memória de curto prazo juntos

```python
"""Chamada do agente com a mensagem nova e a thread escolhida."""

import os

from langchain.agents import create_agent
from langgraph.checkpoint.base import BaseCheckpointSaver

SYSTEM_PROMPT = "Você é um assistente de uso geral. Responda em português brasileiro, de forma clara e concisa."

def respond(checkpointer: BaseCheckpointSaver, thread_id: str, prompt: str) -> None:
    """Envia apenas a nova mensagem ao agente na thread informada."""

    agent = create_agent(
        model=f"anthropic:{os.getenv('MODELO', 'claude-sonnet-5')}",
        tools=[],
        system_prompt=SYSTEM_PROMPT,
        checkpointer=checkpointer,
    )
    thread_config = {"configurable": {"thread_id": thread_id}}
    agent.invoke({"messages": [{"role": "user", "content": prompt}]}, thread_config)
```

Os três elementos-chave, juntos:
1. **`checkpointer=checkpointer`** — passado diretamente ao `create_agent`.
2. **`thread_config = {"configurable": {"thread_id": thread_id}}`** — passado como segundo argumento do `invoke`.
3. Apenas a **mensagem nova** é enviada em `messages` — o histórico completo da conversa não é reenviado manualmente; é o checkpointer, através do `thread_id`, que recupera o histórico e o entrega ao agente internamente.

### `src/web.py` — a aplicação Flask que orquestra tudo

Pontos de destaque da aplicação web:
- `existing_threads(checkpointer)` — lista os IDs únicos de todas as threads que já têm checkpoints gravados, usando `checkpointer.list(None)`.
- `conversation(checkpointer, thread_id)` — recupera as mensagens do **último checkpoint** de uma thread específica via `checkpointer.get_tuple({"configurable": {"thread_id": thread_id}})`, extraindo `saved.checkpoint["channel_values"]["messages"]`.
- A rota `/` cria um novo `thread_id` (UUID) quando o usuário clica em "nova sessão", ou carrega a thread existente informada na URL/formulário.
- O chaveamento de backend ocorre na própria rota: se `BACKEND == "memory"`, usa `memory_checkpointer()`; senão, abre o contexto `with postgres_checkpointer() as checkpointer:` e chama **`checkpointer.setup()`** — que cria as tabelas necessárias no banco automaticamente, sem precisar de migração manual.
- Tratamento de erro específico para `OperationalError` do `psycopg` — se o PostgreSQL estiver indisponível, retorna HTTP 503 com mensagem orientando a subir o banco via `docker compose up -d --wait`.

### Demonstração 1 — backend em memória: sessões se perdem ao reiniciar

```bash
CHECKPOINTER_BACKEND=memory
```

```bash
cd 12-agente-memoria-persistente
uv run flask --app src.web run --port 8501
```

Duas sessões testadas:
- **Sessão 1**: "O que é Kubernetes?" → "Como ele se encaixa no fluxo DevOps?" — a segunda resposta usa corretamente o contexto da primeira pergunta (confirma a memória de curto prazo funcionando dentro da mesma thread).
- **Sessão 2** (nova thread): "O que é Prometheus?" — como o System Prompt é genérico ("assistente de uso geral"), o modelo respondeu com ambiguidade (mitologia grega vs. ferramenta de monitoramento) — o instrutor usa esse "erro" não corrigido de propósito como demonstração de que o System Prompt generalista realmente produz esse comportamento; ao especificar "Prometheus tecnologia" na pergunta seguinte, a resposta corrige para a ferramenta de observabilidade.

Depois de interromper o processo (`Ctrl+C`) e rodar novamente: as sessões **desaparecem completamente** — porque `InMemorySaver()` guarda tudo apenas na memória RAM do processo em execução; reiniciar o processo cria um novo saver vazio.

### Demonstração 2 — PostgreSQL: sessões sobrevivem ao restart

```yaml
# compose.yaml
services:
  postgres:
    image: postgres:17
    environment:
      POSTGRES_USER: aula
      POSTGRES_PASSWORD: aula
      POSTGRES_DB: memoria
    ports:
      - "127.0.0.1:55432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U aula -d memoria"]
      interval: 2s
      timeout: 2s
      retries: 15

volumes:
  postgres_data:
```

```bash
docker compose up -d --wait
```

Depois de subir o banco, trocar no `.env`:

```bash
CHECKPOINTER_BACKEND=postgres
DATABASE_URL=postgresql://aula:aula@localhost:55432/memoria
```

Atenção à pegadinha mencionada na aula: o valor precisa estar correto — na gravação, um erro de digitação (`postgre` em vez de `postgres`) causou falha de validação (`CHECKPOINTER_BACKEND deve ser memory ou postgres`).

Testes:
- **Sessão 1**: "O que é Docker?" → "Como ele entra no fluxo AIOps?" — contexto mantido corretamente, mesma dinâmica da versão em memória.
- **Sessão 2** (nova thread): "O que é Terraform?"

Depois de **encerrar e reiniciar o processo da aplicação**, as sessões continuam disponíveis no seletor — porque o estado agora está no banco PostgreSQL, não na memória volátil do processo. Isso é o que viabiliza escalar a aplicação horizontalmente (múltiplas instâncias compartilhando o mesmo banco) e atualizar/reiniciar a aplicação sem perder dados de sessão.

### A memória de curto prazo como janela de contexto — reforço do ponto da aula anterior

O instrutor reforça (ecoando a aula 02): nesse exemplo, o checkpoint serve efetivamente como a janela de contexto do agente — toda a memória de curto prazo de uma thread é enviada ao modelo a cada interação. É responsabilidade do desenvolvedor gerenciar se essa memória cabe na janela de contexto do modelo usado (cortar, resumir, etc.) — tema que a aula explicitamente **não** aborda em profundidade aqui, deixando como ponto de atenção futuro.

## Comandos e configurações

```bash
# .env
ANTHROPIC_API_KEY=sua-chave-aqui
MODELO=claude-sonnet-5
CHECKPOINTER_BACKEND=memory
DATABASE_URL=postgresql://aula:aula@localhost:55432/memoria
```

```toml
# pyproject.toml
[project]
name = "agente-memoria-persistente"
version = "0.1.0"
description = "Exemplo didatico de threads com checkpointer em memoria"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "flask>=3.1.3",
    "langchain>=1.4.5",
    "langchain-anthropic>=1.7.6",
    "langgraph-checkpoint-postgres>=3.1.3",
    "psycopg[binary]>=3.3.6",
    "python-dotenv>=1.2.4",
]
```

```bash
cd 12-agente-memoria-persistente
uv run flask --app src.web run --port 8501
# abrir http://127.0.0.1:8501
```

```bash
# Subir o PostgreSQL local, antes de trocar o backend
docker compose up -d --wait
```

```python
# src/checkpointer.py
import os

from dotenv import load_dotenv
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.checkpoint.postgres import PostgresSaver

load_dotenv()

BACKEND = os.getenv("CHECKPOINTER_BACKEND", "memory").lower()
if BACKEND not in {"memory", "postgres"}:
    raise ValueError("CHECKPOINTER_BACKEND deve ser memory ou postgres.")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://aula:aula@localhost:55432/memoria")

memory_saver = InMemorySaver()

def memory_checkpointer():
    return memory_saver

def postgres_checkpointer():
    return PostgresSaver.from_conn_string(DATABASE_URL)
```

```python
# src/agent.py
import os

from langchain.agents import create_agent
from langgraph.checkpoint.base import BaseCheckpointSaver

SYSTEM_PROMPT = "Você é um assistente de uso geral. Responda em português brasileiro, de forma clara e concisa."

def respond(checkpointer: BaseCheckpointSaver, thread_id: str, prompt: str) -> None:
    agent = create_agent(
        model=f"anthropic:{os.getenv('MODELO', 'claude-sonnet-5')}",
        tools=[],
        system_prompt=SYSTEM_PROMPT,
        checkpointer=checkpointer,
    )
    thread_config = {"configurable": {"thread_id": thread_id}}
    agent.invoke({"messages": [{"role": "user", "content": prompt}]}, thread_config)
```

## Pegadinhas

- `InMemorySaver()` persiste apenas enquanto o processo Python estiver rodando — qualquer reinício (deploy, crash, `Ctrl+C`) apaga todas as sessões; é adequado só para desenvolvimento/testes, nunca para produção.
- O valor de `CHECKPOINTER_BACKEND` precisa ser exatamente `"postgres"` (com "s" no final) — um erro de digitação como `"postgre"` causa falha de validação explícita (`ValueError`), não um comportamento silencioso incorreto.
- Mesmo usando LangChain, pacotes do LangGraph (`langgraph.checkpoint.*`) aparecem no projeto — isso é esperado, não um sinal de mistura indevida de frameworks.
- `checkpointer.setup()` precisa ser chamado (ao menos uma vez) para criar as tabelas no PostgreSQL — na aplicação de exemplo, isso acontece a cada requisição dentro do bloco `with postgres_checkpointer() as checkpointer:`, o que funciona mas não é necessariamente a abordagem mais eficiente para produção (idealmente seria uma etapa de inicialização/migração separada).
- A memória de curto prazo, nesse padrão, é enviada **inteira** ao modelo como parte da janela de contexto — sem alguma estratégia de corte/resumo, uma conversa muito longa pode ultrapassar o limite de contexto do modelo; a aula identifica esse risco, mas não implementa a mitigação.

## Dúvidas para revisar

- Como implementar, na prática, uma estratégia de corte/resumo da memória de curto prazo quando uma thread cresce além da janela de contexto do modelo usado?
- Que outros backends de checkpoint (SQLite, Redis, DynamoDB, MongoDB) seriam mais adequados para diferentes cenários de produção (ex.: aplicação serverless vs. aplicação com banco relacional já existente)?
- Como ficaria a chamada de `checkpointer.setup()` numa aplicação de produção real — faria sentido movê-la para um script de migração/inicialização separado, em vez de rodar a cada requisição?
