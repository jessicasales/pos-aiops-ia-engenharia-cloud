# RAG (Retrieval-Augmented Generation)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 07 — Rag (17:43) |
| **Assunto** | Recuperar informação externa e injetar no agente; busca lexical, por metadados e semântica (embeddings) |
| **Data** | 04/11/2026 00:12 |
| **Tags** | rag, retrieval, embeddings, busca-semantica, busca-lexical, metadados, banco-vetorial, retriever |

## Resumo da aula

**RAG** = *Retrieval-Augmented Generation* (geração aumentada por recuperação). É **obter informação e injetar no fluxo/agente**. Toda vez que o agente busca um dado externo e usa na resposta, é RAG — inclusive um `kubectl get events` ou consultar documentos de post-mortem. Desmistifica: RAG **não exige** banco vetorial; isso é só uma das formas.

## Conceitos principais

### Três formas de buscar

| Forma | O que faz | Complexidade |
|---|---|---|
| **Lexical** | Busca o texto na íntegra (regex, string, query) | Baixa |
| **Por metadados** | Filtra por categorias/tipos (ex.: incidente + Kubernetes) | Média |
| **Semântica** | Busca por **similaridade de significado** (ex.: "out of memory" acha "falta de memória", "app reiniciando por memória") | Alta (exige embeddings) |

Pode ser **híbrida** (combina as três).

### RAG ≠ ação

Recuperar estado (`get pods`) é RAG. Executar ação (`delete pod`) **não** é RAG.

### Ciclo de embedding (busca semântica)

1. Documentos textuais (wiki, tickets, runbooks) → quebrados em pedaços.
2. **Modelo de embedding** transforma os pedaços em **vetores** → armazenados em **banco vetorial**.
3. Na busca, a query passa pelo **mesmo** modelo de embedding → busca por similaridade (distância) no banco vetorial → injeta o resultado.

> A forma de injetar influencia a janela (cuidado com o miolo cego).

## Comandos e configurações

Aula demonstrativa (app Streamlit + LangChain + SQLite vetorial). Implementação prática fica para os módulos de agentes.

## Pegadinhas

- Busca semântica exige preparar os dados (embedding) antes — não é só consultar texto.
- Limite o número de documentos recuperados (ex.: top 3) para não inflar o contexto.

## Dúvidas para revisar

- Quais buscas do meu time são lexicais/metadados (simples) e quais exigem semântica?
- Que base de conhecimento (runbooks, post-mortems) vale embedar para RAG semântico?
