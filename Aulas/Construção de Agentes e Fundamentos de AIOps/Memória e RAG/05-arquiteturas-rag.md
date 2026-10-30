# Arquiteturas RAG

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 05 — Arquiteturas RAG (32:07) |
| **Assunto** | O que é RAG, por que injeção direta de documento não escala, embedding/banco vetorial, tipos de busca (semântica, lexical, metadados, híbrida) e as três arquiteturas (Two-Step, agente com tool, agente por delegação) |
| **Data** | 30/10/2026 01:15 |
| **Tags** | rag, embedding, banco-de-dados-vetorial, busca-semantica, busca-lexical, busca-hibrida, two-step-rag, agentic-rag, lost-in-the-middle |

## Resumo da aula

Aula conceitual densa (a maior parte teórica do capítulo, sem código), que consolida o entendimento de **RAG (Retrieval-Augmented Generation)** — por que a abordagem "ingênua" de injetar um documento inteiro no prompt (já vista em aulas anteriores do curso) não escala para um cenário real com muitos documentos; o papel do **embedding** e do **banco de dados vetorial**; os diferentes tipos de busca (semântica, lexical, por metadados, híbrida); e as três arquiteturas de implementação de RAG (Two-Step RAG, agente com ferramenta de busca, agente por delegação). Fecha com uma tabela de critérios para escolher a arquitetura adequada.

## Conceitos principais

### RAG = Retrieval-Augmented Generation (geração aumentada por recuperação)

O objetivo do RAG é enriquecer a janela de contexto do agente, buscando informações relevantes a partir de critérios de busca — fornecendo dados ao modelo "de diversas formas diferentes", não apenas uma injeção estática.

### Revisitando o exemplo anterior do curso: por que a injeção direta de documento é limitada

Retomando o agente que carregava um documento de pós-mortem inteiro no prompt (capítulo "Primeiros Agentes"): funcionava porque o documento certo já era conhecido de antemão. Em um cenário real, com **incidentes e pós-mortems acontecendo continuamente**, não é viável colocar todos esses documentos na janela de contexto — por três razões:
1. **Tamanho limitado** da janela de contexto.
2. **"Lost in the Middle"**: o modelo processa de forma menos confiável o que está no meio de um contexto muito extenso.
3. **Risco de alucinação**: informação em excesso, irrelevante ou até contraditória dificulta (em vez de ajudar) a recuperação da resposta correta.

A ferramenta de carregamento dinâmico de documento (vista anteriormente, com `TextLoader`) também tinha uma limitação: carregava um documento **específico e pré-identificado**, sem nenhuma "inteligência" de busca semântica para verificar se aquele era de fato o documento relevante para a pergunta.

### O papel do RAG nos três pilares da engenharia de contexto

RAG ajuda a entregar informação **na hora certa**, **com o volume certo** e **no momento certo** — carregando documentos apenas quando o agente realmente precisa deles, em vez de sempre ou nunca.

### Embedding — transformando texto em vetor

Para fazer busca semântica (em vez de apenas por palavra-chave), os dados precisam passar por um processo de **embedding**: transformação de texto em **vetores numéricos**, de forma conceitualmente similar (não idêntica) ao que ocorre na arquitetura Transformer ao processar tokens. Esses vetores são então armazenados em um **banco de dados vetorial**.

### Busca por similaridade no banco vetorial

Ao buscar, a pergunta do usuário também é transformada em vetor (pelo mesmo modelo de embedding), e o banco vetorial retorna os trechos cujos vetores estão **mais próximos** (por distância vetorial) do vetor da pergunta. Exemplo ilustrativo: a pergunta "o banco perdeu conexão" busca algo relacionado a bancos de dados/conexão (ex.: PostgreSQL, runbooks de conexão) — e **não** retorna, por exemplo, conteúdo sobre "agência bancária", porque essa correlação está semanticamente distante da expressão usada.

### Indexação — o processo completo antes da busca

Para viabilizar a busca por similaridade, é necessário um processo anterior de **indexação**: pegar o documento, quebrá-lo em pedaços (**chunks**), transformar cada pedaço em dado vetorial via modelo de embedding, e persistir no banco de dados vetorial. A indexação também envolve **classificar** os documentos com atributos (metadados), não apenas fragmentá-los.

### Modelo de embedding ≠ modelo de inferência

Ponto técnico importante: o modelo usado para gerar embeddings **não é o mesmo** modelo de inferência usado para gerar respostas (GPT, Gemini, Sonnet, etc.) — são categorias diferentes de modelo. Vantagem prática: modelos de embedding costumam exigir **menos recurso computacional**, podendo ser executados localmente (até na própria máquina, dependendo do hardware), enquanto os modelos de inferência tipicamente são consumidos como serviço na nuvem — permitindo uma arquitetura mista que economiza custo.

### Tipos de busca: semântica, lexical, por metadados e híbrida

- **Busca por similaridade (semântica)**: usa embedding; captura proximidade de significado, mesmo com palavras diferentes (ex.: "banco perdeu conexão" ≈ "recusando conexão" ≈ "banco de dados ficou sem comunicação").
- **Busca lexical**: busca por termos literais/equivalentes — ex.: buscar "checkout" só retorna trechos que contêm exatamente essa palavra ("rollback do checkout", "deploy do checkout"); não captura "banco ficou sem conexões" se o termo não aparecer literalmente. Análoga a um `grep`. Não exige embedding.
- **Busca por metadados**: usa pares chave-valor associados ao documento (nome do serviço, repositório, tipo de aplicação, etc.) — podem vir junto com o embedding ou de forma independente (ex.: front matter de um arquivo Markdown). Não é limitada à busca semântica.
- **Busca híbrida**: combina as abordagens anteriores (metadados + lexical + semântica/vetorial) para enriquecimento de contexto mais robusto e eficiente.

### As três arquiteturas de implementação de RAG

1. **Two-Step RAG**: a aplicação recebe a pergunta, faz a busca na base de conhecimento (usando os modos de recuperação vistos), e envia a resposta recuperada **junto com a pergunta** diretamente ao LLM no prompt — pode ocorrer em mais de uma rodada (buscar, enviar ao LLM, buscar de novo se insuficiente), mas sempre orquestrado pela própria aplicação, injetando a base de conhecimento no prompt.
2. **Agente com tool (RAG agêntico "direto")**: em vez de a aplicação buscar e injetar no prompt, o **agente** recebe uma **ferramenta** (tool) que ele mesmo decide chamar para fazer a busca na base vetorial/outras formas de busca — análogo a dar ao agente "um Google corporativo" próprio.
3. **Agente por delegação**: a forma mais complexa — o agente principal delega a busca a um **segundo agente** especializado, que executa todo o processo de consulta/busca/retorno e entrega as informações de volta ao agente principal, que então gera a resposta final. Analogia usada: um **bibliotecário** — em vez de o usuário procurar diretamente nas estantes, ele pede ao bibliotecário, que faz a busca e entrega o material.

É possível também combinar abordagens em uma **busca híbrida de arquitetura**: começar com Two-Step e, se a informação não for suficiente, recorrer a um agente com tool/RAG agêntico.

### Critérios para escolher a arquitetura

| Critério | Two-Step RAG | Agente com tool / agente por delegação |
|---|---|---|
| Controle do fluxo | Maior — mecanismo de busca fixo e controlado pela aplicação | Menor — o agente decide quando e como buscar |
| Flexibilidade | Menor — fluxo fixo, sempre injeta no prompt | Maior — pode buscar a qualquer momento, com múltiplas fontes |
| Previsibilidade do tempo de resposta | Maior | Menor |
| Cenário recomendado | Base única, bem definida | Várias perguntas diferentes, ou várias fontes de dados diferentes |

### Quando usar memória de curto prazo, memória de longo prazo, RAG e ferramentas

A aula também apresenta (em tabela, não transcrita literalmente pelo instrutor) um guia de quando usar cada um dos quatro mecanismos vistos no módulo: memória de curto prazo (continuidade de sessão), memória de longo prazo (preferências/dados entre sessões), RAG (base de conhecimento institucional extensa e dinâmica) e ferramentas (ações/consultas a sistemas externos) — reforçando que são mecanismos complementares, não concorrentes, cada um resolvendo uma necessidade distinta de contexto.

## Comandos e configurações

Aula puramente conceitual — sem código, comandos ou "Código da Aula" nesta lição. A implementação prática começa na próxima aula.

## Pegadinhas

- Injetar documentos inteiros no prompt, mesmo que dinamicamente (como o `TextLoader` de aulas anteriores), não é RAG — falta exatamente o componente de busca por relevância/similaridade que caracteriza o RAG; é apenas carregamento de documento, sem inteligência de seleção.
- Armazenar documentos em um file system comum (PDF, Markdown) e buscar apenas por palavra-chave é uma forma de busca lexical, não semântica — funciona, mas é menos eficiente para capturar variações de linguagem que remetem ao mesmo significado.
- O modelo de embedding é uma peça técnica **separada** do modelo de inferência usado pelo agente — confundir os dois, ou assumir que o mesmo modelo faz as duas coisas, é um erro conceitual comum.
- Busca semântica por similaridade não é "busca inteligente que entende tudo" — ela depende da proximidade vetorial entre os termos, e pode falhar em capturar relações muito indiretas ou ambíguas (o próprio exemplo do instrutor, "banco de dados" vs. "agência bancária", ilustra os limites dessa proximidade).
- A escolha entre Two-Step RAG e abordagens agênticas (tool própria ou agente delegado) não é puramente estética: tem implicações diretas em previsibilidade de tempo de resposta e controle de fluxo — importante para decisões de arquitetura em produção, não só de implementação.

## Dúvidas para revisar

- Como decidir, na prática, o tamanho ideal de chunk ao fazer a indexação de um documento — tema provavelmente coberto nas próximas aulas sobre chunking?
- Em que cenários valeria a pena combinar busca lexical e semântica no mesmo processo de recuperação (busca híbrida), em vez de escolher apenas uma abordagem?
- Como a escolha entre Two-Step RAG e RAG agêntico (com tool) afeta o custo em tokens de uma aplicação — o modo agêntico, por permitir múltiplas chamadas de busca, tende a consumir mais tokens de reasoning?
