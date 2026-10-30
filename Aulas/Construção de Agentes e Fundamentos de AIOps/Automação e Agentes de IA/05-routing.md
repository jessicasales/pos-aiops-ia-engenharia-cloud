# Routing

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 05 — Routing (35:12) |
| **Assunto** | `Runnable`, `RunnableBranch` e `RunnableLambda` do LangChain para criar workflows com desvio condicional (roteamento), classificando uma solicitação e direcionando para modelos/prompts especializados diferentes |
| **Data** | 30/10/2026 00:10 |
| **Tags** | routing, runnablebranch, runnablelambda, runnable, roteamento, literal, fallback, multiplos-providers |

## Resumo da aula

Evolução do workflow sequencial (Chaining) para um workflow com **desvio condicional**: em vez de sempre seguir a mesma sequência linear de etapas, o fluxo agora **decide o caminho** a seguir com base em uma classificação feita por um modelo roteador. Demonstração: um endpoint `POST /triagens` que recebe uma solicitação (título + descrição) e a classifica em uma de 4 categorias (`pipeline`, `infraestrutura`, `release`, `fallback`), cada uma tratada por um modelo e prompt **diferentes e independentes** — inclusive de provedores diferentes (OpenAI e Anthropic).

## Conceitos principais

### Por que routing — superando a limitação do fluxo linear

Mesmo com contratos tipados (aula anterior), o fluxo continuava **linear**: sempre as mesmas etapas, na mesma ordem. Mas incidentes/solicitações reais exigem diagnósticos diferentes dependendo da área (pipeline, infraestrutura, código) — cada área com seu próprio modelo, prompt e linha de execução. O routing resolve isso sem ainda ser um agente completo: o desenvolvedor continua sabendo **quais caminhos existem**, mas qual caminho será seguido depende de uma decisão (do modelo classificador ou de uma regra).

### `Runnable` — a base de tudo no LangChain

Qualquer objeto que possa ser executado via `.invoke()` no LangChain deriva de `Runnable`. Já usado implicitamente nas aulas anteriores (a chain `prompt | model | parser` é um `RunnableSequence`). Agora aparece uma nova derivação: **`RunnableBranch`**.

### `RunnableBranch` — condicional de execução

Cria uma estrutura de decisão equivalente a um `if/elif/.../else`: avalia condições **em ordem** e executa apenas o **primeiro** ramo cuja condição seja verdadeira; o último item (sem condição) é o caminho padrão.

```python
ramos = RunnableBranch(
    (lambda x: x > 10, RunnableLambda(lambda x: x * 10) | RunnableLambda(lambda x: x + 1)),
    (lambda x: x > 0, RunnableLambda(lambda x: x + 1)),
    RunnableLambda(lambda x: 0),  # caminho padrão (sem condição)
)
ramos.invoke(5)  # 6 — porque 5 não é > 10, mas é > 0, então soma 1
```

### `RunnableLambda` — tornar uma função Python executável na chain

Encapsula uma função Python comum (ou uma `lambda`) para que ela se comporte como um `Runnable`, podendo ser combinada com `|` e chamada via `.invoke()`.

### Condicional por valor fixo vs. condicional interpretativa

- **Valor fixo/determinístico**: ex. checar se `origem == "github_actions"` — uma condição booleana direta no código.
- **Interpretativa (routing com IA)**: um modelo classifica a entrada em uma categoria, e essa categoria decide o ramo — é isso que a aula demonstra.

### Arquitetura do exemplo: triagem de solicitações DevOps

1. **Contrato de entrada** (`Solicitacao`): `titulo` + `descricao`.
2. **Contrato de roteamento** (`Roteamento`): campo `destino` do tipo `Literal["pipeline", "infraestrutura", "release", "fallback"]` — restringe a resposta do modelo roteador a exatamente uma dessas 4 opções, garantida via `with_structured_output`.
3. **Router model**: um `ChatOpenAI`, com prompt que instrui a classificação em uma das 4 categorias (incluindo quando usar `fallback`: mais de uma intenção principal, ou nenhuma categoria serve).
4. **Chains especializadas**, cada uma com modelo e prompt próprios:
   - `pipeline_chain` → **Anthropic Sonnet** — analisa falhas de pipeline, separando evidências de hipóteses.
   - `infraestrutura_chain` → **OpenAI** (outro modelo que o roteador) — revisa infraestrutura como código, aponta riscos, não aplica a mudança.
   - `release_chain` → **Anthropic Haiku** — escreve comunicações curtas de release.
   - `fallback` → **nenhum provider** — resposta padrão pedindo esclarecimento/divisão da solicitação.
5. **`RunnableBranch`** que despacha, com base no campo `rota` do dicionário de entrada, para a função de tratativa correspondente (`tratar_pipeline`, `tratar_infraestrutura`, `tratar_release`, ou `tratar_fallback` como padrão).
6. **`executar_workflow`**: converte a solicitação em dicionário, invoca o `router_chain` para obter a decisão, injeta o campo `rota` no dicionário, e invoca o `RunnableBranch` com esse dicionário enriquecido.

### Multiplicidade de modelos/providers por rota

Ponto central da aula: cada ramo pode usar um **modelo e provedor completamente diferentes** — não há obrigação de usar o mesmo LLM em todo o workflow. Isso é descrito como um princípio que também vale para seleção dinâmica de modelo em agentes (tema futuro): escolher o modelo certo (custo/capacidade) para cada tipo de tarefa.

### `fallback` — tratamento do caso ambíguo

Quando a solicitação mistura mais de uma intenção (ex.: um texto que fala de falha de pipeline, mudança de Terraform e comunicado de release ao mesmo tempo), o roteador classifica como `fallback`, e a resposta é **padrão, sem chamar nenhum provider** — mais rápida e sem custo de IA, pedindo que a solicitação seja esclarecida/dividida antes de seguir para uma tratativa especializada.

### Avaliação necessária

O instrutor alerta: a classificação do roteador pode errar (falso positivo/negativo) — é necessário avaliar o comportamento real (callback ao conceito de *evaluation* já estudado) e ajustar prompts/exemplos quando a classificação não corresponder ao esperado.

## Comandos e configurações

```python
# src/contratos.py
from typing import Literal
from pydantic import BaseModel

class Solicitacao(BaseModel):
    titulo: str
    descricao: str

class Roteamento(BaseModel):
    destino: Literal["pipeline", "infraestrutura", "release", "fallback"]

class Resultado(BaseModel):
    rota: str
    provider: str
    modelo: str
    resposta: str
```

```python
# src/workflow.py (resumo)
from langchain_anthropic import ChatAnthropic
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableBranch, RunnableLambda

router_model = ChatOpenAI(model="gpt-5.6-luna")
router_prompt = ChatPromptTemplate.from_messages([
    ("system", "Classifique a solicitação em exatamente uma categoria: pipeline, "
                "infraestrutura, release, fallback (quando houver mais de uma "
                "intenção ou nenhuma categoria servir)."),
    ("human", "Título: {titulo}\n\nDescrição:\n{descricao}"),
])
router_chain = router_prompt | router_model.with_structured_output(Roteamento)

pipeline_chain = pipeline_prompt | ChatAnthropic(model="claude-sonnet-5") | StrOutputParser()
infraestrutura_chain = infraestrutura_prompt | ChatOpenAI(model="gpt-5.6-sol") | StrOutputParser()
release_chain = release_prompt | ChatAnthropic(model="claude-haiku-4-5-20251001") | StrOutputParser()

def tratar_pipeline(entrada): ...
def tratar_infraestrutura(entrada): ...
def tratar_release(entrada): ...
def tratar_fallback(entrada): ...  # não chama nenhum provider

branches = RunnableBranch(
    (lambda e: e["rota"] == "pipeline", RunnableLambda(tratar_pipeline)),
    (lambda e: e["rota"] == "infraestrutura", RunnableLambda(tratar_infraestrutura)),
    (lambda e: e["rota"] == "release", RunnableLambda(tratar_release)),
    RunnableLambda(tratar_fallback),
)

def executar_workflow(solicitacao: Solicitacao) -> Resultado:
    entrada = solicitacao.model_dump()
    decisao = router_chain.invoke(entrada)
    entrada_com_rota = {**entrada, "rota": decisao.destino}
    return branches.invoke(entrada_com_rota)
```

```bash
cd 03-routing-workflow
uv sync
uv run fastapi dev src/app.py
```

```bash
cd entradas
curl --fail-with-body --request POST --header 'Content-Type: application/json' \
  --data @falha-pipeline.json http://127.0.0.1:8000/triagens
# -> rota: pipeline, provider: anthropic, modelo: claude-sonnet-5

curl ... --data @release.json http://127.0.0.1:8000/triagens
# -> rota: release, provider: anthropic, modelo: claude-haiku-4-5-20251001

curl ... --data @revisao-terraform.json http://127.0.0.1:8000/triagens
# -> rota: infraestrutura, provider: openai, modelo: gpt-5.6-sol

curl ... --data @solicitacao-ambigua.json http://127.0.0.1:8000/triagens
# -> {"rota":"fallback","provider":"aplicacao","modelo":"nenhum","resposta":"..."}
```

## Pegadinhas

- `RunnableBranch` avalia as condições **em ordem** e para na primeira verdadeira — a ordem dos ramos importa.
- Esquecer o `@` ao referenciar um arquivo no `curl` (`--data @arquivo.json`) faz o comando enviar o nome do arquivo como string literal, em vez do conteúdo.
- Rodar a aplicação da aula anterior ainda ocupando a porta 8000 causa erro `[Errno 48] Address already in use` ao tentar subir uma nova instância — é preciso encerrar o processo anterior.
- O roteador pode classificar errado (falso positivo/negativo) — isso exige avaliação contínua do comportamento real, não apenas confiança cega no prompt do classificador.
- Cada chain mantém seu próprio modelo/provedor — misturar modelos de propósito (ex.: um barato para triagem, outro mais caro para a análise especializada) é uma prática válida e até recomendada.

## Dúvidas para revisar

- Como medir sistematicamente a taxa de erro do roteador (falsos positivos/negativos) nas 4 categorias, em vez de confiar só em testes manuais com exemplos pontuais?
- Vale adicionar mais categorias de rota conforme o projeto cresce, ou a lógica de `RunnableBranch` começa a ficar difícil de manter com muitos ramos?
- Como esse padrão de routing se conecta com a "seleção dinâmica de modelos" mencionada como tema futuro em agentes autônomos?
