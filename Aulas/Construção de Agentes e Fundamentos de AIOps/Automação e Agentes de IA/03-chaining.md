# Chaining

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 03 — Chaining (24:02) |
| **Assunto** | Diferença entre automação com IA e agente autônomo; workflow sequencial com prompt chaining usando LCEL (`prompt \| model \| StrOutputParser()`), triando um alerta de produção em 3 etapas (evidências → hipótese → plano) |
| **Data** | 29/10/2026 23:15 |
| **Tags** | chaining, prompt-chaining, lcel, chatprompttemplate, stroutputparser, workflow-sequencial, aiops |

## Resumo da aula

Aula central que estabelece a diferença conceitual entre **colocar IA em uma automação** (fluxo determinístico guiado pelo código, onde o modelo só é chamado em pontos específicos) e um **agente autônomo** (o próprio modelo decide o fluxo, para onde vai, quem aciona). Demonstra o primeiro padrão de workflow: **sequencial com prompt chaining** — uma cadeia de 3 chamadas ao LLM, onde o output de cada etapa alimenta o input da próxima — aplicado a um cenário real de AIOps: triagem de um alerta de produção (`CheckoutHighErrorRate`) em três etapas: extração de evidências → formulação de hipótese → plano de verificação.

## Conceitos principais

### Automação com IA vs. agente autônomo — a diferença real

Não é o simples fato de "ter uma conexão com o modelo" que define um agente. A diferença está na **autonomia e no fluxo de decisão**:
- **Automação com IA**: o fluxo é determinístico, guiado pelo código. O modelo é chamado em pontos específicos e bem definidos (ex.: resumir um texto, categorizar um ticket) — mas quem decide a sequência de passos é o código, não o modelo.
- **Agente**: o próprio modelo decide o fluxo a seguir — para onde a informação vai, quem é acionado, em qual sistema é inserida.

Importante: usar um agente onde um workflow simples resolveria adiciona complexidade e custo desnecessários sem agregar valor correspondente. Saber escolher a abordagem certa para cada cenário é o que diferencia um profissional.

### Workflow sequencial com prompt chaining

Conceito já visto em Engenharia de Prompt: uma sequência de chamadas ao LLM onde a saída de uma é a entrada da próxima (**prompt chaining**). Aqui aplicado como um workflow determinístico e controlado pelo código — o desenvolvedor sabe exatamente que depois da etapa de evidências vem a de hipótese, e depois dela vem o plano; não há ambiguidade sobre quantas etapas ocorrem ou em que ordem.

### `ChatPromptTemplate` — templates de prompt com variáveis

Análogo a um Helm Chart ou a templates de renderização server-side: permite declarar um prompt com variáveis que serão preenchidas em tempo de execução, em vez de strings fixas.

```python
prompt_evidencias = ChatPromptTemplate.from_messages([
    ("system", "Você analisa alertas operacionais. Extraia somente evidências presentes "
                "na entrada, sem formular causa ou ação."),
    ("human", "Alerta:\n\n{alerta}"),
])
```

Cada um dos 3 prompts da demo tem uma instrução de sistema diferente e espera uma variável diferente — só o primeiro prompt recebe um input "externo" (o alerta real); os dois seguintes recebem a saída da etapa anterior.

### LCEL — `prompt | model | StrOutputParser()`

Em vez de montar manualmente a chamada (combinar prompt + modelo + processar o retorno), o LangChain oferece o recurso de encadeamento **LCEL** (LangChain Expression Language), usando o operador pipe (`|`) para compor os componentes em uma única "chain":

```python
chain_evidencias = prompt_evidencias | model | StrOutputParser()
```

`StrOutputParser()` define o formato de saída desejado (aqui, string pura) — pode ser trocado por outros parsers (JSON, YAML, etc., vistos em aulas futuras). O mesmo padrão permite trocar o modelo usado (Gemini, Anthropic, GPT) sem alterar a estrutura do restante do código.

### Execução das 3 chains em sequência

```python
evidencias = chain_evidencias.invoke({"alerta": alerta})
hipotese = chain_hipotese.invoke({"evidencias": evidencias})
plano = chain_plano.invoke({"hipotese": hipotese})
```

Cada chamada usa `invoke` (não `stream`) porque o resultado completo é necessário para alimentar a próxima etapa — reforçando a recomendação da aula anterior sobre quando usar cada modo.

### O cenário de demonstração: alerta de produção

Input (`alerta.txt`): um alerta realista `CheckoutHighErrorRate` do serviço `checkout-api`, com taxa de erro de 18,4% (vs. baseline de 0,18%), rollout da versão `v2.14.0` concluído minutos antes do pico de erros, exceções `NullPointerException` ao tentar acessar `CouponDTO.getDiscount()` quando o `coupon-service` retorna um corpo vazio para determinados cupons, e dados de comparação por versão mostrando que a nova versão concentra os erros em requisições com cupom.

- **Etapa 1 (evidências)**: o modelo extrai, sem formular causa, os dados brutos relevantes — métricas, cronologia de mudanças, logs, estado das dependências, impacto operacional.
- **Etapa 2 (hipótese)**: a partir das evidências, formula uma única hipótese operacional, diferenciando fato de inferência — no caso, aponta um bug de regressão na v2.14.0 ao invocar `getDiscount()` sobre um objeto nulo.
- **Etapa 3 (plano)**: a partir da hipótese, monta um plano curto para **verificar** a hipótese (não corrigir ainda) — inspeção de diff de código, correlação de logs, reprodução em ambiente controlado.

### Por que isso ainda não é um agente

O desenvolvedor mantém controle total do fluxo: sabe que a sequência é sempre evidências → hipótese → plano, nessa ordem, sem variação. Um agente teria essa decisão (quais etapas rodar, em que ordem, se rodar todas) delegada ao próprio modelo.

### Chain of Thought vs. Prompt Chain — qual usar

Pergunta levantada na aula: poderia se fazer tudo em uma única chamada usando Chain of Thought em vez de encadear 3 chamadas separadas? Resposta do instrutor: depende — é necessário **experimentar** no próprio cenário para avaliar custo, velocidade e comportamento, já que não há uma resposta universal.

## Comandos e configurações

```toml
# pyproject.toml
[project]
name = "workflow-sequencial"
version = "0.1.0"
description = "Exemplo didatico de prompt chaining sequencial com LangChain"
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "langchain>=1.3.14",
    "langchain-google-genai>=4.4.0",
    "python-dotenv>=1.2.2",
]
```

```python
# src/app.py (resumo)
import os, sys
from pathlib import Path
from dotenv import load_dotenv
from langchain.chat_models import init_chat_model
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

load_dotenv()
if not os.getenv("GOOGLE_API_KEY"):
    raise SystemExit("Configure GOOGLE_API_KEY no arquivo .env antes de executar.")

model = init_chat_model("google_genai:gemini-3.8-flash")

prompt_evidencias = ChatPromptTemplate.from_messages([
    ("system", "Você analisa alertas operacionais. Extraia somente evidências presentes "
                "na entrada, sem formular causa ou ação."),
    ("human", "Alerta:\n\n{alerta}"),
])
prompt_hipotese = ChatPromptTemplate.from_messages([
    ("system", "Você formula uma única hipótese operacional a partir das evidências "
                "recebidas. Diferencie fato de inferência."),
    ("human", "Evidências:\n\n{evidencias}"),
])
prompt_plano = ChatPromptTemplate.from_messages([
    ("system", "Você cria um plano inicial e curto para verificar uma hipótese "
                "operacional. Não proponha correção antes da verificação."),
    ("human", "Hipótese:\n\n{hipotese}"),
])

alerta = Path("alerta.txt").read_text(encoding="utf-8")

chain_evidencias = prompt_evidencias | model | StrOutputParser()
chain_hipotese = prompt_hipotese | model | StrOutputParser()
chain_plano = prompt_plano | model | StrOutputParser()

evidencias = chain_evidencias.invoke({"alerta": alerta})
hipotese = chain_hipotese.invoke({"evidencias": evidencias})
plano = chain_plano.invoke({"hipotese": hipotese})
```

```bash
uv sync
uv run src/app.py
```

## Pegadinhas

- Ter uma conexão com um LLM em um fluxo não torna esse fluxo um "agente" — a autonomia de decisão é o critério, não a mera presença de uma chamada de IA.
- Usar um agente para resolver um problema que um workflow sequencial simples já resolve adiciona custo e complexidade sem ganho real.
- Não existe resposta universal entre "uma única chamada com Chain of Thought" vs. "prompt chaining em múltiplas chamadas" — é preciso testar no cenário real para avaliar custo, velocidade e qualidade do resultado.
- O parser de saída (`StrOutputParser` aqui) e o modelo usado são intercambiáveis sem alterar a estrutura da chain — mas trocar de string para JSON/YAML, por exemplo, muda o que o restante do código pode fazer com o resultado (tema de aula futura, "Outputs e Contratos").

## Dúvidas para revisar

- Em que ponto esse workflow de triagem de alerta deixaria de ser sequencial e passaria a precisar de ramificação condicional (ex.: se a hipótese indicar causa de infraestrutura vs. causa de código, seguir planos diferentes) — tema provável da aula "Routing"?
- Como ficaria o custo comparado entre essa abordagem de 3 chamadas separadas vs. uma única chamada com Chain of Thought, para esse mesmo alerta?
- Vale aplicar esse mesmo padrão de 3 etapas (evidências → hipótese → plano) a outros tipos de incidente além de erros de aplicação (ex.: incidentes de infraestrutura pura, picos de latência de rede)?
