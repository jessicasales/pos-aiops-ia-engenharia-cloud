# Memória e RAG

Capítulo do módulo **Construção de Agentes e Fundamentos de AIOps** — Pós AIOps e IA na Engenharia de Cloud.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 05:43 | Por que ferramentas não bastam: a lacuna de continuidade (memória) e de conhecimento interno (RAG) |
| 02 | [Estado de Sessão](02-estado-de-sessao.md) | 09:35 | Sessão/thread, memória de curto prazo vs. longo prazo vs. base de conhecimento |
| 03 | [Checkpointer](03-checkpointer.md) | 29:53 | `thread_id`, `checkpointer` (`InMemorySaver`/`PostgresSaver`), troca de backend |
| 04 | [Memória de Longo Prazo](04-memoria-de-longo-prazo.md) | 51:00 | `Store`: namespace/chave/valor, tools de memória, isolamento por usuário |
| 05 | [Arquiteturas RAG](05-arquiteturas-rag.md) | 32:07 | O que é RAG, embedding, banco vetorial, tipos de busca, Two-Step vs. agente vs. delegação |
| 06 | [Embedding e Banco de Dados Vetorial](06-embedding-e-banco-de-dados-vetorial.md) | 47:56 | OpenAI Embeddings + pgvector: indexar, buscar, granularidade (documento vs. página) |
| 07 | [Estratégias de Chunking e Tamanho do Chunk](07-estrategias-de-chunking-e-tamanho-do-chunk.md) | 50:37 | Chunking, overlap, `MarkdownHeaderTextSplitter` vs. `RecursiveCharacterTextSplitter` |
| 08 | [Reindexação e Indexação Incremental](08-reindexacao-e-indexacao-incremental.md) | 45:29 | Hash SHA-256, delete+add, reindexação no lugar vs. collection nova ("blue-green") |
| 09 | [Retriever Como Etapa Fixa](09-retriever-como-etapa-fixa.md) | 25:11 | Two-Step RAG: busca sempre antes do LLM, agente de onboarding completo |
| 10 | [Retriever Como Ferramenta e Filtro por Metadados](10-retriever-como-ferramenta-e-filtro-por-metadados.md) | 16:13 | RAG agêntico: `buscar_documentos` como tool, `Literal`, busca híbrida |
