# Embedding e Banco de Dados Vetorial

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 06 — Embedding e Banco de Dados Vetorial (47:56) |
| **Assunto** | Indexação prática com OpenAI Embeddings + pgvector: carregar Markdown/PDF, gerar vetores, persistir, buscar por similaridade e o impacto da granularidade (documento inteiro vs. página) |
| **Data** | 30/10/2026 01:15 |
| **Tags** | embedding, pgvector, openai-embeddings, pgweb, similarity-search, distancia-de-cosseno, chunking-preview |

## Resumo da aula

Primeira aula prática de RAG: implementa indexação e busca por similaridade usando **OpenAI Embeddings** (`text-embedding-3-small`) e **pgvector** (extensão vetorial do PostgreSQL), sem ainda envolver um agente — o objetivo é isolar e entender bem o mecanismo de embedding/busca antes de combiná-lo com um agente (próximas aulas). Usa o projeto `14-busca-vetorial-pgvector`, com documentos fictícios de pós-mortem (PDF) e runbooks (Markdown). Termina demonstrando, na prática, por que a **granularidade** da indexação (documento inteiro vs. por página) afeta diretamente o volume de contexto recuperado — gancho para a próxima aula, sobre chunking.

## Conceitos principais

### Modelo de embedding precisa ser o mesmo na indexação e na busca

Regra fundamental, repetida com ênfase: o modelo de embedding usado para **indexar** os documentos precisa ser **exatamente o mesmo** usado depois para transformar a **pergunta** em vetor na hora da busca — caso contrário, a comparação de distância vetorial não é válida. É possível, porém, misturar provedores diferentes para embedding e para inferência (ex.: embedding da OpenAI + inferência com Anthropic) — são categorias de modelo independentes, e nem todo provedor oferece ambas (ex.: a Anthropic só oferece modelos de inferência, não de embedding; OpenAI e Google oferecem os dois).

### `EMBEDDING_DIMENSIONS` — por que esse número importa

```python
COLLECTION = "documentos-operacionais-aula-06"
EMBEDDING_MODEL = "text-embedding-3-small"
# Tamanho do vetor que o modelo gera (está na documentação dele). O pgvector precisa
# desse número para criar a coluna vector(N); trocar de modelo exige reindexar.
EMBEDDING_DIMENSIONS = 1536

def embeddings() -> OpenAIEmbeddings:
    """Cria o mesmo modelo de embedding para indexação e consulta."""
    load_dotenv(ROOT / ".env")
    if not os.getenv("OPENAI_API_KEY"):
        raise SystemExit("Defina OPENAI_API_KEY no .env antes de continuar.")
    return OpenAIEmbeddings(model=EMBEDDING_MODEL, dimensions=EMBEDDING_DIMENSIONS)

def sqlalchemy_url(url: str) -> str:
    """Seleciona o driver psycopg usado pela integração do LangChain."""
    return url.replace("postgresql://", "postgresql+psycopg://", 1)
```

O tamanho do vetor que cada modelo de embedding gera é informado na documentação do próprio modelo, e precisa ser declarado tanto ao instanciar o modelo quanto ao criar a coluna vetorial no banco (`vector(N)` no pgvector). **Trocar de modelo de embedding exige reindexar tudo** — os vetores antigos, gerados por outro modelo, não são comparáveis aos novos.

### Carregando documentos — um `Document` do LangChain por arquivo

```python
def carregar_markdown(arquivo: Path) -> list[Document]:
    """Lê um runbook Markdown como uma unidade recuperável."""
    texto = arquivo.read_text(encoding="utf-8").strip()
    if not texto:
        raise SystemExit(f"O arquivo {arquivo.name} não contém texto extraível.")
    return [Document(id=arquivo.name, page_content=texto, metadata={"source": arquivo.name, "format": "md"})]

def carregar_pdf(arquivo: Path) -> list[Document]:
    """Extrai todo o PDF como uma única unidade recuperável."""
    textos = []
    for numero, pagina in enumerate(PdfReader(arquivo).pages, start=1):
        texto = (pagina.extract_text() or "").strip()
        if not texto:
            raise SystemExit(f"A página {numero} de {arquivo.name} não contém texto extraível.")
        textos.append(texto)
    if not textos:
        raise SystemExit(f"O PDF {arquivo.name} não contém páginas.")
    return [
        Document(
            id=arquivo.name,
            page_content="\n\n".join(textos),
            metadata={"source": arquivo.name, "format": "pdf", "pages": len(textos)},
        )
    ]
```

Markdown é lido diretamente como texto (`read_text`). PDF exige uma biblioteca de extração própria — `PdfReader` do pacote **`pypdf`** (fora do LangChain) — porque o formato PDF não é texto plano; é preciso percorrer cada página e extrair o texto com `extract_text()`. A regra geral: **o formato do arquivo determina a ferramenta de extração necessária** — HTML, código-fonte e outros formatos exigiriam suas próprias ferramentas de conversão para texto.

### Metadados — mais do que documentação, um mecanismo de busca

Cada `Document` carrega um `metadata` (dicionário chave-valor livre) — nome do arquivo, formato, quantidade de páginas, etc. O instrutor reforça que esses metadados **não são apenas informativos**: eles podem ser usados como critério de busca (busca por metadados, vista na aula anterior) em conjunto com a busca semântica. Recomendação prática: ser seletivo — como os metadados são persistidos e consomem espaço no banco, incluir apenas informações realmente úteis para busca/filtro.

### Gerando os embeddings (`indexar.py`)

```python
modelo = embeddings()
vetores = modelo.embed_documents([documento.page_content for documento in documentos])
if any(len(vetor) != EMBEDDING_DIMENSIONS for vetor in vetores):
    raise SystemExit("O modelo retornou vetores com dimensão diferente da configurada.")

banco = PGVector(
    embeddings=modelo,
    connection=sqlalchemy_url(database_url()),
    collection_name=COLLECTION,
    collection_metadata={"model": EMBEDDING_MODEL, "dimensions": EMBEDDING_DIMENSIONS},
    embedding_length=EMBEDDING_DIMENSIONS,
    pre_delete_collection=True,
    use_jsonb=True,
)
banco.add_embeddings(
    texts=[documento.page_content for documento in documentos],
    embeddings=vetores,
    metadatas=[documento.metadata for documento in documentos],
    ids=[documento.id for documento in documentos],
)
```

`embed_documents(...)` transforma o `page_content` de cada `Document` em vetor numérico. A classe **`PGVector`** (integração LangChain com pgvector) conecta à `collection` especificada, registrando o modelo e a dimensão nos metadados da própria coleção, e `add_embeddings(...)` persiste texto original, vetor, metadados e ID de uma vez.

### `collection` — agrupamento de embeddings, análogo a um "projeto"

A `collection_name` define o agrupamento lógico de documentos vetorizados dentro do mesmo banco — é possível ter várias collections para diferentes projetos/propósitos (ex.: `documentos-operacionais-aula-06`, uma collection separada para outro conjunto de dados). Esse conceito será retomado na aula de reindexação.

### pgvector — por que escolher PostgreSQL com extensão vetorial

**pgvector** é uma extensão do PostgreSQL que adiciona suporte a tipos e operações vetoriais, transformando o Postgre em um banco de dados vetorial completo. Vantagem prática destacada: times que já têm familiaridade operacional com PostgreSQL evitam a necessidade de homologar/validar uma solução de banco totalmente nova só para dar suporte a embeddings — reaproveitam conhecimento e infraestrutura já existentes. O instrutor recomenda essa opção tanto para projetos de estudo quanto para produção.

### Outras opções de banco vetorial (referência)

Listadas como alternativas de mercado, sem recomendação específica: Qdrant, Milvus, Weaviate, Chroma, OpenSearch, Elasticsearch, Pinecone (serviço gerenciado), e soluções embutidas como sqlite-vec e Zvec (rodam dentro da própria aplicação, sem servidor — citadas como exemplo de categoria, ainda pré-1.0). Opção "in-memory" também existe na documentação do LangChain, mas o instrutor a descarta pela mesma razão já aplicada à memória de longo prazo: não sobrevive a reinícios nem escala horizontalmente.

### `compose.yaml` — PostgreSQL com pgvector + pgweb

```yaml
services:
  postgres:
    image: pgvector/pgvector:pg17
    environment:
      POSTGRES_USER: aula
      POSTGRES_PASSWORD: aula
      POSTGRES_DB: vetores
    ports:
      - "127.0.0.1:55434:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U aula -d vetores"]
      interval: 2s
      timeout: 2s
      retries: 15

  pgweb:
    image: sosedoff/pgweb:0.17.0
    environment:
      DATABASE_URL: postgres://aula:aula@postgres:5432/vetores?sslmode=disable
    ports:
      - "127.0.0.1:58434:8081"
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
```

A imagem `pgvector/pgvector:pg17` já traz a extensão instalada; **pgweb** é uma interface web simples para inspecionar as tabelas criadas pelo LangChain: `langchain_pg_collection` (agrupadores) e `langchain_pg_embedding` (cada item: ID, vetor, texto original, metadados, referência à collection).

### Rodando a indexação

```bash
docker compose up -d
uv run indexar
```

No `pgweb` (`http://localhost:58434`), é possível ver na prática o texto original transformado em um vetor extenso de números ("esse conjunto de números loucos"), junto com os metadados persistidos (quantidade de páginas, formato, source).

### `buscar.py` — busca por similaridade

```python
banco = PGVector(
    embeddings=embeddings(),
    connection=sqlalchemy_url(url),
    collection_name=COLLECTION,
    embedding_length=EMBEDDING_DIMENSIONS,
    use_jsonb=True,
)
resultados = banco.similarity_search_with_score(args.pergunta, k=args.k)
```

A pergunta passa pelo **mesmo processo de embedding** usado na indexação, e `similarity_search_with_score` retorna os `k` documentos mais próximos, cada um acompanhado de uma **distância** (menor = mais similar; a métrica usada aqui é distância de cosseno).

```bash
uv run buscar "O consumidor da fila parou depois da troca da credencial. Como estabilizar?" --k 1
uv run buscar "O consumidor da fila parou depois da troca da credencial. Como estabilizar?" --k 3
```

- Com `--k 1`: retorna o post-mortem **PM-034** inteiro (atraso na fila de pagamentos por rotação de credenciais do broker) — alta relevância semântica com a pergunta.
- Com `--k 3`: retorna PM-034 (sempre presente, pois é o mais próximo), mais RB-381 (fila parada após rotação de credencial — outro documento relacionado) e PM-021 (regressão de API — relevância semântica mais fraca, mas ainda incluído por ser o terceiro mais próximo).

### O parâmetro `k` e o trade-off de volume de contexto

`k` controla quantos documentos retornar — e, consequentemente, quanto texto entra na janela de contexto. Mais `k` = mais contexto potencialmente útil, mas também mais consumo de janela de contexto; menos `k` = menos ruído, mas risco de faltar informação relevante. O instrutor reforça que essa é uma decisão de dosagem a ser calibrada conforme o caso de uso.

### O problema observado: indexar o documento inteiro traz contexto demais

Com a indexação atual (um PDF inteiro = um único `Document`), cada resultado de busca retorna o **PDF completo**, mesmo que só uma parte seja relevante — gerando uso excessivo de janela de contexto. Para demonstrar a mitigação, a aula reescreve `carregar_pdf()` para indexar **por página**:

```python
def carregar_pdf(arquivo: Path) -> list[Document]:
    """Extrai uma unidade recuperável por página do PDF."""
    documentos = []
    for numero, pagina in enumerate(PdfReader(arquivo).pages, start=1):
        texto = (pagina.extract_text() or "").strip()
        if not texto:
            raise SystemExit(f"A página {numero} de {arquivo.name} não contém texto extraível.")
        documentos.append(
            Document(
                id=f"{arquivo.name}#p{numero}",
                page_content=texto,
                metadata={"source": arquivo.name, "format": "pdf", "page": numero},
            )
        )
    return documentos
```

Cada página passa a ser um `Document` independente, com ID no formato `arquivo#pN` e o número da página nos metadados. Reindexando e repetindo a mesma busca com `--k 3`: os resultados agora trazem **páginas específicas** em vez de documentos inteiros — PM-034 página 3, PM-034 página 2, RB-381 (página única) — reduzindo significativamente o volume de texto por resultado, mantendo a relevância.

### Gancho para a próxima aula: chunking

O instrutor fecha deixando claro que a quebra em páginas foi só uma primeira demonstração do problema de granularidade — o tema mais amplo de **chunking** (estratégias de divisão de documentos para otimizar recuperação e uso de janela de contexto) é o assunto da próxima aula.

## Comandos e configurações

```bash
# .env
OPENAI_API_KEY=sua-chave-aqui
DATABASE_URL=postgresql://aula:aula@localhost:55434/vetores
```

```bash
cd 14-busca-vetorial-pgvector
docker compose up -d
uv run indexar
uv run buscar "O consumidor da fila parou depois da troca da credencial. Como estabilizar?" --k 1
uv run buscar "O consumidor da fila parou depois da troca da credencial. Como estabilizar?" --k 3
# abrir pgweb em http://localhost:58434
```

```text
# Documentação consultada na aula
Embedding models: https://docs.langchain.com/oss/python/integrations/embeddings
Vector stores: https://docs.langchain.com/oss/python/integrations/vectorstores
```

```text
# Bancos vetoriais citados como referência
pgvector (extensão do PostgreSQL): https://github.com/pgvector/pgvector
Qdrant: https://github.com/qdrant/qdrant
Milvus: https://github.com/milvus-io/milvus
Weaviate: https://github.com/weaviate/weaviate
Chroma: https://github.com/chroma-core/chroma
OpenSearch: https://github.com/opensearch-project/OpenSearch
Elasticsearch: https://github.com/elastic/elasticsearch
Pinecone (serviço gerenciado): https://www.pinecone.io
sqlite-vec (embutido, SQLite): https://github.com/asg017/sqlite-vec
Zvec (embutido, Alibaba): https://github.com/alibaba/zvec
```

(Ver trechos de código completos de `config.py`, `indexar.py` e `buscar.py` nas seções anteriores desta nota.)

## Pegadinhas

- Trocar o modelo de embedding depois de já ter indexado documentos exige **reindexar tudo** — os vetores antigos não são comparáveis aos vetores do novo modelo.
- A dimensão do vetor (`EMBEDDING_DIMENSIONS`) precisa bater exatamente entre o modelo de embedding e a configuração da coluna vetorial no banco — um valor errado causa erro ou, pior, dados inconsistentes.
- Indexar um documento inteiro como uma única unidade recuperável (um `Document` por PDF) faz com que **qualquer** busca relevante retorne o documento completo — mesmo quando só uma pequena parte é pertinente, inflando desnecessariamente a janela de contexto.
- `k` alto traz mais contexto potencialmente útil, mas às custas de mais consumo de janela de contexto e risco de incluir resultados de relevância semântica mais fraca (como o terceiro resultado do exemplo, que claramente tinha menor relação com a pergunta original).
- `pre_delete_collection=True` recria a coleção do zero a cada execução de `indexar` — conveniente para iteração em desenvolvimento, mas precisa ser usado com cuidado em um cenário real onde não se quer perder todo o histórico indexado a cada rodada.

## Dúvidas para revisar

- Como as estratégias de chunking (tema da próxima aula) vão refinar ainda mais essa granularidade, além da divisão por página de PDF já demonstrada aqui?
- Em que ponto a granularidade fica "excessiva" (chunks tão pequenos que perdem contexto necessário) — existe um equilíbrio ideal entre página inteira e fragmentos menores?
- Como ficaria a métrica de distância se outro tipo de métrica (produto interno, distância euclidiana) fosse usado em vez de distância de cosseno — isso é configurável no pgvector?
