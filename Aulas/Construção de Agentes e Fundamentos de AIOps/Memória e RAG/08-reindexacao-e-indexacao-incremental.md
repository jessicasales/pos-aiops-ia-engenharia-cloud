# Reindexação e Indexação Incremental

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 08 — Reindexação e Indexação Incremental (45:29) |
| **Assunto** | Manter o banco vetorial sincronizado com a fonte: indexação incremental via hash SHA-256 (delete + add) e reindexação total (no lugar vs. collection nova, "blue-green" de dados) |
| **Data** | 30/10/2026 01:15 |
| **Tags** | indexacao-incremental, reindexacao, hash-sha256, ollama, embeddings-local, blue-green-collection, pgvector |

## Resumo da aula

Resolve um problema prático central do RAG: documentos institucionais mudam com frequência, mas atualizar a fonte (repositório, wiki) **não atualiza automaticamente** o banco vetorial — é preciso reindexar. A aula apresenta duas técnicas: **indexação incremental** (atualiza só o que mudou, usando hash do arquivo para detectar mudança, evitando custo de reembedding desnecessário) e **reindexação total** (regenera tudo, usada quando a própria estratégia de embedding/chunking muda), com duas variantes desta última — apagar e recriar no lugar, ou criar uma **collection nova ao lado** (padrão "blue-green" aplicado a dados vetoriais). Usa embeddings **locais via Ollama** neste exemplo, em vez de um provedor de API paga.

## Conceitos principais

### O problema: defasagem entre fonte e índice vetorial

Atualizar um documento na fonte (repositório, wiki institucional) não propaga automaticamente para o banco vetorial — é necessário reprocessar (embedding + persistência) explicitamente. Sem isso, o agente consulta uma versão desatualizada do conteúdo, mesmo que a fonte already reflita a mudança.

### Indexação incremental — quando usar

Usada ao **atualizar, criar ou remover** documentos individuais, **sem** mudar o modelo de embedding nem a estratégia de chunk. Motivação central: reindexar do zero a cada pequena mudança gera **custo real** (chamadas repetidas ao modelo de embedding) — irrelevante com poucos documentos, mas significativo em escala empresarial. A indexação incremental resolve isso indo direto à origem da mudança, processando só o que de fato mudou.

### Hash SHA-256 — detectando se o conteúdo mudou

```python
def hash_do_arquivo(arquivo: Path) -> str:
    """Impressão digital do conteúdo: muda se um byte do arquivo mudar."""
    return hashlib.sha256(arquivo.read_bytes()).hexdigest()
```

O hash é uma "impressão digital" do conteúdo — se nada mudou, o hash é idêntico; qualquer alteração, mesmo mínima, gera um hash diferente. O hash é persistido junto com os metadados de cada chunk no banco; a cada execução da indexação, compara-se o hash atual do arquivo com o hash gravado.

### `estado_no_indice` — consultando o que já está indexado

```python
def estado_no_indice(url: str, source: str) -> dict | None:
    """Lê do banco o hash gravado e os IDs dos chunks do documento, ou None se ele não está lá."""
    try:
        with psycopg.connect(url) as conexao:
            with conexao.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT e.id, e.cmetadata->>'hash'
                    FROM langchain_pg_embedding e
                    JOIN langchain_pg_collection c ON e.collection_id = c.uuid
                    WHERE c.name = %s AND e.cmetadata->>'source' = %s
                    """,
                    (COLECAO, source),
                )
                linhas = cursor.fetchall()
    except psycopg.errors.UndefinedTable:
        return None

    if not linhas:
        return None
    return {"hash": linhas[0][1], "ids": [id_chunk for id_chunk, _ in linhas]}
```

Consulta direta via SQL (`psycopg`) nas tabelas internas do LangChain (`langchain_pg_embedding`, `langchain_pg_collection`), filtrando pela coleção ativa e pelo `source` (nome do arquivo). Como todos os chunks de um mesmo documento compartilham o mesmo hash, basta ler o da primeira linha; os IDs de todos os chunks são retornados para permitir a remoção posterior, se necessário.

### Fluxo da indexação incremental: comparar, e só reprocessar se diferente

```python
def main() -> None:
    """Compara o documento com a coleção ativa e grava só se ele mudou."""
    ...
    hash_atual = hash_do_arquivo(arquivo)
    anterior = estado_no_indice(url, arquivo.name)

    # Mesmo hash: o conteúdo é o mesmo, nada a fazer e nenhuma chamada ao modelo.
    if anterior and anterior["hash"] == hash_atual:
        print(f"igual: {arquivo.name} | coleção {COLECAO}")
        return

    modelo = OllamaEmbeddings(model=EMBEDDING_MODEL, base_url=os.environ["OLLAMA_URL"])
    chunks = dividir(arquivo)
    vetores = modelo.embed_documents([chunk.page_content for chunk in chunks])

    banco = PGVector(...)

    if anterior:
        # Alterado: saem todos os chunks antigos do documento, entram os novos.
        banco.delete(ids=anterior["ids"], collection_only=True)
        situacao = "alterado"
    else:
        situacao = "novo"
    banco.add_embeddings(
        texts=[chunk.page_content for chunk in chunks],
        embeddings=vetores,
        metadatas=[{**chunk.metadata, "hash": hash_atual} for chunk in chunks],
        ids=[f"{COLECAO}/{arquivo.name}#{numero}" for numero in range(len(chunks))],
    )
    print(f"{situacao}: {arquivo.name} | {len(chunks)} chunks | coleção {COLECAO}")
```

Ponto central de design: **não existe "update"** — a operação é sempre **delete seguido de add**. Se o hash é idêntico, a função retorna imediatamente, **sem nenhuma chamada ao modelo de embedding** (economia direta de custo). Se mudou (ou é novo), gera os novos chunks, embeda, remove os chunks antigos daquele documento específico (se existiam) e adiciona os novos — com IDs estáveis no formato `{COLECAO}/{arquivo}#{numero}` (coleção + documento + posição do chunk).

### Demonstração da indexação incremental

```bash
uv run indexar dados/v1/RB-274-catalog-api.md
uv run buscar "Qual é o nome do usuário responsável?" --k 2
```

Primeira indexação (versão 1): a busca retorna "time de catálogo" como responsável (não é uma resposta de pessoa específica — o conteúdo original era genérico). Depois de editar o arquivo (versão 2, mudando a linha do responsável para um nome específico):

```bash
uv run indexar dados/v2/RB-274-catalog-api.md
uv run buscar "Qual é o nome do usuário responsável?" --k 2
```

A busca passa a retornar o novo nome — confirmando que a indexação incremental removeu o conteúdo antigo daquele documento e inseriu o atualizado.

### Reindexação total — quando usar

Usada quando a **estratégia de embedding muda**: outro modelo, outra dimensão de vetor, outra estratégia de chunking. Nesses casos, comparar hashes não ajuda — o problema não é "o conteúdo mudou", é "a forma de processar mudou", então **tudo** precisa ser reprocessado.

### Duas formas de reindexar: no lugar vs. collection nova

1. **Apagar e recriar no lugar** (mesma collection): mais simples, mas **não recomendado** pelo instrutor — perde qualquer histórico, e o sistema fica indisponível durante o processo (a coleção é apagada antes de ser recriada).
2. **Criar uma collection nova ao lado**: preserva a coleção anterior intacta, permite rollback instantâneo (voltar a apontar para a coleção antiga) e permite testes A/B entre estratégias de chunk/embedding diferentes. Analogia explícita usada: **Blue-Green Deployment**, aplicado a dados vetoriais em vez de versões de aplicação.

Recomendação do instrutor: preferir sempre a criação de nova collection, exceto em casos de restrição real de espaço em disco e certeza de que a versão antiga nunca mais será usada.

### `colecao_existe` e o fluxo de `reindexar.py`

```python
def colecao_existe(url: str) -> bool:
    """Confere no banco se a coleção da COLECAO já foi criada."""
    try:
        with psycopg.connect(url) as conexao:
            with conexao.cursor() as cursor:
                cursor.execute("SELECT 1 FROM langchain_pg_collection WHERE name = %s", (COLECAO,))
                return cursor.fetchone() is not None
    except psycopg.errors.UndefinedTable:
        return False

def main() -> None:
    """Gera de novo a base inteira da pasta, com ou sem mudança nos arquivos."""
    ...
    existe = colecao_existe(url)

    # Os embeddings vêm antes de apagar: se o modelo falhar, a coleção continua como estava.
    modelo = OllamaEmbeddings(model=EMBEDDING_MODEL, base_url=os.environ["OLLAMA_URL"])
    arquivos = sorted(pasta.glob("*.md"))
    chunks = []
    ids = []
    for arquivo in arquivos:
        hash_atual = hash_do_arquivo(arquivo)
        do_arquivo = dividir(arquivo)
        for numero, chunk in enumerate(do_arquivo):
            chunk.metadata = {**chunk.metadata, "hash": hash_atual}
            ids.append(f"{COLECAO}/{arquivo.name}#{numero}")
        chunks += do_arquivo
    vetores = modelo.embed_documents([chunk.page_content for chunk in chunks])

    banco = PGVector(...)

    if existe:
        # Apagar a coleção leva todos os chunks dela, até de documento que saiu da pasta.
        banco.delete_collection()
        banco.create_collection()

    banco.add_embeddings(texts=..., embeddings=vetores, metadatas=..., ids=ids)
    situacao = "existente, apagada e criada de novo" if existe else "nova, ao lado das outras"
```

Pontos de desenho importantes:
- **Ordem deliberada**: os embeddings são gerados **antes** de apagar a coleção existente — se a chamada ao modelo falhar, a coleção antiga permanece intacta, nenhum dado é perdido pela metade.
- Trabalha sobre a **pasta inteira**, não arquivo por arquivo (diferente da indexação incremental) — reindexação é um processo de regeneração completa de uma versão/estratégia.
- Usa os **mesmos IDs e hashes** do fluxo incremental — garantindo que, depois de uma reindexação total, o processo incremental possa continuar normalmente a partir daquele ponto.
- Deletar e recriar a coleção também remove automaticamente chunks de documentos que **saíram** da pasta (foram removidos da fonte) — um "limpa tudo" implícito.

### Demonstrações de reindexação

```bash
uv run reindexar dados/v1
uv run buscar "Qual é o nome do usuário responsável?" --k 2

uv run reindexar dados/v2
uv run buscar "Qual é o nome do usuário responsável?" --k 6

uv run reindexar dados/v1
uv run buscar "Qual é o nome do usuário responsável?" --k 6
```

No reindexamento "no lugar" (mesma `COLECAO=base_v1`), ao reindexar a versão 2 a busca com `k` baixo (2) **não encontrou** imediatamente o documento alterado — porque, com uma base maior (vários documentos agora na mesma coleção), a distância semântica relativa mudou e o documento certo deixou de estar entre os 2 mais próximos. Só com `k=6` o resultado correto apareceu. O próprio instrutor expõe esse "erro" ao vivo (em vez de escondê-lo) como demonstração honesta de que `k` baixo pode, legitimamente, não capturar o resultado esperado quando a base cresce — não é um bug da reindexação, é o comportamento normal de busca por similaridade com `k` insuficiente.

```bash
# .env: COLECAO=base_v2
uv run reindexar dados/v2
uv run buscar "Qual é o nome do usuário responsável?" --k 6

# .env: COLECAO=base_v1
uv run buscar "Qual é o nome do usuário responsável?" --k 6
```

Trocando a `COLECAO` no `.env` para `base_v2` e reindexando a versão 2 ali: a nova coleção nasce **ao lado** da `base_v1`, que permanece intacta (confirmado no pgweb: duas coleções, 16 chunks cada). A busca segue a collection apontada pelo `.env` — trocar de volta para `base_v1` é, literalmente, o **rollback**.

### Regra de ouro: modelo de embedding e collection precisam estar sincronizados

Reforço explícito: ao trocar a collection ativa, é preciso garantir que o **modelo de embedding** usado na busca seja o mesmo usado naquela coleção — indexar com um modelo e buscar com outro simplesmente não funciona (os vetores não são comparáveis entre modelos diferentes).

### Embeddings locais com Ollama — por que, nesta aula

Diferente da aula anterior (OpenAI Embeddings via API), esta aula roda o embedding **localmente** via **Ollama**:

```bash
ollama pull qwen3-embedding:0.6b
```

```bash
OLLAMA_URL=http://localhost:11434
DATABASE_URL=postgresql://aula:aula@localhost:55436/vetores
COLECAO=base_v1
```

Motivação: modelos de embedding, por serem mais leves computacionalmente que modelos de inferência, podem rodar em hardware local razoável, evitando custo por chamada de API — vantajoso especialmente quando se vai reindexar com frequência (como neste próprio exemplo didático). Para quem não tem recursos de máquina para rodar Ollama, o instrutor orienta adaptar o código para usar OpenAI (ou outro provedor) como na aula anterior. Outros modelos de embedding do catálogo Ollama (ex.: `embeddinggemma`, do Google) também podem ser testados livremente.

### Tabela de decisão: incremental vs. reindexação no lugar vs. collection nova vs. outro banco

| Cenário | Estratégia recomendada |
|---|---|
| Editou um runbook existente | Indexação incremental |
| Documento novo | Indexação incremental |
| Documento removido | Indexação incremental |
| Índice não confiável (falha anterior na indexação) | Reindexar no lugar, mesma coleção |
| Mudou só a estratégia de chunk | Reindexar no lugar OU collection nova (decisão aberta, recomendação do instrutor é collection nova) |
| Modelo novo, mesma dimensão de vetor | Collection nova (recomendado pelo instrutor) |
| Modelo novo com dimensão diferente | Banco de dados diferente (a coluna vetorial precisa ser recriada com a nova dimensão) |

Recomendação final para trocar de modelo: sempre consultar a documentação do novo modelo de embedding para confirmar a dimensão suportada antes de decidir onde ele vai viver.

## Comandos e configurações

```bash
# .env
OLLAMA_URL=http://localhost:11434
DATABASE_URL=postgresql://aula:aula@localhost:55436/vetores
COLECAO=base_v1
```

```bash
ollama pull qwen3-embedding:0.6b

cd 16-reindexacao-incremental
docker compose up -d

uv run indexar dados/v1/RB-274-catalog-api.md
uv run buscar "Qual é o nome do usuário responsável?" --k 2

uv run indexar dados/v2/RB-274-catalog-api.md
uv run buscar "Qual é o nome do usuário responsável?" --k 2

uv run reindexar dados/v1
uv run reindexar dados/v2
# .env: COLECAO=base_v2
uv run reindexar dados/v2
```

(Ver trechos de código completos de `indexar.py` e `reindexar.py` nas seções anteriores desta nota.)

## Pegadinhas

- Atualizar um documento na fonte (repositório/wiki) **não** atualiza o banco vetorial automaticamente — é sempre necessário acionar explicitamente o processo de indexação/reindexação.
- Mudar apenas a estratégia de chunk (sem mudar o conteúdo dos arquivos) **não** altera o hash do arquivo — a indexação incremental, por depender só do hash, não detecta essa mudança; é preciso forçar a reindexação (total) nesse caso.
- Com `k` baixo numa base vetorial que cresce (mais documentos na mesma coleção), uma busca que antes encontrava o resultado esperado pode deixar de encontrá-lo — não é um defeito do pipeline de indexação, é o comportamento esperado de busca por similaridade quando a distância relativa muda com o aumento da base.
- Trocar a collection ativa sem garantir que o modelo de embedding seja o mesmo usado para indexá-la resulta em busca inconsistente — vetores gerados por modelos diferentes não são comparáveis entre si.
- Apagar e recriar uma coleção no mesmo lugar deixa o sistema temporariamente indisponível durante o processo — ao contrário de criar uma collection nova ao lado, que não interrompe o funcionamento da coleção atual enquanto a nova é construída.
- A ordem de operações em `reindexar.py` (gerar embeddings antes de apagar a coleção) é deliberada: protege contra perda total de dados em caso de falha do modelo de embedding no meio do processo.

## Dúvidas para revisar

- Como automatizar o disparo da indexação incremental a partir de um evento real (ex.: webhook de commit num repositório de documentação), em vez de rodar manualmente via CLI?
- Em um cenário de produção com centenas de documentos, como paralelizar ou agendar a reindexação total sem impactar a disponibilidade da busca em produção?
- Como decidir, na prática, entre manter várias collections "ao lado" indefinidamente (para rollback) versus eventualmente limpar collections antigas que não serão mais usadas — existe uma política recomendada de retenção?
