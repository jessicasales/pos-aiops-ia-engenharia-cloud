# Estratégias de Chunking e Tamanho do Chunk

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 07 — Estratégias de Chunking e Tamanho do Chunk (50:37) |
| **Assunto** | Chunking, overlap, `MarkdownHeaderTextSplitter` (por seção) vs. `RecursiveCharacterTextSplitter` (por tamanho), e o guia prático de qual estratégia usar por tipo de documento |
| **Data** | 30/10/2026 01:15 |
| **Tags** | chunking, overlap, markdownheadertextsplitter, recursivecharactertextsplitter, langchain-text-splitters, tamanho-de-chunk |

## Resumo da aula

Aula densa que formaliza o conceito de **chunking** já antecipado na aula anterior (quebra de PDF por página), explica o papel do **overlap** (sobreposição) para preservar continuidade semântica entre blocos, e implementa duas estratégias de divisão com LangChain: `MarkdownHeaderTextSplitter` (quebra por seção/título, usada para Markdown) e `RecursiveCharacterTextSplitter` (quebra por tamanho de caracteres, usada para PDFs de pós-mortem). Fecha com um guia prático de qual estratégia e quais parâmetros usar para cada tipo de conteúdo (runbook, pós-mortem, ticket, código, conversa, logs).

## Conceitos principais

### Chunking — quebrar documentos em unidades recuperáveis

**Chunking** é o processo de quebrar documentos/conteúdos em **unidades recuperáveis** menores, para que a busca semântica retorne apenas a informação necessária — em vez do documento inteiro (problema identificado na aula anterior). Riscos do chunking:
- **Corte de informação relacionada** entre chunks diferentes, perdendo a conexão entre partes do mesmo raciocínio.
- **Perda de contexto estrutural** — dados cortados/desestruturados podem levar o modelo a concluir, erroneamente, que não há informação suficiente para resolver o problema.

Vantagens que justificam usar chunking mesmo assim:
- Maior **precisão** na busca vetorial (cada vetor representa uma ideia mais específica).
- **Menos texto por pergunta** — preserva a janela de contexto.
- Maior **diversidade de uso de modelos de embedding** (cada modelo tem um limite de tamanho por chamada de embedding).
- Permite manter **referência granular** (arquivo + seção) nos metadados de cada chunk.

### Overlap (sobreposição) — preservando a continuidade entre chunks

**Overlap** é reaproveitar um pequeno trecho do final de um chunk no início do próximo (e vice-versa), de forma que uma frase cortada no limite entre dois chunks não perca sua continuidade de sentido. Exemplo ilustrativo: sem overlap, um chunk termina em "...antes de reiniciar, confirme" e o próximo começa em "a aprovação, depois valide o consumo" — a frase fica cortada e sem sentido isolado; com overlap, o segundo chunk repete "antes de reiniciar, confirme" junto com a continuação, preservando a frase completa dentro de uma mesma unidade.

O overlap não é sempre necessário — é mais importante quando o texto é corrido e as sentenças dependem de continuidade; é menos necessário em documentos já bem delimitados por seções/títulos.

### Estratégias de criação de chunks

- **Baseadas em tamanho**: quebra por quantidade de caracteres ou tokens, tipicamente combinada com overlap (texto livre, sem estrutura clara).
- **Baseadas na estrutura do próprio texto**: por parágrafo, por título/seção, por função (em código), por linha de log, etc.

### Ponto de partida recomendado para tamanho e overlap

Recomendação prática do instrutor: começar com **1.000 caracteres** para documentos pequenos, ou **2.000 caracteres** para documentos maiores, com overlap de **20%** do tamanho (200 e 400 caracteres, respectivamente). Fluxo de decisão sugerido: medir a maior seção que precisará ser quebrada e verificar se cabe no limite de tokens do modelo de embedding escolhido — se não couber, trocar de modelo ou reduzir o tamanho do chunk.

### O trade-off fundamental: precisão vs. contexto

Chunk menor → mais precisão na busca, porém menos contexto por resultado (risco de cortar no meio de uma sentença). Chunk maior → mais contexto por resultado, porém menos precisão (mais "diluição" semântica). **Não há uma fórmula única** — a decisão depende do tipo de conteúdo.

### Guia prático por tipo de documento

| Tipo de documento | Estratégia recomendada |
|---|---|
| Runbook, documento de arquitetura, documento de referência | Quebra por **seção** (títulos/subtítulos) — faz sentido semântico buscar por tópico |
| Pós-mortem / documento de incidente | Documento inteiro, se couber; senão, quebra **recursiva por caracteres** com overlap definido |
| Ticket / descrição de PR | Conteúdo inteiro (tipicamente curtos), vinculado aos anexos/documentos de apoio |
| Manifesto / arquivo de código | Um **recurso por chunk** |
| Conversa (troca de mensagens) | Blocos de **interação** (pergunta + resposta), para preservar o histórico contextual |
| Log / dados de observabilidade | **Não recomendado** usar RAG/embedding — dados mudam com muita frequência; reindexar continuamente é custoso e ineficiente. Preferir ferramentas de consulta direta (MCP conectado a Prometheus, Grafana Loki, etc.) |

### Projeto de exemplo: `15-chunking-dados-operacionais`

Nova dependência em relação ao projeto da aula anterior:

```toml
dependencies = [
    "langchain-core>=1.6.10",
    "langchain-openai>=1.7.2",
    "langchain-postgres>=0.0.19",
    "langchain-text-splitters>=1.1.3",
    "pypdf>=6.20.1",
    "python-dotenv>=1.2.4",
]
```

`langchain-text-splitters` traz as classes de divisão de texto usadas na aula.

### `indexar.py` — dividindo a base pela natureza do dado

```python
from chunking_dados_operacionais.gerar_chunks import (
    SOBREPOSICAO_LONGO,
    TAMANHO_LONGO,
    dividir_por_secao,
    dividir_recursivo,
)

def main() -> None:
    """Divide a base pela natureza de cada dado e indexa os chunks numa coleção do pgvector."""
    chunks = []
    # Markdown tem títulos: cada seção vira um chunk.
    for arquivo in sorted(DATA_DIR.glob("*.md")):
        chunks += dividir_por_secao(carregar_markdown(arquivo))
    # O PDF perde os títulos na extração: recursivo. Linha do tempo e causa são resposta longa,
    # por isso o ponto de partida longo (2000/400); é hipótese, não medição.
    for arquivo in sorted(DATA_DIR.glob("*.pdf")):
        chunks += dividir_recursivo(carregar_pdf(arquivo), TAMANHO_LONGO, SOBREPOSICAO_LONGO)
```

Decisão explícita de design: **Markdown (runbook, arquitetura) → divisão por seção**; **PDF (post-mortem) → divisão recursiva por tamanho**, porque o PDF perde a marcação de títulos ao ser extraído como texto puro.

### Metadados derivados do nome do arquivo

```python
# O nome do arquivo diz o tipo e o serviço: RB-381-payments-worker.md é um runbook do payments-worker.
TIPOS = {"RB": "runbook", "ARQ": "arquitetura", "REF": "referência", "PM": "post-mortem"}
SERVICOS = ["catalog-api", "payments-worker", "image-processor"]

def metadados(arquivo: Path) -> dict:
    """Monta o metadado do documento a partir do nome do arquivo."""
    tipo = TIPOS[arquivo.name.split("-")[0]]
    for servico in SERVICOS:
        if servico in arquivo.name:
            return {"source": arquivo.name, "tipo": tipo, "servico": servico}
    raise ValueError(f"Serviço desconhecido no nome do arquivo: {arquivo.name}")

def carregar_markdown(arquivo: Path) -> Document:
    """Lê o documento Markdown inteiro."""
    return Document(page_content=arquivo.read_text(encoding="utf-8"), metadata=metadados(arquivo))

def carregar_pdf(arquivo: Path) -> Document:
    """Extrai o texto de todas as páginas do post-mortem."""
    texto = "\n\n".join(pagina.extract_text() for pagina in PdfReader(arquivo).pages)
    return Document(page_content=texto, metadata=metadados(arquivo))
```

Uma convenção de nomenclatura de arquivo (prefixo de tipo + nome do serviço) é usada para extrair metadados automaticamente, sem precisar de um campo explícito dentro do próprio arquivo.

### `dividir_por_secao` — `MarkdownHeaderTextSplitter`

```python
from langchain_text_splitters import MarkdownHeaderTextSplitter, RecursiveCharacterTextSplitter

def dividir_por_secao(documento: Document) -> list[Document]:
    """Seção: corta nos títulos Markdown e põe o título no texto do chunk."""
    titulos = [("#", "h1"), ("##", "h2"), ("###", "h3")]
    secoes = MarkdownHeaderTextSplitter(headers_to_split_on=titulos).split_text(documento.page_content)

    servico = documento.metadata["servico"]
    tipo = documento.metadata["tipo"]
    chunks = []
    for secao in secoes:
        # Os títulos acima da seção, ex.: "RB-381 - Fila parada... > Procedimento de estabilização"
        caminho = " > ".join(secao.metadata.values())
        # Um "passo 4" sozinho não diz de qual procedimento é: o título vai junto no texto.
        texto = f"[{servico} | {tipo}] {caminho}\n\n{secao.page_content}"
        metadata = dict(documento.metadata)
        metadata["secao"] = caminho
        chunks.append(Document(page_content=texto, metadata=metadata))
    return chunks
```

Pontos centrais:
- `headers_to_split_on=[("#", "h1"), ("##", "h2"), ("###", "h3")]` delimita as seções pelos três níveis de título Markdown (e funcionaria da mesma forma com tags de título HTML, caso o conteúdo viesse nesse formato).
- O `MarkdownHeaderTextSplitter` **só aceita texto** — não preserva automaticamente os metadados do documento original; por isso são **recolocados manualmente** em cada chunk resultante.
- O **caminho da seção** (ex.: "RB-381 - Fila parada... > Procedimento de estabilização") é injetado **diretamente no texto** do chunk, não só nos metadados — motivo: um fragmento isolado como "passo 4" não diz, por si só, a qual procedimento pertence; colocar o título no próprio texto garante que a busca semântica "entenda" o contexto mesmo sem olhar metadados separadamente.
- Cada chunk recebe **todos os metadados do documento original**, mais um metadado adicional `secao` com o caminho — diferente do documento original (onde o metadado vive só uma vez), cada chunk precisa carregar sua própria cópia completa dos metadados.

### `dividir_recursivo` — `RecursiveCharacterTextSplitter`

```python
# Pontos de partida do recursivo, em caracteres; a sobreposição é 20% do tamanho.
TAMANHO_CURTO = 1000
SOBREPOSICAO_CURTO = 200
TAMANHO_LONGO = 2000
SOBREPOSICAO_LONGO = 400

def dividir_recursivo(documento: Document, tamanho: int, sobreposicao: int) -> list[Document]:
    """Recursivo: tenta o parágrafo; se não couber, a linha; depois a palavra."""
    splitter = RecursiveCharacterTextSplitter(chunk_size=tamanho, chunk_overlap=sobreposicao)
    return splitter.split_documents([documento])
```

Diferenças importantes em relação ao splitter por seção:
- Muito mais simples de usar — não exige definir marcadores de divisão.
- **Não garante tamanho exato e uniforme**: o `chunk_size` é um alvo, não um valor fixo — se o corte caísse no meio de uma palavra, o próprio splitter **ajusta o tamanho (tipicamente para menos)** para não quebrar a palavra, cortando preferencialmente em limites de parágrafo, depois linha, depois palavra (a ordem de tentativa que dá nome ao splitter — "recursivo").

### Rodando a indexação e observando os resultados

```bash
cd 15-chunking-dados-operacionais
docker compose up -d
uv run indexar
```

Resultado observado na primeira execução (tamanho longo = 2000/400): documentos de arquitetura/runbook/referência (todos por seção) geraram 36 chunks, com o maior chegando a 4.815 caracteres (sem limite rígido de tamanho na quebra por seção — a maior seção da base tinha cerca de 5 mil caracteres); os post-mortems (recursivo 2000/400) geraram 9 chunks, com o maior em 1.903 caracteres (ajustado para menos do alvo de 2000, para não quebrar palavra).

### Verificando no pgweb

Cada chunk aparece como uma linha própria na tabela `langchain_pg_embedding` — sem ID explícito definido no código (diferente da aula anterior, onde o ID era o nome do arquivo), o próprio processo de indexação atribui IDs automaticamente a cada chunk gerado recursivamente.

### Buscas por similaridade — o efeito de incluir contexto na pergunta

```bash
uv run buscar "taxa de status code, respostas 500 muito altas" --k 3
uv run buscar "aplicação catalog-api estava com status code de resposta 500 muito alto" --k 3
uv run buscar "aplicação catalog-api estava com status code de resposta 500 muito alto" --k 6
uv run buscar "aplicação catalog-api estava com status code de resposta 500 muito alto" --k 40
```

- Pergunta genérica (sem nome de serviço) → resultados vêm de documentos de **serviços variados** (payments-worker, etc.) — a busca semântica não tem como privilegiar um serviço específico se a pergunta não o menciona.
- Pergunta incluindo "catalog-api" → resultados se concentram em documentos **daquele serviço específico** — adicionar mais contexto relevante à pergunta muda completamente o conjunto de resultados retornados.
- Com `k` muito alto (40): mesmo tendo focado em catalog-api, em algum ponto a distância semântica cresce o suficiente para trazer de volta resultados de **outros serviços** — ilustrando concretamente o limite prático de aumentar `k` indiscriminadamente: a partir de certo ponto, os resultados adicionais deixam de ser realmente relevantes.

### Testando com chunks menores

```python
TAMANHO_LONGO = 1000
SOBREPOSICAO_LONGO = 200
```

```bash
docker compose down -v
docker compose up -d
uv run indexar
```

Com esses valores reduzidos pela metade, o post-mortem passou a gerar **20 chunks** em vez de 9, com o maior chegando exatamente a 1.000 caracteres (sem necessidade de ajuste, nesse caso, para evitar corte de palavra). O instrutor demonstra visualmente no pgweb como os blocos de texto ficam proporcionalmente muito menores.

## Comandos e configurações

```bash
cd 15-chunking-dados-operacionais
docker compose up -d
uv run indexar

uv run buscar "taxa de status code, respostas 500 muito altas" --k 3
uv run buscar "aplicação catalog-api estava com status code de resposta 500 muito alto" --k 3
uv run buscar "aplicação catalog-api estava com status code de resposta 500 muito alto" --k 6
uv run buscar "aplicação catalog-api estava com status code de resposta 500 muito alto" --k 40
```

```bash
# Testando outro tamanho de chunk para o PDF
docker compose down -v
docker compose up -d
uv run indexar
# TAMANHO_LONGO = 1000, SOBREPOSICAO_LONGO = 200 (editado em gerar_chunks.py)
```

(Ver trechos de código completos de `indexar.py`, `gerar_chunks.py` — `dividir_por_secao` e `dividir_recursivo` — nas seções anteriores desta nota.)

## Pegadinhas

- `MarkdownHeaderTextSplitter` não preserva automaticamente os metadados originais do documento em cada chunk — é preciso recolocá-los manualmente a cada seção gerada, ou essa informação se perde.
- Colocar o caminho da seção (ex.: "Procedimento de estabilização") só nos metadados, sem incluí-lo também no texto do chunk, pode deixar o conteúdo ambíguo para a busca semântica — um passo isolado ("passo 4") não diz, pelo texto, a qual procedimento pertence.
- `RecursiveCharacterTextSplitter` **não garante** que todos os chunks terão exatamente o `chunk_size` configurado — ele ajusta (geralmente para menos) para evitar cortar uma palavra no meio, então o valor configurado é um teto-alvo, não uma garantia absoluta.
- Aumentar `k` indiscriminadamente numa busca por similaridade pode trazer de volta resultados de relevância semântica muito mais fraca (até de documentos sobre assuntos/serviços completamente diferentes) — não existe "quanto mais k, melhor" sem limite.
- Usar chunks menores aumenta a quantidade total de unidades indexadas — o que, por sua vez, exige `k` maiores nas buscas para trazer contexto comparável ao que um chunk maior traria sozinho.
- Dados de observabilidade/logs são explicitamente **desencorajados** como alvo de indexação RAG — a alta frequência de mudança torna a reindexação cara e ineficiente; a alternativa recomendada é conectar ferramentas de consulta direta (MCP para Prometheus/Grafana Loki) em vez de vetorizar esse tipo de dado.

## Dúvidas para revisar

- Como calibrar, na prática, o valor de `k` ideal para um caso de uso específico — existe uma forma sistemática de medir isso (ex.: avaliar manualmente um conjunto de perguntas de teste), ou é só tentativa e ajuste?
- Para documentos híbridos (parte estruturada por título, parte em texto corrido), valeria a pena combinar as duas estratégias de chunking (seção + recursivo) no mesmo documento?
- Como o processo de reindexação completa (tema da próxima aula) se relaciona com a necessidade de reindexar toda vez que se ajusta o tamanho do chunk, como foi feito ao vivo nesta aula?
