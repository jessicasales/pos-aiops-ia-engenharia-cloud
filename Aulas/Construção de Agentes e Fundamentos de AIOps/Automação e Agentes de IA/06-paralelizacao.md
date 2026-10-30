# Paralelização

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 06 — Paralelização (18:50) |
| **Assunto** | `RunnableParallel` para executar múltiplas análises independentes (fan-out) sobre a mesma entrada e consolidar os resultados (fan-in) em uma única chamada final |
| **Data** | 30/10/2026 00:25 |
| **Tags** | runnableparallel, fan-out, fan-in, paralelismo, consolidacao, multiplas-perspectivas |

## Resumo da aula

Quarto e último padrão de workflow do capítulo (depois de sequencial, com contrato, e com routing). Quando múltiplas etapas **não dependem umas das outras** e todas precisam ser executadas (não apenas uma, como no routing), o ideal é rodá-las **em paralelo**. A aula demonstra o padrão **fan-out/fan-in**: um mesmo incidente é analisado simultaneamente por três perspectivas independentes (pipeline, infraestrutura, aplicação), e os três resultados são depois consolidados em uma única resposta final.

## Conceitos principais

### Quando paralelizar

Requisito-chave: **nenhuma das etapas pode depender do resultado de outra**. Se o input de uma etapa é o output de outra (como no workflow sequencial), não há como paralelizar. Mas quando todas as etapas recebem o **mesmo input** e são independentes entre si — como analisar o mesmo incidente sob 3 perspectivas diferentes — não há motivo para executá-las uma após a outra; podem rodar simultaneamente, reduzindo o tempo total de execução.

### Fan-out e fan-in

- **Fan-out**: pegar uma mesma entrada e distribuí-la para múltiplos ramos de execução em paralelo.
- **Fan-in**: depois que todos os ramos terminam, consolidar/unir os resultados em uma etapa sequencial final.

Esse padrão já é comum em programação em geral (threads, múltiplos núcleos) — aqui aplicado à orquestração de chamadas a LLMs.

### `RunnableParallel` — o novo bloco

Análogo ao `RunnableBranch`, mas em vez de uma condicional escolhendo **um** ramo, agrupa vários `Runnable`s para serem executados **todos ao mesmo tempo**:

```python
analises_paralelas = RunnableParallel(
    pipeline=pipeline_chain,
    infraestrutura=infraestrutura_chain,
    aplicacao=aplicacao_chain,
)
```

Ao chamar `.invoke(entrada)`, cada chain recebe a **mesma entrada** e todas executam concorrentemente. O retorno é um dicionário cujas chaves são os nomes definidos (`pipeline`, `infraestrutura`, `aplicacao`) e os valores são os respectivos resultados.

### Comparação direta com `RunnableBranch`

| | `RunnableBranch` (routing) | `RunnableParallel` (paralelização) |
|---|---|---|
| Quantos ramos executam | Só um (o primeiro cuja condição seja verdadeira) | Todos, simultaneamente |
| Precisa de condicional | Sim | Não |
| Quando usar | Decidir **qual** caminho seguir | Executar **todos** os caminhos sobre a mesma entrada |

### Arquitetura do exemplo: análise de incidente sob 3 perspectivas

1. **Contrato `Analise`**: `perspectiva` (`Literal["pipeline", "infraestrutura", "aplicacao"]`), `evidencias` (lista), `hipotese`, `severidade` (`Literal["baixa", "media", "alta", "critica"]`).
2. **Contrato `AnalisesParalelas`**: um campo por ramo (`pipeline: Analise`, `infraestrutura: Analise`, `aplicacao: Analise`).
3. **Contrato `Consolidacao`**: `resumo`, `convergencias`, `divergencias`, `proximos_passos`.
4. **Contrato `Resultado`**: `analises: AnalisesParalelas` + `consolidacao: Consolidacao`.
5. Três chains independentes (`pipeline_chain`, `infraestrutura_chain`, `aplicacao_chain`), cada uma com seu próprio prompt (focado na perspectiva correspondente) e `with_structured_output(Analise)`.
6. `RunnableParallel` (fan-out) executando as três ao mesmo tempo sobre o mesmo `Incidente`.
7. Validação do resultado agregado com `AnalisesParalelas.model_validate(resultados)`.
8. `consolidacao_chain` (fan-in): recebe as três análises serializadas em JSON e produz a consolidação — instruída a **preservar divergências** entre as perspectivas, não transformar hipótese em fato, e propor apenas próximos passos de verificação (não correção).

### Workflow completo

```python
def executar_workflow(incidente: Incidente) -> Resultado:
    entrada = incidente.model_dump()
    resultados = analises_paralelas.invoke(entrada)       # fan-out
    analises = AnalisesParalelas.model_validate(resultados)
    consolidacao = consolidacao_chain.invoke(              # fan-in
        {"analises": analises.model_dump_json(indent=2)}
    )
    return Resultado(analises=analises, consolidacao=consolidacao)
```

### Por que devolver as análises individuais junto com a consolidação

O endpoint retorna tanto as 3 análises quanto a consolidação, mesmo a consolidação já conter o essencial — porque esse dado já foi processado (sem custo adicional) e permite verificação humana das perspectivas originais, não só do resumo final.

### Resultado observado no exemplo (incidente: erros 503 pós-deploy do checkout)

As três perspectivas convergiram em apontar o pool de conexões com o banco como fator relevante, todas classificando a severidade como **alta**, mas com **ênfases diferentes**: pipeline enfatiza uma possível alteração no checkout que elevou uso/retenção de conexões; infraestrutura enfatiza saturação/contenção da dependência sem fechar o mecanismo exato; aplicação considera mais provável contenção/esgotamento do pool com saturação progressiva pós-deploy. A consolidação preservou essas divergências explicitamente (em vez de arbitrariamente escolher uma) e listou próximos passos de verificação (comparar diffs, correlacionar métricas de pool por pod, verificar logs de timeout, validar o que os readiness checks realmente verificam — sem alterá-los antes de confirmar o diagnóstico).

## Comandos e configurações

```python
# src/contratos.py
from typing import Literal
from pydantic import BaseModel

class Incidente(BaseModel):
    titulo: str
    descricao: str

class Analise(BaseModel):
    perspectiva: Literal["pipeline", "infraestrutura", "aplicacao"]
    evidencias: list[str]
    hipotese: str
    severidade: Literal["baixa", "media", "alta", "critica"]

class AnalisesParalelas(BaseModel):
    pipeline: Analise
    infraestrutura: Analise
    aplicacao: Analise

class Consolidacao(BaseModel):
    resumo: str
    convergencias: list[str]
    divergencias: list[str]
    proximos_passos: list[str]

class Resultado(BaseModel):
    analises: AnalisesParalelas
    consolidacao: Consolidacao
```

```python
# src/workflow.py (resumo)
from langchain_core.runnables import RunnableParallel
from langchain_openai import ChatOpenAI

pipeline_chain = pipeline_prompt | ChatOpenAI(model="gpt-5.6-luna").with_structured_output(Analise)
infraestrutura_chain = infraestrutura_prompt | ChatOpenAI(model="gpt-5.6-luna").with_structured_output(Analise)
aplicacao_chain = aplicacao_prompt | ChatOpenAI(model="gpt-5.6-luna").with_structured_output(Analise)

analises_paralelas = RunnableParallel(
    pipeline=pipeline_chain,
    infraestrutura=infraestrutura_chain,
    aplicacao=aplicacao_chain,
)

consolidacao_chain = consolidacao_prompt | ChatOpenAI(model="gpt-5.6-luna").with_structured_output(Consolidacao)

def executar_workflow(incidente: Incidente) -> Resultado:
    entrada = incidente.model_dump()
    resultados = analises_paralelas.invoke(entrada)
    analises = AnalisesParalelas.model_validate(resultados)
    consolidacao = consolidacao_chain.invoke({"analises": analises.model_dump_json(indent=2)})
    return Resultado(analises=analises, consolidacao=consolidacao)
```

```bash
cd 04-parallel-workflow
uv sync
uv run fastapi dev src/app.py
```

```bash
curl --fail-with-body --request POST --header 'Content-Type: application/json' \
  --data @entradas/incidente.json http://127.0.0.1:8000/analises
```

## Pegadinhas

- Paralelizar etapas que têm dependência real entre si (uma precisa do resultado da outra) quebra a lógica do workflow — o requisito de independência não é opcional.
- A consolidação deve ser instruída explicitamente a **preservar divergências** entre as perspectivas — sem essa instrução, o modelo poderia "escolher" arbitrariamente uma das hipóteses como se fosse a única correta, perdendo informação valiosa.
- O fan-in (consolidação) só pode rodar depois que **todos** os ramos do fan-out terminaram — é inerentemente uma etapa sequencial após o paralelismo.
- Como no routing, a classificação/análise de cada perspectiva pode variar a cada execução — o texto exato das evidências e hipóteses não é determinístico.

## Dúvidas para revisar

- Como esse padrão de paralelização se compara, em termos de custo e tempo, com uma única chamada que pedisse ao modelo para analisar as 3 perspectivas de uma vez (sem RunnableParallel)?
- Vale combinar paralelização com routing — por exemplo, rodar paralelamente apenas as perspectivas relevantes, decidido por um roteador, em vez de sempre rodar as 3?
- Em quais outros cenários de AIOps esse padrão de "múltiplas perspectivas + consolidação com divergências preservadas" seria valioso (ex.: revisão de segurança, análise de performance)?
