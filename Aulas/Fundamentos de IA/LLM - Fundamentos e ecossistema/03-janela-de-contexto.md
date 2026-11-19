# Janela de Contexto

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | LLM - Fundamentos e ecossistema |
| **Aula** | 03 — Janela de Contexto (15:41) |
| **Assunto** | Máximo de tokens processáveis por vez; impacto na qualidade e custo; gerenciamento |
| **Data** | 04/11/2026 00:35 |
| **Tags** | janela-de-contexto, tokens, degradacao, sumarizacao, chunking, rag, sliding-window |

## Resumo da aula

A **janela de contexto** é o número máximo de tokens processáveis de uma vez — a "visão periférica" do modelo. Tudo fora dela é ignorado. É a memória **da sessão**: cada turno (input → output) é empilhado e reenviado ao modelo.

> Observação: este conteúdo é a versão *Fundamentos* do tema; o módulo Engenharia de Prompt e Contexto aprofunda janela de contexto, lost-in-the-middle e os context fails.

## Conceitos principais

### Limite por modelo

Cada modelo tem seu teto de tokens. Conforme a janela cresce, a **qualidade cai** (redundância, ruído, dados conflitantes) e o **custo sobe** (todo o contexto é reenviado).

### Boas práticas

- Use até ~**60%** da janela (acima disso, degrada).
- Coloque os dados mais importantes **próximos do fim** do prompt.

### Gerenciamento

| Técnica | O que faz |
|---|---|
| **Sumarização** | Resume o histórico antigo (perde detalhes) |
| **Chunking** | Divide a tarefa em múltiplas requisições menores |
| **RAG** | Recupera só os dados relevantes sob demanda |
| **Prompt compression** | Comprime o prompt sem perder informação |
| **Sliding window** | Move a janela ativa sobre a informação completa |

Ex.: num agente AIOps, não envie todos os logs do dia — mande o log de erro/gatilho e deixe o agente buscar o resto (RAG/MCP).

## Comandos e configurações

Demo: app chatbot (Streamlit) que mostra a janela de contexto crescendo por interação, com limite de tokens configurável. Projeto no repositório do curso.

## Pegadinhas

- Mudar de tarefa na mesma janela acumula dados conflitantes/redundantes → piora e encarece.
- Janela cheia degrada a assertividade, especialmente em agentes de codificação.

## Dúvidas para revisar

- Qual meu teto prático de ocupação antes de limpar/compactar?
- Onde uso RAG/MCP para evitar lotar a janela?
