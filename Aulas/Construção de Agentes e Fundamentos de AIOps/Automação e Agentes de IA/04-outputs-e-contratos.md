# Outputs e Contratos

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 04 — Outputs e Contratos (34:09) |
| **Assunto** | Substituir strings por contratos de dados tipados (Pydantic) na entrada e saída de cada etapa do workflow, expondo tudo via FastAPI com `with_structured_output` |
| **Data** | 29/10/2026 23:40 |
| **Tags** | pydantic, contratos, structured-output, json-schema, fastapi, basemodel, composicao-de-objetos |

## Resumo da aula

Evolução direta da aula "Chaining": em vez de passar **strings** entre as etapas do workflow (texto plano), a aula introduz **contratos de dados tipados** usando **Pydantic**, tanto na entrada (o que a API recebe) quanto na saída de cada etapa do workflow (evidências, hipótese, plano) e no retorno final. O projeto evolui de um script único (`uv run src/app.py`) para uma aplicação web real com **FastAPI**, expondo um endpoint `POST /analises` que recebe um `AlertaEntrada` e devolve uma `AnaliseIncidente` estruturada em JSON.

## Conceitos principais

### Por que strings deixam de ser suficientes

Trabalhar com string pura funciona bem quando quem consome a informação é uma pessoa (ela interpreta o texto naturalmente). Mas quando a comunicação é entre **sistemas** — múltiplos microserviços, múltiplos agentes, persistência em banco de dados — é necessário um **contrato** que garanta, na própria fronteira de comunicação, que os campos esperados estão presentes e no formato certo. Sem isso, cada integração vira "a bolsa do Gato Félix" — um saco que recebe qualquer coisa e o sistema seguinte tem que se virar para interpretar. Validar o contrato na entrada evita gastar processamento e tokens (custo) com dados que já estão incorretos.

### Pydantic — contratos como classes Python

O Pydantic permite declarar modelos de dados como classes, cada campo com tipo, regras de validação (`min_length`, `ge`, valor obrigatório ou padrão) e descrição:

```python
class AlertaEntrada(BaseModel):
    alerta: str = Field(min_length=1, description="Conteúdo bruto do alerta operacional")
    origem: str = Field(default="monitoramento", description="Sistema que enviou o alerta")
```

Se um sistema tentar se comunicar sem obedecer o contrato, uma exceção é lançada **antes** de qualquer chamada ao modelo de IA — ganho de segurança, confiabilidade e economia (não desperdiça tokens processando algo que já está incorreto).

### Composição de contratos

Contratos podem ser compostos por outros contratos — um padrão comum de projeto de software:

```python
class Evidencia(BaseModel):
    categoria: Literal["sintoma", "mudanca", "contexto"]
    descricao: str

class Evidencias(BaseModel):
    servico: str
    itens: list[Evidencia] = Field(min_length=1)
    mudanca_recente: str | None = Field(default=None)

class AnaliseIncidente(BaseModel):
    evidencias: Evidencias
    hipotese: Hipotese
    plano: PlanoVerificacao
```

### Onde colocar os contratos no projeto

Recomendação de organização: um arquivo separado (`contratos.py`, ou `models.py`/`modelos.py` quando o foco é domínio/persistência) — nunca misturado com a lógica de workflow ou com o endpoint da API.

### `with_structured_output` — ligando o contrato ao modelo

O LangChain tem integração nativa com Pydantic: basta declarar qual contrato cada chamada deve retornar.

```python
modelo_evidencias = model.with_structured_output(Evidencias, method="json_schema")
chain_evidencias = prompt_evidencias | modelo_evidencias
```

O retorno de `chain_evidencias.invoke(...)` passa a ser uma **instância do modelo Pydantic** (`Evidencias`), não mais uma string.

### Encadeamento com conversão explícita

Como cada etapa espera agora um contrato tipado (não mais uma string livre), ao passar o resultado de uma etapa para a próxima é preciso serializar explicitamente para JSON com `model_dump_json()`:

```python
evidencias = chain_evidencias.invoke({"origem": entrada.origem, "alerta": entrada.alerta})
evidencias_json = evidencias.model_dump_json()

hipotese = chain_hipotese.invoke({"evidencias": evidencias_json})
hipotese_json = hipotese.model_dump_json()

plano = chain_plano.invoke({"evidencias": evidencias_json, "hipotese": hipotese_json})
```

Vantagem adicional: cada prompt agora recebe só os **campos específicos** que precisa (ex.: `{origem}` e `{alerta}`), em vez de uma string gigante — economia de janela de contexto.

### Exposição via FastAPI

O projeto passa de um script de execução única para uma aplicação web persistente:

```python
from fastapi import FastAPI
from contratos import AlertaEntrada, AnaliseIncidente
from workflow import executar_workflow

app = FastAPI(title="Analise de Incidentes", ...)

@app.post("/analises")
def analisar_incidente(entrada: AlertaEntrada) -> AnaliseIncidente:
    return executar_workflow(entrada)
```

O FastAPI usa o próprio contrato Pydantic como **schema de validação automática** da requisição e da resposta — qualquer payload incompatível com `AlertaEntrada` é rejeitado antes de chegar à função.

### Observação sobre integração real com ferramentas de observabilidade

O instrutor nota que, na prática, ferramentas como o Alertmanager/Prometheus têm sua própria estrutura de payload — para integrar de fato, seria necessário ou adaptar o contrato de entrada para seguir essa estrutura, ou criar um adaptador (fora do escopo da aula, tema de arquitetura de software).

### Onde declarar isso ao trabalhar com IA assistida (gancho para SDD)

Reforço de um princípio recorrente do curso: ao especificar esse tipo de workflow via Spec Driven Development, a definição do contrato de comunicação (campos, tipos, regras) deve constar explicitamente da especificação/documento técnico, instruindo a IA a usar Pydantic — o importante não é a sintaxe exata, mas entender a estrutura para poder especificá-la corretamente.

## Comandos e configurações

```toml
# pyproject.toml
[project]
name = "outputs-contratos"
version = "0.1.0"
dependencies = [
    "fastapi[standard]>=0.141.1",
    "langchain>=1.3.14",
    "langchain-google-genai>=4.4.0",
    "pydantic>=2.13.4",
    "python-dotenv>=1.2.2",
]
```

```python
# src/contratos.py (resumo)
from typing import Literal
from pydantic import BaseModel, Field

class AlertaEntrada(BaseModel):
    alerta: str = Field(min_length=1, description="Conteúdo bruto do alerta operacional")
    origem: str = Field(default="monitoramento", description="Sistema que enviou o alerta")

class Evidencia(BaseModel):
    categoria: Literal["sintoma", "mudanca", "contexto"]
    descricao: str

class Evidencias(BaseModel):
    servico: str
    itens: list[Evidencia] = Field(min_length=1)
    mudanca_recente: str | None = Field(default=None)

class Hipotese(BaseModel):
    descricao: str
    evidencias_relacionadas: list[str] = Field(min_length=1)
    incertezas: list[str] = Field(default_factory=list)

class PassoVerificacao(BaseModel):
    ordem: int = Field(ge=1)
    acao: str
    evidencia_esperada: str

class PlanoVerificacao(BaseModel):
    objetivo: str
    passos: list[PassoVerificacao] = Field(min_length=1)
    criterio_encerramento: str

class AnaliseIncidente(BaseModel):
    evidencias: Evidencias
    hipotese: Hipotese
    plano: PlanoVerificacao
```

```bash
cd 02-outputs-contratos
uv sync
uv run fastapi dev src/app.py
```

```bash
curl --fail-with-body --request POST --header 'Content-Type: application/json' \
  --data @entrada.json http://127.0.0.1:8000/analises
```

## Pegadinhas

- Esquecer de converter o objeto Pydantic para JSON (`model_dump_json()`) antes de passá-lo como variável de template para a próxima etapa da chain causa erro, já que o template espera uma string.
- Adotar um contrato de entrada "de fachada" sem considerar o formato real das ferramentas de observabilidade (Alertmanager, Prometheus) exige um adaptador — não basta inventar a estrutura ideal sem compatibilizar com o que realmente chega.
- Copiar e colar comandos de terminal de slides/material pode falhar silenciosamente por formatação (quebra de linha, aspas) — vale sempre confirmar o comando antes de assumir que a falha é do código.
- `with_structured_output` muda o tipo de retorno de string para uma instância do modelo — qualquer código que ainda trata o resultado como string (ex.: concatenação direta) vai falhar.

## Dúvidas para revisar

- Como ficaria um adaptador real entre o payload do Alertmanager/Prometheus e o contrato `AlertaEntrada` do projeto?
- Vale persistir cada `AnaliseIncidente` gerada em um banco de dados, reaproveitando o mesmo contrato Pydantic como schema de armazenamento?
- Em que ponto a composição de contratos (`Evidencias` contendo lista de `Evidencia`) começa a ficar complexa demais para ser gerada de forma confiável por um modelo via `with_structured_output`?
