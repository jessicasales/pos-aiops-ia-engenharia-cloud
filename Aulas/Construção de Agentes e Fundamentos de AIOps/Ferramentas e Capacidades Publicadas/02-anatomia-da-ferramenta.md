# Anatomia da Ferramenta

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 02 — Anatomia da Ferramenta e o Ciclo de Tool Calling (38:53) |
| **Assunto** | Estrutura completa de uma `tool` LangChain (docstring vs. Pydantic/`args_schema`), o ciclo de tool calling, e um agente real consultando Droplets da DigitalOcean |
| **Data** | 30/10/2026 01:15 |
| **Tags** | tool, docstring, parse_docstring, pydantic, args_schema, tool-calling, digitalocean, pydo, janela-de-contexto |

## Resumo da aula

Aula longa e prática: constrói um agente que consulta o inventário de Droplets (máquinas virtuais) de uma conta DigitalOcean, usando o projeto `09-inventario-droplets`. O foco é entender a **anatomia de uma ferramenta** LangChain em profundidade — não só "o que é uma tool", mas como ela é estruturada internamente e como o agente a "vê" — comparando duas formas de declarar os parâmetros (docstring simples vs. `parse_docstring=True` vs. modelo Pydantic com `args_schema`), e observando o **ciclo de tool calling** na prática (mensagem humana → decisão de chamar ferramenta → `ToolMessage` com resultado → resposta final). O instrutor reforça que o ciclo de execução e os requisitos de uma ferramenta são conceitualmente agnósticos de framework — mudará a biblioteca, não o conceito.

## Conceitos principais

### DigitalOcean como ambiente de prática

A DigitalOcean é recomendada pelo instrutor como provedor de cloud para ambiente de estudo: tem menos serviços que os grandes provedores (AWS, Azure, GCP), mas é muito mais barata — Droplets (máquinas virtuais), Kubernetes gerenciado, bancos de dados, modelos de IA. O curso promete exemplos equivalentes com AWS mais adiante, mas usa DigitalOcean aqui por custo e simplicidade de setup.

### Toda ferramenta é, no fundo, uma função — com 3 requisitos

Reforçando o que já apareceu em aulas anteriores, mas agora de forma mais estruturada, toda tool LangChain precisa de:
1. O decorator `@tool` (de `langchain.tools`), que sinaliza que aquela função é uma ferramenta.
2. O **contrato** da função — os parâmetros que ela recebe.
3. Uma **documentação clara** (descrição + descrição de cada argumento) — essencial porque é isso que o agente "lê" para decidir quando e como chamar a ferramenta.

### Forma 1 — Docstring simples (dados simples: string, número)

```python
from langchain.tools import tool

from src.droplets import consultar_droplets

@tool
def listar_droplets(
    regiao: str | None = None,
    status: str | None = None,
    memoria_minima_mb: int | None = None,
    memoria_maxima_mb: int | None = None,
) -> str:
    """Lista os Droplets da conta DigitalOcean, com filtros opcionais.

    Args:
        regiao: Slug da região em minúsculas, como nyc1. Sem região, lista todas.
        status: Status do Droplet: new, active, off ou archive. Sem status, lista todos.
        memoria_minima_mb: Memória mínima em MB, no mínimo 512.
        memoria_maxima_mb: Memória máxima em MB, no mínimo 512 e maior ou igual à mínima.
    """
    return consultar_droplets(regiao, status, memoria_minima_mb, memoria_maxima_mb)
```

Nessa forma simples, **sem** `parse_docstring=True`, toda a documentação — descrição da função + descrição de cada argumento — vai para um único campo `description` no JSON que o modelo recebe, misturado em um bloco de texto só.

### Detalhe prático: quanto detalhar os parâmetros depende do modelo

Sobre descrever valores possíveis de `regiao` (ex.: `nyc1`): o quanto detalhar depende do modelo usado. Modelos recentes (como o Sonnet, usado na aula) provavelmente já "sabem" como a DigitalOcean nomeia suas regiões, então não é preciso listar todas no prompt/docstring. Ressalva importante: o conhecimento do modelo pode estar desatualizado em relação ao estado atual do provedor de cloud (AWS, Azure e GCP criam novas regiões/data centers constantemente) — nesses casos, pode valer a pena criar uma ferramenta própria que liste as regiões disponíveis em tempo real, em vez de confiar no conhecimento estático do modelo.

### Script `inspecionar.py` — vendo exatamente o que o agente recebe

```python
import argparse
import json

from langchain_anthropic.chat_models import convert_to_anthropic_tool

from src.ferramentas import docstring, modelo_pydantic

FORMAS = {
    "1": ("docstring", docstring.listar_droplets),
    "2": ("Pydantic", modelo_pydantic.listar_droplets),
}

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Mostra o que o modelo recebe de cada forma da ferramenta."
    )
    parser.add_argument("forma", nargs="?", choices=FORMAS, help="Sem forma, mostra as duas.")
    args = parser.parse_args()

    for numero in [args.forma] if args.forma else FORMAS:
        nome, ferramenta = FORMAS[numero]
        enviado = convert_to_anthropic_tool(ferramenta)

        print(f"\n===== {numero}. {nome} =====")
        print(f"name: {enviado['name']}")
        print(f"description: {enviado['description']}")
        print("input_schema:")
        print(json.dumps(enviado["input_schema"], indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
```

```bash
uv run src/inspecionar.py 1
```

Ferramenta pedagógica importante: `convert_to_anthropic_tool` mostra exatamente o JSON (`name`, `description`, `input_schema`) que é enviado ao modelo — sem chamar a API nem a DigitalOcean. Com a docstring simples (sem `parse_docstring`), toda a documentação de parâmetros aparece dentro de um único `description` geral; o `input_schema` tem as propriedades (`regiao`, `status`, etc.), mas sem descrição individual por campo.

### `parse_docstring=True` — estruturando a documentação por parâmetro

```python
@tool(parse_docstring=True)
def listar_droplets(
    regiao: str | None = None,
    status: str | None = None,
    memoria_minima_mb: int | None = None,
    memoria_maxima_mb: int | None = None,
) -> str:
    """Lista os Droplets da conta DigitalOcean, com filtros opcionais.

    Args:
        regiao: Slug da região em minúsculas, como nyc1. Sem região, lista todas.
        status: Status do Droplet: new, active, off ou archive. Sem status, lista todos.
        memoria_minima_mb: Memória mínima em MB, no mínimo 512.
        memoria_maxima_mb: Memória máxima em MB, no mínimo 512 e maior ou igual à mínima.
    """
    return consultar_droplets(regiao, status, memoria_minima_mb, memoria_maxima_mb)
```

Com `parse_docstring=True` no decorator, o `description` da ferramenta passa a conter **só** a frase de objetivo ("Lista os Droplets..."), e cada parâmetro do `input_schema` ganha sua própria `description`, extraída do bloco `Args:` da docstring — a mesma informação, mas vinculada diretamente a cada propriedade, em vez de concentrada num texto só. O instrutor é explícito: isso não é só estética — quanto melhor estruturado o contexto por parâmetro, melhor o agente interpreta e usa a ferramenta corretamente.

### Implementação separada — `consultar_droplets` em `src/droplets.py`

```python
import json
import os

from pydo import Client

def resumir(droplet) -> dict:
    ip_publico = next(
        (rede["ip_address"] for rede in droplet["networks"]["v4"] if rede["type"] == "public"),
        None,
    )
    return {
        "id": droplet["id"],
        "nome": droplet["name"],
        "status": droplet["status"],
        "regiao": droplet["region"]["slug"],
        "tamanho": droplet["size_slug"],
        "vcpus": droplet["vcpus"],
        "memoria_mb": droplet["memory"],
        "disco_gb": droplet["disk"],
        "ip_publico": ip_publico,
        "tags": droplet["tags"],
        "criado_em": droplet["created_at"],
    }

def consultar_droplets(regiao, status, memoria_minima_mb, memoria_maxima_mb) -> str:
    print(
        f"Ferramenta: listar_droplets(regiao={regiao!r}, status={status!r}, "
        f"memoria_minima_mb={memoria_minima_mb!r}, memoria_maxima_mb={memoria_maxima_mb!r})"
    )

    cliente = Client(token=os.environ["DIGITALOCEAN_TOKEN"])
    droplets = cliente.droplets.list()["droplets"]

    # A API não filtra por esses campos: o filtro é feito aqui.
    if regiao:
        droplets = [d for d in droplets if d["region"]["slug"] == regiao]
    if status:
        droplets = [d for d in droplets if d["status"] == status]
    if memoria_minima_mb is not None:
        droplets = [d for d in droplets if d["memory"] >= memoria_minima_mb]
    if memoria_maxima_mb is not None:
        droplets = [d for d in droplets if d["memory"] <= memoria_maxima_mb]

    return json.dumps([resumir(d) for d in droplets], ensure_ascii=False)
```

A implementação real foi deixada em um arquivo separado para simplificar a comparação entre as duas formas de declarar a ferramenta (docstring vs. Pydantic) sem duplicar a lógica. Usa a biblioteca `pydo` (cliente oficial da DigitalOcean) para listar todos os Droplets e filtra **no lado da aplicação** (a API da DigitalOcean não suporta filtro nativo por região/status/memória nessa chamada).

### Segurança de token: escopo somente leitura para o agente, token separado para setup

Prática recomendada explicitada na aula: o token usado pelo **agente** (`DIGITALOCEAN_TOKEN`) deve ter escopo restrito — nesse caso, somente leitura de Droplets (`droplet:read`) — enquanto um **token separado** (`DIGITALOCEAN_TOKEN_SETUP`), com acesso total, é usado apenas pelos scripts de setup/teardown (que criam e destroem Droplets de teste), nunca pelo próprio agente. Essa separação limita o blast radius de qualquer comportamento inesperado do agente.

### Setup e teardown dos Droplets de teste

```bash
uv run setup/criar_droplets.py    # cria web-01, worker-01 (nyc1) e batch-01 (sfo3)
uv run setup/destruir_droplets.py # apaga tudo que tem a tag "inventario-droplets"
```

Scripts que criam uma base de dados de teste cobrindo os filtros da ferramenta (regiões diferentes, status diferentes, perfis de memória diferentes), e depois destroem tudo ao final — importante porque Droplets são cobrados enquanto existirem.

### O ciclo de tool calling, observado na prática

Ao executar `uv run src/app.py "Quantas máquinas eu tenho nesse momento em cada região?"`, o instrutor descreve o fluxo interno:
1. A pergunta entra como `HumanMessage`.
2. O agente decide que precisa de dados externos e identifica qual ferramenta usar (`listar_droplets`), com todos os filtros nulos (quer tudo).
3. A execução da ferramenta gera uma `ToolMessage`, contendo o resultado (JSON com todos os Droplets).
4. Baseado na `ToolMessage`, o agente monta a resposta final para o usuário.

Pontos técnicos reforçados:
- **Toda chamada de ferramenta consome a janela de contexto** — quanto mais chamadas de ferramenta, mais a janela se enche. Vale considerar filtrar os campos retornados pela ferramenta (em vez de um "get all" com tudo), para controlar o que entra na janela de contexto.
- **O resultado da ferramenta não gera cobrança direta de token de output** — é o modelo recebendo e interpretando essas informações depois que vira token de input; a chamada da função em si não é tokenizada como output.

### Comportamento observado (forma docstring)

```bash
uv run src/app.py "Quantas máquinas eu tenho nesse momento em cada região?"
# → nyc1: 2, sfo3: 1 (total: ~4 ou mais, conforme setup)

uv run src/app.py "Quantas máquinas eu tenho nesse momento na região de New York City 1 e com mais de 1 GB de RAM?"
# → agente chama listar_droplets com regiao="nyc1", memoria_minima_mb=1024
```

O agente identifica corretamente quais parâmetros preencher com base na pergunta em linguagem natural, deixando os demais como `None`.

### Forma 2 — Modelo Pydantic com `args_schema` (dados complexos/tipados)

```python
from typing import Literal

from langchain.tools import tool
from pydantic import BaseModel, Field, model_validator

from src.droplets import consultar_droplets

class FiltroDroplets(BaseModel):
    regiao: str | None = Field(
        default=None,
        pattern=r"^[a-z]{3}[0-9]$",
        description="Região do Droplet. Sem região, lista todas.",
    )
    status: Literal["new", "active", "off", "archive"] | None = Field(
        default=None, description="Status do Droplet. Sem status, lista todos."
    )
    memoria_minima_mb: int | None = Field(
        default=None, ge=512, description="Memória mínima do Droplet, em MB."
    )
    memoria_maxima_mb: int | None = Field(
        default=None, ge=512, description="Memória máxima do Droplet, em MB."
    )

    # Regra entre campos: não aparece no esquema enviado ao modelo, só vale na validação.
    @model_validator(mode="after")
    def minima_ate_maxima(self):
        if (
            self.memoria_minima_mb is not None
            and self.memoria_maxima_mb is not None
            and self.memoria_minima_mb > self.memoria_maxima_mb
        ):
            raise ValueError("memoria_minima_mb não pode ser maior que memoria_maxima_mb")
        return self

@tool(args_schema=FiltroDroplets)
def listar_droplets(
    regiao: str | None = None,
    status: str | None = None,
    memoria_minima_mb: int | None = None,
    memoria_maxima_mb: int | None = None,
) -> str:
    """Lista os Droplets da conta DigitalOcean, com filtros opcionais."""
    return consultar_droplets(regiao, status, memoria_minima_mb, memoria_maxima_mb)
```

Quando os dados são mais complexos/estruturados — ou quando se quer **validação de regras entre campos** (como `memoria_minima_mb` não pode ser maior que `memoria_maxima_mb`) —, o padrão recomendado é um modelo Pydantic (igual ao já usado em workflows no curso), passado via `args_schema=`. Vantagens:
- `pattern` (regex) e `Literal` restringem os valores aceitos diretamente no schema (ex.: `status` só pode ser um dos 4 valores válidos).
- `ge=512` valida limites numéricos.
- `@model_validator(mode="after")` valida regras **entre** campos (ex.: mínima ≤ máxima) — essa regra específica **não aparece** no schema enviado ao modelo, só é aplicada na validação em tempo de execução; se o agente enviar valores inválidos, a validação falha e o erro retorna ao agente, que pode se autocorrigir.
- A docstring da função, nesse caso, carrega **só** a descrição geral — os detalhes de cada campo ficam no modelo Pydantic.

O instrutor ressalva: os dois modelos (plano com docstring vs. Pydantic com `args_schema`) funcionam tecnicamente; a escolha depende da complexidade dos dados e da necessidade de validação cruzada entre campos.

### Trocar entre as formas é só trocar o import

```python
# Troque o módulo para mudar a forma da ferramenta: docstring · modelo_pydantic
from src.ferramentas.modelo_pydantic import listar_droplets
```

Nada no resto do `app.py` muda — só a linha de import da ferramenta. Demonstra como a estrutura de declaração da tool é desacoplada do resto do agente.

### Observação sobre variação de formato na resposta

Ao repetir a mesma pergunta ("Quantas máquinas eu tenho nesse momento?"), o formato da resposta varia entre execuções — porque o System Prompt não fixa um formato de saída, e o agente é probabilístico por natureza. Se um formato consistente for necessário, isso precisa ser especificado explicitamente no System Prompt.

## Comandos e configurações

```bash
# .env.example
# Copie para .env e preencha. O .env está no .gitignore e nunca deve ser commitado.
ANTHROPIC_API_KEY=sua-chave-aqui
MODELO=claude-sonnet-5

# Token do exemplo: escopo customizado só com droplet:read.
DIGITALOCEAN_TOKEN=seu-token-somente-leitura

# Token dos scripts de setup/teardown dos testes: cria e apaga Droplets.
# Não é usado pelo agente.
DIGITALOCEAN_TOKEN_SETUP=seu-token-de-setup
```

```bash
uv sync
uv run setup/criar_droplets.py

uv run src/inspecionar.py 1   # inspeciona a forma docstring
uv run src/inspecionar.py 2   # inspeciona a forma Pydantic
uv run src/inspecionar.py     # mostra as duas

uv run src/app.py "Quantas máquinas eu tenho nesse momento em cada região?"
uv run src/app.py "Quantas máquinas eu tenho nesse momento na região de New York City 1 e com mais de 1 GB de RAM?"
uv run src/app.py "Quantas máquinas eu tenho nesse momento?"
uv run src/app.py "Quantas máquinas eu tenho nesse momento por região?"

uv run setup/destruir_droplets.py
```

```python
# src/app.py
import argparse
import os

from dotenv import load_dotenv
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic

# Troque o módulo para mudar a forma da ferramenta: docstring · modelo_pydantic
from src.ferramentas.docstring import listar_droplets

load_dotenv()

if not os.getenv("ANTHROPIC_API_KEY"):
    raise SystemExit("Configure ANTHROPIC_API_KEY no arquivo .env antes de executar.")
if not os.getenv("DIGITALOCEAN_TOKEN"):
    raise SystemExit("Configure DIGITALOCEAN_TOKEN no arquivo .env antes de executar.")

SYSTEM_PROMPT = """
Você é um assistente de operações que consulta o inventário de Droplets da conta DigitalOcean.
Use a ferramenta listar_droplets para responder e não invente Droplets.
Você é especialista em DigitalOcean.
"""

model = ChatAnthropic(model=os.getenv("MODELO", "claude-sonnet-5"))

agent = create_agent(
    model=model,
    tools=[listar_droplets],
    system_prompt=SYSTEM_PROMPT,
)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Consulta o inventário de Droplets usando um agente com ferramenta."
    )
    parser.add_argument("pergunta", help='Ex.: "Quais Droplets ativos têm pelo menos 2 GB de memória?"')
    args = parser.parse_args()

    print(f"Pergunta: {args.pergunta}\n")

    resultado = agent.invoke({"messages": [("human", args.pergunta)]})

    print("\nResposta:")
    print(resultado["messages"][-1].text)

if __name__ == "__main__":
    main()
```

## Pegadinhas

- Sem `parse_docstring=True`, toda a documentação dos parâmetros fica dentro de um único campo `description` geral — funciona, mas é uma estrutura pior para o agente interpretar do que ter uma `description` específica por parâmetro no schema.
- A implementação da consulta nessa aula lista **todos** os Droplets e filtra no código da aplicação, porque a API da DigitalOcean (via `pydo`) não oferece filtro nativo por região/status/memória — o instrutor é transparente sobre isso ser uma limitação da API, não um erro de design.
- A regra de validação entre campos (`memoria_minima_mb` ≤ `memoria_maxima_mb`), definida com `@model_validator(mode="after")` em Pydantic, **não aparece** no schema que o modelo recebe — ela só é aplicada quando o agente efetivamente tenta chamar a ferramenta com esses valores; é uma garantia de execução, não de "conhecimento prévio" do agente.
- O token usado pelo agente deve ter escopo restrito (ex.: somente leitura); usar um token de acesso total no agente amplia innecessariamente o blast radius de qualquer comportamento inesperado.
- Toda chamada de ferramenta consome a janela de contexto — retornos muito verbosos (como um "get all" sem filtro de campos) enchem a janela mais rápido; vale considerar retornar só os campos relevantes.
- Droplets de teste geram custo real enquanto existem — sempre rodar o script de destruição ao terminar os testes.

## Dúvidas para revisar

- Em que cenários valeria a pena criar uma ferramenta adicional só para listar as regiões/tamanhos disponíveis em tempo real (em vez de confiar no conhecimento estático do modelo sobre o provedor de cloud)?
- Como ficaria a implementação se a API da DigitalOcean (ou outro provedor) suportasse filtro nativo — valeria a pena mover o filtro da aplicação para a chamada da API, por economia de dados transferidos e de janela de contexto?
- Em qual ponto a complexidade dos dados justifica migrar de docstring simples para Pydantic com `args_schema` — existe uma regra prática, ou é sempre caso a caso?
