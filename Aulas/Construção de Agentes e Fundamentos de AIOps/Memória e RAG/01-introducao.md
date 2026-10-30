# Introdução

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Memória e RAG |
| **Aula** | 01 — Introdução (05:43) |
| **Assunto** | Por que ferramentas não bastam: a lacuna de continuidade (memória) e de conhecimento interno não estruturado (RAG) |
| **Data** | 30/10/2026 01:15 |
| **Tags** | memoria, rag, janela-de-contexto, continuidade-de-conversa, conhecimento-interno |

## Resumo da aula

Aula de abertura do último capítulo do módulo, puramente conceitual. Depois de dotar os agentes de ferramentas (capítulo anterior — consultas, ações, MCP Servers próprios), o instrutor mostra que ferramentas por si só não resolvem duas necessidades distintas: (1) **continuidade** — lembrar o que já foi dito numa conversa (ou entre sessões), e (2) **conhecimento interno não estruturado** — documentação, guias e procedimentos da empresa que o modelo nunca viu e que não cabem inteiros no prompt. Essas duas lacunas são resolvidas, respectivamente, por **memória** e por **RAG** (Retrieval-Augmented Generation) — os dois temas centrais deste capítulo.

## Conceitos principais

### O problema da "amnésia" do agente

Cenário ilustrativo: um agente de IA interno de onboarding orienta o usuário a configurar acesso ao ambiente de desenvolvimento no macOS; na pergunta seguinte ("como verifico se o acesso está funcionando?"), o usuário espera que o agente saiba que está falando de macOS — mas, se a aplicação não preserva a janela de contexto entre interações, o agente "esquece" completamente o que foi dito, obrigando o usuário a repetir informação já fornecida. As ferramentas continuam disponíveis, os acessos continuam os mesmos — só a continuidade da conversa se perde.

### O problema do conhecimento institucional não disponível ao modelo

Segundo cenário: perguntar "qual o procedimento da empresa para solicitar acesso a um outro ambiente/serviço?" não é algo que o modelo de IA conhece por treinamento — ele tende a **inventar** uma resposta plausível, mas incorreta. A empresa tem guias de acesso, padrões de rede, procedimentos de implantação — potencialmente dezenas ou centenas de documentos — e o modelo só sabe o que está escrito ali se a aplicação efetivamente for buscar essa informação. Colocar todo esse acervo no prompt de uma vez não faz sentido (nem seria viável); é preciso encontrar, dentre os documentos, o trecho específico que ajuda a responder àquela pergunta.

### Memória — continuidade entre interações

A **memória** dá continuidade: a aplicação preserva as informações necessárias e as recupera quando o agente precisa retomar uma conversa ou aproveitar algo de uma sessão/interação anterior — por exemplo, a preferência de um usuário por respostas mais curtas, o sistema operacional de sua máquina de trabalho, ou os sistemas que ele mais utiliza.

### RAG — busca em fontes externas/internas da empresa

O **RAG** (Retrieval-Augmented Generation) permite buscar informações em fontes externas (do ponto de vista do modelo) — como documentos internos da empresa — e entregar ao modelo apenas o **conteúdo relevante** que ajuda a responder à pergunta específica do usuário. A ideia central: recuperar só o trecho pertinente, não o documento inteiro na janela de contexto — diferente da abordagem "ingênua" de injeção de contexto já vista em aulas anteriores (ex.: `TextLoader` carregando um runbook inteiro no prompt, no capítulo "Primeiros Agentes").

### O ponto em comum entre memória e RAG

Em ambos os casos, as informações precisam ser **selecionadas** antes de serem entregues à aplicação/agente — o modelo não "lembra tudo sozinho" automaticamente. O objetivo comum de memória e RAG é **oferecer a informação certa no momento em que o modelo vai utilizá-la** — nem mais, nem menos. No exemplo do chat de onboarding: para responder à pergunta de acompanhamento, o agente precisa receber o contexto da conversa (ambiente/SO informado anteriormente — tarefa da memória) **e** precisa receber o trecho de documentação pertinente ao procedimento perguntado (tarefa do RAG) — são duas necessidades diferentes, que podem até coexistir na mesma interação.

### Por que este capítulo é central

O instrutor classifica memória, RAG e ferramentas como os **três conceitos-chave** de agentes de IA — presentes, em alguma medida, em praticamente todo agente real construído. Reforça a recomendação de exercitar bastante o conteúdo deste capítulo, dado seu peso conceitual.

## Comandos e configurações

Aula puramente conceitual — sem código, comandos ou "Código da Aula" nesta lição.

## Pegadinhas

- Ferramentas (capítulo anterior) resolvem acesso a sistemas/ações, mas não resolvem continuidade de conversa nem acesso a conhecimento institucional não estruturado — são capacidades complementares, não substitutas.
- Um modelo sem acesso a RAG não erra silenciosamente ao ser perguntado sobre um procedimento interno desconhecido — ele tende a **inventar** uma resposta plausível (alucinação), o que é potencialmente mais perigoso do que simplesmente não responder.
- Injetar todo um acervo de documentos no prompt não é uma alternativa viável ao RAG — além do custo e do limite de contexto, isso dilui a relevância da informação específica que o modelo precisa para aquela pergunta.

## Dúvidas para revisar

- Em um mesmo agente, como as capacidades de memória e de RAG vão coexistir na prática — elas competem pelo mesmo "espaço" na janela de contexto, ou são tratadas por camadas distintas da arquitetura?
- Que tipos de memória serão explorados no capítulo (apenas de curto prazo, dentro de uma sessão, ou também de longo prazo, entre sessões diferentes)?
- Como a escolha de granularidade na recuperação de documentos (trecho vs. documento inteiro) afeta a qualidade da resposta final do agente — isso será abordado em profundidade nas próximas aulas sobre chunking?
