# Memória de Longo Prazo

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 04 — Memória de Longo Prazo com Store (51:00) |
| **Assunto** | `Store` do LangChain: namespace/chave/valor, tools de memória (`listar_projetos`, `criar_projeto`, `consultar_projeto`, `registrar_decisao`), isolamento por usuário, combinação com checkpointer |
| **Data** | 30/10/2026 01:15 |
| **Tags** | store, namespace, langgraph-store, postgresstore, tool-runtime, context-schema, memoria-de-longo-prazo, isolamento-por-usuario |

## Resumo da aula

Aula mais longa do curso até aqui: implementa memória de longo prazo com o componente **`Store`** do LangChain, usando o exemplo `13-consultor-arquitetura-cloud` — um agente que atua como consultor de arquitetura cloud, registrando projetos e decisões arquiteturais (como um ADR interativo) que persistem **entre sessões diferentes** e são isolados **por usuário**. Diferente do checkpointer (atado a um `thread_id`), o Store não trabalha com threads — ele persiste dados por **namespace** e **chave**, acessados através de **tools** próprias que o agente chama para ler/escrever memória de longo prazo.

## Conceitos principais

### Por que memória de longo prazo precisa de outro componente

A memória de curto prazo (checkpointer, aula 03) está vinculada à sessão — ao momento específico de interação. Para dados que precisam **transitar entre sessões** (preferências de usuário, configurações de projeto, padrões de arquitetura), é necessário outro componente: o **`Store`**.

### O modelo de dados do Store: namespace, chave, valor

Cada item armazenado no Store tem três campos:
- **`namespace`**: uma tupla de valores que agrupa itens — análogo a uma "pasta". Define a quem/a que aquele agrupamento de informações pertence (ex.: `("consultor-arquitetura-cloud", user_id, "projects")`).
- **`key`**: identifica o item dentro daquele namespace — análogo ao "nome do arquivo" dentro da pasta.
- **`value`**: o conteúdo em si, persistido como JSON — o "documento".

### Operações disponíveis no Store

- **`put`** — grava um item.
- **`get`** — obtém um item específico por namespace + chave.
- **`search`** — busca todos os itens dentro de um namespace.
- **`delete`** — remove um item (não implementado nas tools desta aula; proposto como **desafio** ao final: criar uma tool que remova uma decisão usando `delete`).

### Acesso ao Store só via tools — diferente do checkpointer

Diferente da memória de curto prazo (que o agente usa automaticamente através do checkpointer), a memória de longo prazo exige que o desenvolvedor **implemente tools explícitas** para cada operação (listar, criar, consultar, registrar). Isso acontece porque o Store é um dado compartilhável entre sessões e, muitas vezes, entre usuários/projetos — o controle de acesso (quem pode ler/escrever o que) precisa ser modelado deliberadamente nessas ferramentas, para garantir, por exemplo, que o agente não misture dados de um usuário com os de outro.

### Backend do Store: por que ir direto para PostgreSQL

Assim como o checkpointer, o Store tem backends plugáveis (in-memory, PostgreSQL, Redis, bancos vetoriais, etc.). A aula pula direto para PostgreSQL — o instrutor argumenta que não faz muito sentido ter uma memória de **longo prazo** guardada apenas em memória volátil (ela desapareceria ao reiniciar o processo, contrariando o próprio propósito de "longo prazo").

### Cenário de demonstração: consultor de arquitetura cloud com dois usuários

A aplicação de exemplo simula dois perfis de usuário (Ana e Bruno), cada um podendo criar **projetos** de arquitetura cloud e registrar **decisões** (como um processo de ADR conversacional). Cada usuário tem suas próprias sessões (threads, via checkpointer) e sua própria memória de longo prazo de projetos (via Store, isolada por `user_id`).

Demonstrações realizadas:
- Bruno cria o projeto "Kube-News" (Node.js, containers com Docker/Kubernetes, AWS, PostgreSQL, S3) — o agente chama `criar_projeto`, depois registra automaticamente cada decisão tecnológica mencionada via `registrar_decisao` (linguagem, hospedagem, cloud provider, banco de dados, armazenamento).
- Em uma **nova thread** (nova sessão), consultando "informações sobre o projeto Kube-News": como o checkpointer (memória de curto prazo) não teria esse histórico numa thread nova, é o **Store** que recupera as decisões salvas anteriormente — demonstrando exatamente a diferença entre as duas memórias.
- Testando com o usuário **Ana**: o mesmo projeto "Kube-News" não é encontrado — porque o Store isola os dados por `user_id`; é Bruno quem criou aquele projeto, não Ana.
- Ana cria seu próprio projeto "E-commerce" (Python, PostgreSQL, Azure, Docker, CI/CD com GitHub Actions) — isolado da memória de Bruno.
- Um erro de digitação (nome do projeto com espaço "Cube News" em vez de "Kube-News") ilustra uma limitação explícita deste exemplo: a busca por nome de projeto é **exata** (não há busca semântica/fuzzy), então o agente precisa do nome correto.
- Um momento de aparente falha (o agente pareceu não ter salvo decisões imediatamente) revela, na revisão, que o agente estava corretamente **aguardando confirmação explícita do usuário** antes de registrar as decisões — comportamento desejado pelo System Prompt, não um bug.

### Isolamento de dados é uma decisão de design do desenvolvedor, não do framework

Ponto explicitamente reforçado: o Store, por si só, não impõe isolamento por usuário — é a **estrutura de namespace escolhida** pelo desenvolvedor (incluir `user_id` no namespace) que garante esse isolamento. Poderia, em outro desenho, haver permissões por grupo, por squad, compartilhamento entre usuários, etc. — esse controle de acesso é inteiramente modelado pela aplicação.

### `src/database.py` — abrindo checkpointer e Store no mesmo banco

```python
import os

from dotenv import load_dotenv
from langgraph.checkpoint.postgres import PostgresSaver
from langgraph.store.postgres import PostgresStore

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://aula:aula@localhost:55433/arquitetura")

def open_checkpointer():
    """Abre um checkpointer para recuperar o histórico de cada thread."""
    return PostgresSaver.from_conn_string(DATABASE_URL)

def open_store():
    """Abre o Store para dados compartilhados entre threads de um usuário."""
    return PostgresStore.from_conn_string(DATABASE_URL)
```

Os dois mecanismos podem compartilhar o mesmo banco de dados (como neste exemplo) ou usar bancos separados, dependendo de como o projeto for estruturado.

### Abertura dos dois mecanismos na rota do chat (`src/web.py`)

```python
@app.route("/", methods=["GET", "POST"])
def chat():
    """Atende o chat e compartilha a conexão PostgreSQL com os dois mecanismos."""
    user_id = selected_user()
    if request.method == "POST" and request.form.get("action") == "new":
        return redirect(url_for("chat", user_id=user_id, thread_id=new_thread_id(user_id)))
    try:
        with open_checkpointer() as checkpointer, open_store() as store:
            checkpointer.setup()
            store.setup()
            if request.method == "POST":
                return send_message(checkpointer, store, user_id)
            return render_page(checkpointer, user_id)
    except OperationalError:
        return "PostgreSQL indisponível. Inicie o banco com docker compose up -d --wait.", 503
```

`checkpointer.setup()` e `store.setup()` criam as respectivas tabelas no banco automaticamente, se ainda não existirem.

### `src/agent.py` — `create_agent` com `store` e `context_schema`

```python
import os

from langchain.agents import create_agent
from langgraph.checkpoint.base import BaseCheckpointSaver
from langgraph.store.base import BaseStore

from src.memory_tools import AgentContext, TOOLS

SYSTEM_PROMPT = """Você é um consultor didático de arquitetura Cloud. Responda em português brasileiro.
Ao começar uma conversa, pergunte se o usuário quer criar um projeto ou continuar um existente.
Se a primeira mensagem já responder a essa pergunta, execute o pedido sem repeti-la.
Se ele quiser consultar o catálogo, use listar_projetos. Não presuma um projeto ativo em uma thread nova.
Use o nome do projeto nas ferramentas. O Store separa o catálogo de projetos dos itens de decisão.
Antes de responder sobre decisões anteriores, chame consultar_projeto; não invente memórias.
Registre uma decisão somente quando o usuário disser explicitamente que a aceitou ou pedir para registrá-la.
Escolhas de provedor e região também são decisões quando o usuário as confirma.
Registre uma decisão por chamada da ferramenta, sem exigir justificativa ou motivo.
Uma alternativa proposta, hipótese ou recomendação ainda não é uma decisão.
Não grave chaves de API, tokens ou outros segredos no Store; explique esse limite ao usuário.
Os dados Cloud deste exemplo são declarados pelo usuário; não alegue ter consultado infraestrutura real.
"""

def respond(
    checkpointer: BaseCheckpointSaver,
    store: BaseStore,
    user_id: str,
    thread_id: str,
    prompt: str,
) -> None:
    agent = create_agent(
        model=f"anthropic:{os.getenv('MODELO', 'claude-sonnet-5')}",
        tools=TOOLS,
        system_prompt=SYSTEM_PROMPT,
        checkpointer=checkpointer,
        store=store,
        context_schema=AgentContext,
    )
    thread_config = {"configurable": {"thread_id": thread_id}}
    agent.invoke(
        {"messages": [{"role": "user", "content": prompt}]},
        thread_config,
        context=AgentContext(user_id=user_id),
    )
```

Pontos técnicos centrais:
- O `create_agent` recebe **ambos** os mecanismos (`checkpointer=` para memória de curto prazo, `store=` para memória de longo prazo) — um agente pode (e frequentemente deve) ter os dois ao mesmo tempo.
- **`context_schema=AgentContext`**: define a estrutura de dados que trafega entre a aplicação e as tools — aqui, apenas o `user_id`, necessário para isolar o Store por usuário.
- O `thread_id` continua indo no `thread_config` (configurable), como na aula anterior, para a memória de curto prazo.
- O `user_id` vai no parâmetro **`context=`** do `invoke` — é isso que viabiliza que as tools de memória de longo prazo saibam de qual usuário são os dados.

### System Prompt como mecanismo de controle de comportamento da memória

Vale destacar instruções específicas do System Prompt que evitam comportamentos indesejados já observados em aulas anteriores (alucinação, invenção de memórias):
- "Antes de responder sobre decisões anteriores, chame `consultar_projeto`; não invente memórias."
- "Registre uma decisão somente quando o usuário disser explicitamente que a aceitou ou pedir para registrá-la." — distinção explícita entre uma **sugestão/hipótese** ainda não aceita e uma **decisão confirmada**.
- "Não grave chaves de API, tokens ou outros segredos no Store; explique esse limite ao usuário." — salvaguarda de segurança incorporada diretamente na instrução de comportamento do agente.

### `src/memory_tools.py` — as quatro tools de memória de longo prazo

```python
"""Ferramentas de memória de longo prazo para projetos de arquitetura Cloud.

O Store localiza cada item por namespace (tupla) e chave (string):

- projeto: namespace ("consultor-arquitetura-cloud", "ana", "projects"),
  chave "plataforma aurora", valor {"nome": "Plataforma Aurora"};
- decisão: namespace ("consultor-arquitetura-cloud", "ana", "decisions", "plataforma aurora"),
  chave única, valor {"texto": "Usar AWS na região sa-east-1"}.

Os namespaces de projetos e decisões são separados para a listagem de projetos
não incluir decisões. A aplicação normaliza o nome do projeto com ``casefold()``.
"""

import json
from dataclasses import dataclass
from uuid import uuid4

from langchain.tools import ToolRuntime, tool

@dataclass
class AgentContext:
    """Identidade escolhida pela aplicação web para uma execução do agente."""
    user_id: str

@tool
def listar_projetos(runtime: ToolRuntime[AgentContext]) -> str:
    """Liste os projetos do usuário atual."""
    store = runtime.store
    assert store is not None
    namespace = ("consultor-arquitetura-cloud", runtime.context.user_id, "projects")
    projects = [item.value["nome"] for item in store.search(namespace, limit=100)]
    return json.dumps(projects, ensure_ascii=False)

@tool
def criar_projeto(nome: str, runtime: ToolRuntime[AgentContext]) -> str:
    """Crie um projeto com o nome informado pelo usuário."""
    store = runtime.store
    assert store is not None
    name = nome.strip()
    if not name:
        return "Informe um nome para o projeto."

    namespace = ("consultor-arquitetura-cloud", runtime.context.user_id, "projects")
    key = name.casefold()
    if store.get(namespace, key) is not None:
        return "Já existe um projeto com esse nome. Liste os projetos e escolha o existente."

    project = {"nome": name}
    store.put(namespace, key, project)
    return json.dumps(project, ensure_ascii=False)

@tool
def consultar_projeto(nome_projeto: str, runtime: ToolRuntime[AgentContext]) -> str:
    """Consulte as decisões registradas para um projeto do usuário atual."""
    store = runtime.store
    assert store is not None
    user_id = runtime.context.user_id
    project_key = nome_projeto.strip().casefold()
    project_namespace = ("consultor-arquitetura-cloud", user_id, "projects")
    project = store.get(project_namespace, project_key)
    if project is None:
        return "Projeto não encontrado para este usuário."

    decisions_namespace = ("consultor-arquitetura-cloud", user_id, "decisions", project_key)
    decisions = [item.value["texto"] for item in store.search(decisions_namespace, limit=100)]
    return json.dumps({"nome": project.value["nome"], "decisoes": decisions}, ensure_ascii=False)

@tool
def registrar_decisao(
    nome_projeto: str,
    decisao: str,
    runtime: ToolRuntime[AgentContext],
) -> str:
    """Registre uma decisão aceita pelo usuário como um item próprio do Store."""
    store = runtime.store
    assert store is not None
    user_id = runtime.context.user_id
    project_key = nome_projeto.strip().casefold()
    project_namespace = ("consultor-arquitetura-cloud", user_id, "projects")
    if store.get(project_namespace, project_key) is None:
        return "Projeto não encontrado para este usuário."
    if not decisao.strip():
        return "Informe a decisão a registrar."

    decisions_namespace = ("consultor-arquitetura-cloud", user_id, "decisions", project_key)
    value = {"texto": decisao.strip()}
    decision_id = str(uuid4())
    store.put(decisions_namespace, decision_id, value)
    return json.dumps({"id": decision_id, **value}, ensure_ascii=False)

TOOLS = [listar_projetos, criar_projeto, consultar_projeto, registrar_decisao]
```

Pontos centrais de design:
- **`ToolRuntime[AgentContext]`**: o parâmetro que dá à tool acesso ao `store` e ao `context` (incluindo `user_id`) injetados pelo `create_agent` — é assim que a tool "sabe" de qual usuário são os dados, sem precisar que o próprio agente de IA informe isso explicitamente a cada chamada.
- **Dois namespaces distintos** para o mesmo conceito de "projeto": um para o catálogo de projetos (`"projects"`) e outro para as decisões de cada projeto (`"decisions", project_key`) — decisão de design do instrutor, para que listar projetos não misture com decisões; poderia, em outro desenho, estar tudo num único namespace.
- **Normalização do nome do projeto com `casefold()`**: usada como chave, para tornar a busca por nome insensível a maiúsculas/minúsculas (embora ainda exija o nome exato, sem busca semântica).
- **`criar_projeto`** verifica primeiro se já existe um projeto com aquele nome (`store.get`) antes de criar — evitando duplicação e comunicando o erro de forma que o próprio agente de IA possa se autocorrigir ("já existe... liste os projetos e escolha o existente").
- **`registrar_decisao`** usa uma **chave nova (`uuid4()`)** a cada chamada — isso é o que permite acumular várias decisões para o mesmo projeto sem sobrescrever as anteriores (cada decisão é um item independente dentro do mesmo namespace de decisões).

### Limitação explícita deste exemplo: busca exata, não semântica

O instrutor reconhece abertamente que a busca por nome de projeto é exata — um erro de digitação no nome ("Cube News" em vez de "Kube-News") faz a busca falhar, retornando "projeto não encontrado". Ele sinaliza que buscas por similaridade/semântica serão tratadas em casos futuros (conectando com o tema de embeddings e RAG, ainda a vir no capítulo).

### Desafio proposto

Implementar uma nova tool que remova uma decisão do Store usando a operação `delete` — exercitando a quarta operação do Store que a aula não implementou nas tools fornecidas.

## Comandos e configurações

```bash
# .env
ANTHROPIC_API_KEY=sua-chave-aqui
MODELO=claude-sonnet-5
DATABASE_URL=postgresql://aula:aula@localhost:55433/arquitetura
```

```yaml
# compose.yaml
services:
  postgres:
    image: postgres:17
    environment:
      POSTGRES_USER: aula
      POSTGRES_PASSWORD: aula
      POSTGRES_DB: arquitetura
    ports:
      - "127.0.0.1:55433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U aula -d arquitetura"]
      interval: 2s
      timeout: 2s
      retries: 15

volumes:
  postgres_data:
```

```bash
cd 13-consultor-arquitetura-cloud
docker compose up -d --wait
uv run flask --app src.web run --port 8502
# abrir http://127.0.0.1:8502, escolher usuário (Ana ou Bruno)
```

(Ver trechos de código completos de `src/database.py`, `src/agent.py` e `src/memory_tools.py` nas seções anteriores desta nota.)

## Pegadinhas

- A busca de projetos por nome, nesta implementação, é **exata** (normalizada com `casefold()`, mas sem tolerância a erros de digitação ou busca semântica) — um nome ligeiramente diferente do registrado ("Cube News" vs. "Kube-News") resulta em "projeto não encontrado", mesmo que a intenção seja clara para um humano.
- O isolamento de dados entre usuários (Ana vs. Bruno) não é automático do Store — é inteiramente resultado de incluir `user_id` no namespace de cada tool; omitir isso faria com que todos os usuários compartilhassem os mesmos dados.
- Um comportamento de "não salvou" pode, na verdade, ser o agente seguindo corretamente a instrução de só registrar uma decisão quando o usuário confirma explicitamente — antes de supor um bug, é importante verificar se o agente está, na verdade, esperando confirmação.
- `registrar_decisao` usa um UUID novo como chave a cada chamada — se fosse usada uma chave fixa (como o nome da decisão), decisões repetidas ou similares poderiam se sobrescrever indevidamente.
- Guardar memória de longo prazo apenas em backend `in-memory` contraria o próprio propósito dessa memória (sobreviver entre sessões) — por isso a aula parte direto para PostgreSQL, sem demonstrar a versão em memória como fez na aula anterior com o checkpointer.

## Dúvidas para revisar

- Como implementar a tool de remoção de decisão proposta como desafio, usando `store.delete(namespace, key)`?
- Como evoluir a busca de projetos por nome para tolerar variações (busca aproximada ou semântica), antecipando os temas de embedding e RAG do restante do capítulo?
- Que outra estrutura de namespace faria sentido para armazenar preferências de usuário (não ligadas a um projeto específico), como mencionado de passagem na aula ("preferences" ou "user_context")?
