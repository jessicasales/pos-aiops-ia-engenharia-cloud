# Testando a Ferramenta

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 03 — Testando a Ferramenta (19:06) |
| **Assunto** | Testes de unidade (esquema/Pydantic) e de integração (conta DigitalOcean real) gerados por IA (Claude Code, Plan Mode) para a ferramenta `listar_droplets` |
| **Data** | 30/10/2026 01:15 |
| **Tags** | pytest, teste-de-unidade, teste-de-integracao, plan-mode, conftest, mock, fixture |

## Resumo da aula

Como toda ferramenta (tool) é, no fundo, código determinístico, ela deve ser testada como qualquer código. A aula demonstra como usar um agente de codificação (Claude Code, em Plan Mode, com um modelo de reasoning forte — Opus 5.5) para projetar e implementar uma suíte de testes completa para a ferramenta `listar_droplets` do projeto `09-inventario-droplets`: testes de unidade (validação de esquema, sem tocar a DigitalOcean) e testes de integração (contra a conta real, criando e destruindo Droplets de teste automaticamente).

## Conceitos principais

### Dois tipos de teste: unidade vs. integração

- **Teste de unidade**: testa a funcionalidade isoladamente, sem se conectar a meios externos (banco de dados, serviços externos) — tipicamente usando mocks para simular essas dependências.
- **Teste de integração**: verifica se o código integra corretamente com a camada externa de fato — no caso de ferramentas conectadas a infraestrutura/cloud, esse é o teste que garante que o comportamento realmente funciona contra o serviço real. Demora mais (provisiona recursos reais), mas garante a conectividade de ponta a ponta.

Para ferramentas que conectam a ambientes de cloud, o instrutor reforça que o teste de integração é necessário, não opcional — um teste de unidade com mocks não captura, por exemplo, mudanças reais na API do provedor.

### Usar um agente de codificação, em Plan Mode, com modelo de reasoning forte

A criação dos testes é delegada ao Claude Code (poderia ser Codex ou outro), explicitamente em **Plan Mode** (modo de planejamento) e com um modelo de reasoning mais profundo — Opus 5.5 na aula (ou Sonnet, se Opus não disponível). A recomendação é usar o melhor modelo disponível para esse tipo de tarefa, que exige análise cuidadosa do código e do contrato de dados antes de agir.

### O prompt de planejamento (`prompt.md`)

```text
Este projeto expõe a ferramenta listar_droplets, usada por um agente LangChain, declarada de
duas formas: src/ferramentas/docstring.py e src/ferramentas/modelo_pydantic.py. A execução
fica em src/droplets.py e consulta a conta DigitalOcean.

Quero testes dessa ferramenta. Antes de criar qualquer coisa, analise o código em src/ e o
README.md, com as regras de cada argumento. Depois apresente:
1. Os casos de teste possíveis, numa tabela com: caso, tipo (unidade ou integração), entrada,
   resultado esperado e se precisa chamar a conta DigitalOcean.
2. O cenário de Droplets que os testes de integração precisam: o menor conjunto em que cada
   filtro tenha um Droplet que entra e outro que fica de fora, com nome, região, tamanho e
   status. Use os menores tamanhos que atendam aos filtros de memória.
Não crie nem altere nenhum arquivo. Pare depois disso e aguarde a minha aprovação.

Depois que eu aprovar, crie os testes aprovados com pytest em tests/ e execute:
- etapa inicial de setup: antes dos casos, a suíte cria o cenário aprovado na conta e espera
  cada Droplet chegar ao status esperado
- etapa final de teardown: ao terminar, mesmo com teste falhando, a suíte apaga os Droplets
  que criou
- os Droplets do cenário levam a tag inventario-droplets-testes; o teardown apaga só essa tag,
  e o resultado esperado olha só para ela, porque a conta pode ter outros Droplets
- setup e teardown usam o DIGITALOCEAN_TOKEN_SETUP; a ferramenta continua com o
  DIGITALOCEAN_TOKEN, só de leitura
- invoque a ferramenta direto, sem modelo e sem agente
- integração contra a conta real, sem mock
- pytest como dependência de desenvolvimento, adicionada com uv
- não altere src/ nem setup/, e não use os scripts de setup/
- não leia, crie nem edite o .env; os testes carregam os tokens dele ao rodar
- não imprima o valor de nenhuma variável de ambiente
- rode com uv run pytest -v e me mostre o resultado
- se algum teste falhar, não mude o teste nem o código para passar: explique a causa e pare
```

Pontos de design do prompt que valem ser destacados:
- Pede explicitamente a análise do código e do README **antes** de criar qualquer arquivo, e exige aprovação do plano antes de agir — típico fluxo de Plan Mode / SDD.
- Define regras claras de isolamento entre ambientes: a ferramenta testada usa sempre o token **só de leitura**; setup/teardown usam o token de escrita separado.
- Usa uma tag exclusiva (`inventario-droplets-testes`) para identificar e limpar apenas os recursos da suíte — a conta pode ter outros Droplets, e a suíte não deve tocá-los.
- Exige teardown garantido mesmo em caso de falha de teste.
- Proíbe explicitamente "fazer o teste passar" alterando código ou teste em caso de falha — pede que o agente explique a causa e pare, preservando o valor diagnóstico do teste.
- Proíbe imprimir variáveis de ambiente (evita leak de segredos em logs).

### Iteração durante a execução: falha real de provisionamento

Depois do plano aprovado, a execução revelou um problema real: a DigitalOcean não oferecia o tamanho de máquina de 512 MB na região `sfo` do cenário planejado. Seguindo a instrução do prompt ("não mude teste nem código para passar"), o agente **parou** e apresentou duas opções ao usuário:
1. Manter 512 MB e mudar a região para uma que ofereça esse tamanho.
2. Usar os tamanhos de 1 GB / 2 GB já disponíveis no ambiente de laboratório.

A instrutora/instrutor escolheu a opção 1, pedindo a região `nyc3`. O agente corrigiu, encontrou outros ajustes de provisionamento necessários, e rodou a suíte novamente — ilustrando bem o papel do humano no loop: o agente não decide sozinho como contornar uma falha de ambiente, ele expõe o trade-off e espera a escolha.

### `pyproject.toml` — pytest como dependência de desenvolvimento

```toml
[dependency-groups]
dev = [
    "pytest>=9.1.1",
]
```

O agente adicionou `pytest` no grupo `dev` via `uv`, sem alterar as dependências de produção da aplicação — exatamente como solicitado no prompt.

### `tests/conftest.py` — fixture de setup/teardown do cenário de integração

```python
"""Cenário dos testes de integração: cria os Droplets antes dos casos e apaga ao final.

Setup e teardown usam DIGITALOCEAN_TOKEN_SETUP (escrita). A ferramenta testada continua com
DIGITALOCEAN_TOKEN, só de leitura. Os tokens vêm do .env.
"""

import os
import time

import pytest
from dotenv import load_dotenv
from pydo import Client

load_dotenv()

TAG = "inventario-droplets-testes"
IMAGEM = "ubuntu-24-04-x64"

CENARIO = {
    # nome: (região, tamanho, status final)
    "teste-web-01": ("nyc1", "s-1vcpu-1gb", "active"),
    "teste-batch-01": ("ams3", "s-1vcpu-512mb-10gb", "off"),
}

def aguardar(cliente, droplet_id, status, tentativas=30) -> bool:
    for _ in range(tentativas):
        if cliente.droplets.get(droplet_id)["droplet"]["status"] == status:
            return True
        time.sleep(10)
    return False

@pytest.fixture(scope="session")
def cenario():
    cliente = Client(token=os.environ["DIGITALOCEAN_TOKEN_SETUP"])
    try:
        ids = {}
        for nome, (regiao, tamanho, _) in CENARIO.items():
            resposta = cliente.droplets.create(
                body={"name": nome, "region": regiao, "size": tamanho, "image": IMAGEM, "tags": [TAG]}
            )
            ids[nome] = resposta["droplet"]["id"]

        for nome, (_, _, status_final) in CENARIO.items():
            assert aguardar(cliente, ids[nome], "active"), f"{nome} não ficou active"
            if status_final == "off":
                # Recém-criado, o Droplet pode ignorar o shutdown: cai para power_off.
                cliente.droplet_actions.post(ids[nome], body={"type": "shutdown"})
                if not aguardar(cliente, ids[nome], "off", tentativas=18):
                    cliente.droplet_actions.post(ids[nome], body={"type": "power_off"})
                assert aguardar(cliente, ids[nome], "off"), f"{nome} não ficou off"

        yield CENARIO
    finally:
        # Roda mesmo com teste ou setup falhando. Só toca na tag da suíte.
        cliente.droplets.destroy_by_tag(tag_name=TAG)
```

Pontos técnicos:
- `@pytest.fixture(scope="session")`: o cenário é criado **uma vez** para toda a sessão de testes, não repetido por teste — importante para controlar custo e tempo.
- O bloco `try/finally`: o `destroy_by_tag` no `finally` garante o teardown **mesmo se o setup ou algum teste falhar** — requisito explícito do prompt.
- `yield CENARIO`: padrão clássico de fixture pytest — tudo antes do `yield` é setup, tudo depois (no `finally`) é teardown.

### `tests/test_esquema.py` — testes de unidade (sem tocar a DigitalOcean)

```python
"""Testes de unidade: o esquema de cada forma e a validação da forma Pydantic.

Nenhum chama a DigitalOcean: o esquema é gerado localmente, e na forma Pydantic o argumento
inválido é recusado antes de a função rodar.
"""

import pytest
from pydantic import ValidationError

from src.ferramentas.docstring import listar_droplets as forma_docstring
from src.ferramentas.modelo_pydantic import listar_droplets as forma_pydantic

ARGUMENTOS = ["regiao", "status", "memoria_minima_mb", "memoria_maxima_mb"]

def campo(ferramenta, nome) -> dict:
    """O ramo não nulo do campo no JSON Schema que o modelo recebe."""
    propriedade = ferramenta.tool_call_schema.model_json_schema()["properties"][nome]
    return next(ramo for ramo in propriedade["anyOf"] if ramo["type"] != "null")

def test_mesmo_nome_e_argumentos_nas_duas_formas():
    for ferramenta in (forma_docstring, forma_pydantic):
        assert ferramenta.name == "listar_droplets"
        assert list(ferramenta.args) == ARGUMENTOS

def test_esquema_pydantic_traz_as_regras():
    assert campo(forma_pydantic, "regiao")["pattern"] == "^[a-z]{3}[0-9]$"
    assert campo(forma_pydantic, "status")["enum"] == ["new", "active", "off", "archive"]
    assert campo(forma_pydantic, "memoria_minima_mb")["minimum"] == 512
    assert campo(forma_pydantic, "memoria_maxima_mb")["minimum"] == 512

def test_regra_minima_ate_maxima_fica_fora_do_esquema():
    # O model_validator não vira JSON Schema: a máxima só carrega o próprio piso.
    assert campo(forma_pydantic, "memoria_maxima_mb") == {"minimum": 512, "type": "integer"}

def test_esquema_docstring_so_tem_tipos_e_regras_em_prosa():
    for nome in ARGUMENTOS:
        assert set(campo(forma_docstring, nome)) == {"type"}

    descricao = forma_docstring.description
    assert "nyc1" in descricao
    assert "new, active, off ou archive" in descricao
    assert "no mínimo 512" in descricao

@pytest.mark.parametrize(
    "argumentos",
    [
        {"regiao": "NYC-1"},
        {"status": "running"},
        {"memoria_minima_mb": 256},
        {"memoria_maxima_mb": 256},
        {"memoria_minima_mb": 2048, "memoria_maxima_mb": 1024},
    ],
)
def test_pydantic_recusa_argumento_fora_da_regra(argumentos):
    with pytest.raises(ValidationError):
        forma_pydantic.invoke(argumentos)
```

Destaques:
- Confirma, via teste automatizado, exatamente o que a aula anterior mostrou manualmente com o script `inspecionar.py`: a forma Pydantic carrega regras estruturadas no schema (`pattern`, `enum`, `minimum`); a forma docstring só carrega `type`, com as regras em prosa na `description`.
- `test_regra_minima_ate_maxima_fica_fora_do_esquema`: confirma explicitamente, por teste, que o `@model_validator` **não aparece** no JSON Schema enviado ao modelo — só é aplicado em tempo de invocação.
- `test_pydantic_recusa_argumento_fora_da_regra`: testa que a forma Pydantic **rejeita** (`ValidationError`) valores fora das regras antes mesmo de a função rodar.
- Nenhum teste aqui chama a DigitalOcean — são testes de unidade puros, rápidos.

### `tests/test_listar_droplets.py` — testes de integração (conta real, sem mock)

```python
"""Testes de integração: a ferramenta contra a conta DigitalOcean real, sem mock.

Cada caso roda nas duas formas. A conta pode ter outros Droplets, então o resultado é
comparado só com os da tag da suíte.
"""

import json

import pytest

from conftest import TAG
from src.ferramentas.docstring import listar_droplets as forma_docstring
from src.ferramentas.modelo_pydantic import listar_droplets as forma_pydantic

pytestmark = pytest.mark.usefixtures("cenario")

FORMAS = pytest.mark.parametrize(
    "ferramenta", [forma_docstring, forma_pydantic], ids=["docstring", "pydantic"]
)

def nomes(resultado: str) -> set[str]:
    """Nomes dos Droplets devolvidos, só os da tag da suíte."""
    return {d["nome"] for d in json.loads(resultado) if TAG in d["tags"]}

@FORMAS
@pytest.mark.parametrize(
    "argumentos, esperado",
    [
        ({}, {"teste-web-01", "teste-batch-01"}),
        ({"regiao": "nyc1"}, {"teste-web-01"}),
        ({"status": "active"}, {"teste-web-01"}),
        ({"status": "off"}, {"teste-batch-01"}),
        ({"memoria_minima_mb": 1024}, {"teste-web-01"}),
        ({"memoria_maxima_mb": 512}, {"teste-batch-01"}),
        ({"memoria_minima_mb": 1024, "memoria_maxima_mb": 1024}, {"teste-web-01"}),
        ({"status": "active", "memoria_minima_mb": 1024}, {"teste-web-01"}),
        ({"regiao": "ams3", "status": "active"}, set()),
    ],
)
def test_filtros(ferramenta, argumentos, esperado):
    assert nomes(ferramenta.invoke(argumentos)) == esperado
```

Destaques:
- `pytestmark = pytest.mark.usefixtures("cenario")`: aplica a fixture de setup/teardown a **todos** os testes do arquivo.
- Cada caso de filtro é testado nas **duas formas** da ferramenta (docstring e Pydantic) — garantindo que ambas produzem o mesmo comportamento funcional, apesar da estrutura de declaração diferente.
- Compara o resultado só pelos Droplets com a tag da suíte — protegendo o teste de "ruído" de outros Droplets que possam existir na conta.
- Um teste adicional (`test_docstring_aceita_argumento_fora_da_regra`) documenta explicitamente uma diferença de comportamento entre as formas: a forma docstring, sem validação, **aceita** um argumento fora da regra (ex.: `"regiao": "NYC-1"` maiúsculo) e simplesmente retorna vazio (porque nenhum Droplet bate com esse valor), em vez de rejeitar com erro como a forma Pydantic faria.

### Execução manual da suíte

```bash
uv run pytest -v
```

Comportamento observado: os testes de unidade (esquema) passam quase instantaneamente, pois não dependem de rede; os testes de integração demoram mais, pois o `conftest.py` provisiona Droplets reais na conta (visíveis no painel da DigitalOcean durante a execução) antes de rodar os casos, e os destrói ao final — confirmado visualmente no painel da DigitalOcean (conta vazia antes, Droplets aparecendo durante, vazia novamente depois).

### A lição central: testar ferramentas como qualquer código, e deixar a IA fazer o trabalho pesado

O instrutor encerra reforçando que essa prática — testes de unidade + integração, gerados com apoio de um agente de codificação em Plan Mode — deve ser incorporada sempre que se cria uma ferramenta, especialmente quando ela integra com infraestrutura/ambiente real, seja a implementação em LangChain, seja via MCP (próximas aulas do capítulo).

## Comandos e configurações

```text
# prompt.md (resumo de uso)
Executado em Claude Code, Plan Mode, modelo Opus 5.5 (ou equivalente de reasoning forte).
```

```bash
uv run pytest -v
```

```toml
# pyproject.toml (trecho novo)
[dependency-groups]
dev = [
    "pytest>=9.1.1",
]
```

## Pegadinhas

- Testes de integração contra infraestrutura real geram custo real, ainda que pequeno (segundos/minutos de provisionamento) — é preciso prever e aceitar esse custo como parte do processo de teste.
- Quando o ambiente real não corresponde exatamente ao planejado (ex.: tamanho de máquina indisponível na região escolhida), um bom agente de codificação, bem instruído, **para e pergunta** em vez de simplesmente contornar silenciosamente o problema alterando teste ou código — isso só acontece porque o prompt pediu explicitamente esse comportamento.
- A regra de validação cruzada em Pydantic (`@model_validator`) não aparece no JSON Schema exposto ao modelo — isso precisa ser testado separadamente (como fez `test_regra_minima_ate_maxima_fica_fora_do_esquema`), já que um teste que só confere o schema não pegaria essa regra.
- A forma docstring sem validação aceita silenciosamente valores "errados" (ex.: região em maiúsculas) e apenas retorna um resultado vazio — isso pode mascarar um erro de uso real em produção, diferente da forma Pydantic, que rejeita explicitamente com `ValidationError`.
- O teardown precisa ser garantido mesmo em caso de falha (`try/finally`) — sem isso, um teste que falha no meio pode deixar recursos reais órfãos, gerando custo contínuo.

## Dúvidas para revisar

- Como estruturar testes de integração para uma ferramenta que executa ações de escrita irreversível (categoria vista na aula de introdução a ferramentas), onde não é possível simplesmente "destruir e recriar" o cenário de teste com segurança?
- Vale a pena incluir a criação de testes como etapa explícita dentro de um fluxo de Spec Driven Development (TRD/ADR), em vez de pedir separadamente como foi feito nesta aula?
- Como esse mesmo padrão de teste (unidade + integração, com setup/teardown via fixture) se aplicaria a uma ferramenta implementada como MCP Server, em vez de uma função LangChain direta?
