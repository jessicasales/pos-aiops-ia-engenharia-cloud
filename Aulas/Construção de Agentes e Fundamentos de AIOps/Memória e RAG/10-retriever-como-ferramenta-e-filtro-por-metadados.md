# Retriever Como Ferramenta e Filtro por Metadados (Agentic RAG)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 10 — Retriever como Ferramenta e Filtro por Metadados (Agentic RAG) (16:13) |
| **Assunto** | Transformar o retriever numa tool (`buscar_documentos`) com `Literal` para projeto/tipo, busca híbrida (metadados + similaridade), e comparação direta com o Two-Step RAG da aula anterior |
| **Data** | 30/10/2026 01:15 |
| **Tags** | agentic-rag, retriever-tool, literal, busca-hibrida, similarity-search-filter, parse-docstring |

## Resumo da aula

Última aula do capítulo e do módulo: evolui o agente de onboarding (aula 09) de **Two-Step RAG** para **RAG agêntico** — em vez de a aplicação sempre buscar e injetar o resultado no prompt, o **agente** recebe uma **tool própria de busca** (`buscar_documentos`) e decide, sozinho, quando buscar, com qual consulta e com quais filtros de metadados. A ingestão permanece idêntica à aula anterior; a mudança está inteiramente na camada de consumo. Fecha o módulo "Construção de Agentes e Fundamentos de AIOps" com uma comparação direta e prática entre as duas arquiteturas de RAG vistas.

## Conceitos principais

### A mudança de paradigma: de injeção fixa para decisão do agente

Na aula anterior (Two-Step RAG), a aplicação sempre fazia a busca, com a pergunta exata do usuário, antes de qualquer chamada ao LLM. Nesta aula, o **agente** recebe a ferramenta `buscar_documentos` e decide ele mesmo: se vai buscar, com que texto de consulta (pode reformular a pergunta original), e com quais filtros de metadados (projeto, tipo de documento) aplicar — um salto de autonomia do agente sobre o processo de recuperação.

### `.env` — mesmas variáveis, banco isolado

```bash
ANTHROPIC_API_KEY=sua-chave-aqui
MODELO=claude-haiku-5-5
OLLAMA_URL=http://localhost:11434
DATABASE_URL=postgresql://aula:aula@localhost:55438/onboarding
COLECAO=onboarding
K=4
```

Mesma configuração da aula 09, exceto a porta do banco — permitindo que os dois exemplos (17 e 18) coexistam e sejam comparados lado a lado.

### A tool `buscar_documentos` — o retriever como ferramenta

```python
# Os valores possíveis entram no esquema da ferramenta: o modelo não consegue inventar um projeto.
Projeto = Literal["kube-news", "encontros-tech"]
Tipo = Literal["runbook", "guia", "referencia", "post-mortem"]

@tool(parse_docstring=True)
def buscar_documentos(consulta: str, projeto: Projeto | None = None, tipo: Tipo | None = None) -> str:
    """Busca trechos na documentação do time: guias, referências, runbooks e post-mortems.

    Args:
        consulta: O que procurar, em linguagem natural.
        projeto: Restringe a busca a um projeto. Deixe vazio quando a pergunta não é de um projeto só.
        tipo: Restringe a busca a um tipo de documento. Use post-mortem para saber se algo já aconteceu.
    """
    # O agente preencheu os parâmetros a partir da conversa: ele mesmo montou o filtro.
    filtro = {}
    if projeto:
        filtro["projeto"] = projeto
    if tipo:
        filtro["tipo"] = tipo

    # O metadado restringe os candidatos; a similaridade ordena dentro deles.
    trechos = banco.similarity_search(consulta, k=K, filter=filtro or None)
    mostrar_busca(consulta, filtro, trechos)
    return formatar(trechos) or "Nenhum trecho encontrado com esse filtro."
```

Pontos centrais de design:
- **`Literal["kube-news", "encontros-tech"]`** e **`Literal["runbook", "guia", "referencia", "post-mortem"]`**: restringem os valores possíveis **no próprio esquema da tool** — o modelo não pode "inventar" um nome de projeto ou tipo que não existe; só pode escolher entre os valores declarados, exatamente como visto com `enum` em Pydantic em aulas anteriores do curso (ex.: filtro de status de Droplets).
- Parâmetros `projeto` e `tipo` são **opcionais** (`| None = None`) — a docstring orienta explicitamente quando deixá-los vazios ("Deixe vazio quando a pergunta não é de um projeto só"), e até sugere um caso de uso específico para `tipo` ("Use post-mortem para saber se algo já aconteceu") — um exemplo de como a descrição de parâmetro pode ensinar heurísticas de uso ao modelo, não só o tipo do dado.
- **Busca híbrida de verdade**: `similarity_search(consulta, k=K, filter=filtro or None)` combina filtro por **metadados** (restringe os candidatos) com **similaridade semântica** (ordena os candidatos restantes) — diferente de implementações anteriores no curso que usavam só `similarity_search_with_score` sem filtro.

### `formatar` e `mostrar_busca` — reaproveitadas da aula anterior

As funções de formatação de resposta (incluindo a origem para citação) e de log de diagnóstico no terminal são praticamente idênticas à aula 09 — a mudança de arquitetura não exigiu reescrever essa parte.

### `responder()` — muito mais simples

```python
def responder(pergunta: str, thread_id: str, checkpointer: BaseCheckpointSaver) -> None:
    """Entrega só a pergunta: buscar, com que consulta e com que filtro, é decisão do agente."""
    agente = create_agent(
        model=f"anthropic:{MODELO}",
        tools=[buscar_documentos],
        system_prompt=SYSTEM_PROMPT,
        checkpointer=checkpointer,
    )
    agente.invoke(
        {"messages": [{"role": "user", "content": pergunta}]},
        {"configurable": {"thread_id": thread_id}},
    )
```

Comparando com a versão da aula 09 (que fazia a busca manualmente, formatava e montava a mensagem com o marcador de trechos): esta versão apenas **entrega a pergunta original**, sem nenhuma busca prévia — toda a complexidade de "quando buscar e o quê" fica encapsulada na tool, chamada pelo próprio agente quando ele julgar necessário.

### Demonstração: pergunta composta gera duas buscas independentes

```text
Qual é a stack do projeto Kube News? E como faço para executar em produção?
```

Com a pergunta composta numa única mensagem, o agente fez **duas chamadas separadas** à tool `buscar_documentos`: uma para a stack tecnológica, outra para o procedimento de execução em produção — cada uma com seu próprio filtro de projeto preenchido corretamente (`kube-news`). O instrutor contrasta isso explicitamente com o comportamento da arquitetura anterior (Two-Step RAG): lá, uma única busca seria feita com a pergunta composta inteira, trazendo um conjunto de trechos menos direcionado — aqui, o agente decompôs a pergunta em duas sub-consultas mais específicas, enriquecendo o resultado final.

### Demonstração: perguntas separadas em mensagens distintas

```text
Qual é a stack do projeto Encontros Tech?
E como faço para executar em produção?
```

Em uma nova sessão, com cada pergunta enviada separadamente: o agente faz **uma busca por mensagem** — comportamento natural, já que cada mensagem é tratada independentemente (mas ainda com o contexto da sessão mantido pelo checkpointer).

### Observação honesta sobre limitação de granularidade

O instrutor nota, ao analisar a resposta, que o tamanho pequeno dos chunks (por título/subtítulo, resultando em blocos bem pequenos) pode ter limitado a quantidade de contexto recuperado em cada busca — propondo como exercício testar com `K` maior, ou até deixar o próprio agente decidir o valor de `K` dinamicamente (não implementado nesta aula, mas sugerido como extensão natural).

## Comparação direta: Two-Step RAG vs. RAG agêntico (nesta aula)

| Aspecto | Two-Step RAG (aula 09) | RAG agêntico — tool (aula 10) |
|---|---|---|
| Quem decide buscar | A aplicação, sempre | O agente, quando julgar necessário |
| Consulta usada na busca | A pergunta do usuário, literal | Pode ser reformulada/decomposta pelo agente |
| Múltiplas perguntas numa mensagem | Uma busca só, com a pergunta inteira | Pode gerar múltiplas buscas, uma por sub-tópico |
| Filtro de metadados | Nenhum (busca sem filtro) | O agente preenche `projeto`/`tipo` dinamicamente |
| Previsibilidade | Maior (fluxo fixo) | Menor (depende da decisão do agente) |
| Complexidade do código de consumo | Maior (monta mensagem, marcador, formatação manual) | Menor (delega tudo à tool) |

Reforçando a conclusão já apresentada na aula 05 (arquiteturas RAG): não há "certo" ou "errado" entre as duas abordagens — a escolha depende do cenário, da previsibilidade necessária e da complexidade das perguntas esperadas.

### Encerramento do módulo

O instrutor fecha o capítulo (e o módulo "Construção de Agentes e Fundamentos de AIOps" como um todo) convidando o aluno a pegar as duas implementações de RAG apresentadas, adaptá-las ao próprio cenário, e construir suas próprias soluções combinando memória de curto prazo, memória de longo prazo e RAG — os três pilares trabalhados ao longo de todo o capítulo "Memória e RAG".

## Comandos e configurações

```bash
cd 18-agente-onboarding-tool
cp .env.example .env   # preencha ANTHROPIC_API_KEY
uv sync --locked
docker compose down -v # limpeza: remove o volume e zera o banco
docker compose up -d   # PostgreSQL com pgvector em 127.0.0.1:55438, pgweb em http://localhost:58438
uv run web              # http://127.0.0.1:8003
```

```text
# Perguntas de teste
Qual é a stack do projeto Kube News? E como faço para executar em produção?

# (sessão nova, uma pergunta por mensagem)
Qual é a stack do projeto Encontros Tech?
E como faço para executar em produção?
```

(Ver trechos de código completos de `buscar_documentos`, `formatar`, `mostrar_busca` e `responder` nas seções anteriores desta nota.)

## Pegadinhas

- `Literal` no tipo do parâmetro é o que impede o modelo de "inventar" um valor de projeto/tipo inexistente — sem essa restrição, o agente poderia enviar um valor de filtro que não corresponde a nenhum metadado real, retornando silenciosamente nenhum resultado.
- Deixar `K` fixo via variável de ambiente, independentemente de quão complexa seja a pergunta, pode limitar a quantidade de contexto recuperado quando os chunks são muito pequenos (como no caso desta aula, por título/subtítulo) — vale considerar deixar o próprio agente decidir esse valor dinamicamente, como sugerido no fechamento da aula.
- O comportamento de "quantas buscas o agente faz" depende de como a pergunta é estruturada pelo usuário (uma mensagem com dois tópicos vs. duas mensagens separadas) — não é um parâmetro configurável diretamente, é uma consequência da forma como o modelo interpreta a tarefa.
- Migrar de Two-Step RAG para RAG agêntico não elimina a necessidade de pensar em filtro por metadados — pelo contrário, agora é o **agente** que precisa ser orientado (via docstring) sobre quando e como usar cada filtro disponível.

## Dúvidas para revisar

- Como implementar a sugestão de deixar o agente decidir dinamicamente o valor de `K` por consulta, em vez de usar um valor fixo global?
- Em quais cenários reais a imprevisibilidade do RAG agêntico (múltiplas buscas, filtros variáveis) seria um problema — por exemplo, em termos de custo de tokens ou latência de resposta?
- Como seria uma versão híbrida que combina Two-Step RAG (uma busca inicial sempre executada, cobrindo o caso comum) com RAG agêntico (uma tool adicional para buscas de acompanhamento, quando a primeira busca não for suficiente)?
