# Estado de Sessão

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 02 — Estado de Sessão (09:35) |
| **Assunto** | Sessão/thread e memória de curto prazo vs. memória de longo prazo vs. base de conhecimento (RAG) — onde cada tipo de informação deve viver |
| **Data** | 30/10/2026 01:15 |
| **Tags** | sessao, thread, memoria-de-curto-prazo, memoria-de-longo-prazo, janela-de-contexto, base-de-conhecimento |

## Resumo da aula

Aula conceitual que estabelece a taxonomia central do capítulo: **sessão/thread** (a conversa de trabalho que precisa de continuidade), **memória de curto prazo** (o histórico dentro de uma sessão), **memória de longo prazo** (informação útil entre sessões diferentes, como preferências do usuário) e **base de conhecimento** (documentos institucionais, que não cabem em nenhuma das memórias e pertencem ao RAG). A analogia central usada é o comportamento do Claude Code: uma tarefa aberta mantém contexto entre perguntas; um `/clear` zera essa continuidade, mas as instruções do projeto (análogas a preferências/conhecimento persistente) continuam disponíveis.

## Conceitos principais

### Sessão / thread — a conversa que precisa de continuidade

Uma **sessão** (também chamada de **thread**) é a conversa de trabalho que precisa manter continuidade — análoga a uma tarefa aberta no Claude Code: você faz uma pergunta, o agente consulta arquivos e executa ferramentas, você faz uma pergunta de acompanhamento, e espera que a resposta leve em conta o que acabou de acontecer. Ao usar `/clear` (ou equivalente), inicia-se uma nova conversa — o histórico da anterior não passa automaticamente para a nova, embora arquivos e instruções do projeto continuem ali.

### Memória de curto prazo = continuidade dentro de uma sessão

A **memória de curto prazo** é justamente essa continuidade dentro do escopo de uma sessão/thread — "curto prazo" se refere ao **escopo** da informação (pertence àquela conversa), não necessariamente à sua duração temporal. Uma sessão pode, inclusive, ser **salva e restaurada mais tarde** (como `claude --resume`) e ainda assim continuar sendo memória de curto prazo, porque seu escopo continua sendo aquela sessão específica, não "todas as sessões".

### A distinção crucial: memória guardada ≠ janela de contexto enviada ao modelo

Ponto técnico central da aula: guardar o histórico completo de uma sessão **não significa** que o modelo vê esse histórico inteiro em cada chamada. A janela de contexto (já vista em aulas de engenharia de contexto) limita quanto o modelo processa por chamada — instruções, mensagens da conversa e qualquer informação recuperada precisam caber nesse espaço. Uma conversa longa pode ter muito mais histórico armazenado do que cabe na janela de contexto; a aplicação precisa **decidir o que entra** para responder a pergunta atual.

Exemplo de falha ilustrado: se a aplicação guarda a conversa inteira mas envia ao modelo apenas a última pergunta ("como eu valido se funcionou?"), sem o contexto de ambiente/SO informado anteriormente, o agente não consegue orientar com segurança — o dado está salvo, mas **ficou fora da chamada**. Na prática comum, a sessão persistida costuma coincidir em boa parte com o que entra na janela de contexto, mas a distinção conceitual entre "o que está guardado" e "o que realmente foi processado nesta interação" é importante de manter clara.

### Memória de longo prazo = informação útil entre sessões diferentes

Ao abrir uma nova conversa no dia seguinte, não faz sentido, em geral, levar todas as mensagens da conversa anterior — mas certas informações (ex.: "prefiro respostas curtas, com comandos separados para copiar") são preferências de comportamento do usuário que fazem sentido reaproveitar em **qualquer** interação futura, não só naquela tarefa específica. Isso é a **memória de longo prazo**: preserva informações usadas em diversas sessões diferentes — preferências de usuário, ou qualquer coisa relevante a tarefas/projetos recorrentes.

Critério de seleção explicitado: **não é simplesmente "apareceu na conversa"** — a aplicação precisa selecionar deliberadamente o que vale a pena registrar, e também permitir que essa informação seja **corrigida e removida** quando necessário (o modelo em si não "aprende para sempre" — a informação fica na aplicação e é injetada no contexto quando relevante para uma nova tarefa; o modelo não tem seus pesos alterados por isso).

### Por que a memória de longo prazo não substitui tudo

A vantagem central de ter memória de curto e longo prazo separadas é poder aproveitar o que é útil entre conversas sem precisar arrastar o histórico completo (ou dados de sessões inteiras) entre interações.

### Base de conhecimento institucional — nem memória nem skill

Caso usado para diferenciar: um documento de procedimentos da plataforma (setup de ambiente, setup de projeto, etc.) — faz sentido esse tipo de documento viver na memória do usuário, ou numa skill? **Não.** Justificativa: uma equipe inteira atualiza esse documento constantemente; se estivesse em memória ou skill, seria necessário atualizar manualmente esses artefatos a cada mudança do documento original. Esse tipo de **base de conhecimento** institucional é o domínio do **RAG**, tema das próximas aulas do capítulo — onde o documento vive em sua fonte original, e o sistema busca o trecho relevante dinamicamente, em vez de replicar o conteúdo em memória.

### Síntese da taxonomia

| Tipo | Escopo | Exemplo | Onde vive |
|---|---|---|---|
| Memória de curto prazo | Uma sessão/thread | Histórico da conversa atual (ambiente/SO já informado) | Estado da sessão (pode ser restaurado, mas escopo continua sendo "aquela conversa") |
| Memória de longo prazo | Entre sessões/interações diferentes | Preferência por respostas curtas, sistemas que o usuário mais usa | Armazenamento próprio da aplicação, injetado no contexto quando relevante |
| Base de conhecimento | Documentos institucionais extensos e vivos | Procedimentos de setup, guias de acesso, padrões de rede | Fonte original + busca via RAG (próximas aulas) |

## Comandos e configurações

Aula puramente conceitual — sem código, comandos ou "Código da Aula" nesta lição.

## Pegadinhas

- Persistir (salvar/restaurar) uma sessão não transforma memória de curto prazo em memória de longo prazo — o critério que define o tipo é o **escopo** da informação (uma conversa específica vs. qualquer conversa futura), não se ela pode ou não ser recuperada depois.
- Guardar o histórico completo de uma sessão não garante que o modelo "vê" tudo isso em cada resposta — a aplicação precisa gerenciar ativamente o que entra na janela de contexto a cada chamada; informação salva mas fora da janela de contexto da chamada atual é como se não existisse para aquela resposta.
- Nem toda informação que aparece numa conversa merece ir para memória de longo prazo — a aplicação precisa de um critério de seleção deliberado, e também precisa suportar correção/remoção dessa informação.
- Documentação institucional extensa e em constante atualização não deve ser replicada em memória nem em skills — isso geraria um problema permanente de sincronização; o padrão correto para esse caso é RAG.

## Dúvidas para revisar

- Como a aplicação decide, na prática, o que da memória de curto prazo (histórico da sessão) entra na janela de contexto de uma chamada específica, quando o histórico é maior do que o espaço disponível?
- Que critérios objetivos ajudam a decidir se uma informação dita pelo usuário merece ser promovida de "só esta conversa" para memória de longo prazo?
- Como a implementação prática de memória de curto e longo prazo em LangChain/LangGraph (tema das próximas aulas, incluindo Checkpointer) materializa essa distinção conceitual no código?
