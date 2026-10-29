# Fronteira da delegação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 01 — Fronteira da delegação (22:28) |
| **Assunto** | O que é um sub-agente, por que pensar nele como uma fronteira de execução (não "mais um agente"), ganhos (contexto, especialização, segurança, paralelismo) e custos (perda de contexto, briefing, resultado filtrado) |
| **Data** | 29/10/2026 18:30 |
| **Tags** | sub-agentes, fronteira, briefing, janela-de-contexto, paralelismo, lost-in-the-middle, skill-vs-subagente |

## Resumo da aula

Aula de abertura do capítulo "Sub Agentes", definindo o conceito central que vai guiar todo o capítulo: um sub-agente não deve ser visto como "mais um agente", mas como uma **fronteira de execução** — um isolamento com uma janela de contexto própria, onde só duas coisas atravessam a fronteira: o **briefing da tarefa** (na ida) e o **resultado** (na volta). O instrutor usa um exemplo de investigação de incidente em Kubernetes + Prometheus para demonstrar os ganhos (economia de contexto, especialização, controle de permissões, paralelismo) e os custos (o sub-agente não conhece a sessão principal, o briefing precisa ser completo, e você não controla o que ele decide incluir ou deixar de fora no resultado).

## Conceitos principais

### Definição

**Sub-agente**: um agente que recebe uma tarefa de um agente principal e trabalha em uma **janela de contexto separada**. Na prática, como se o agente principal abrisse uma nova conversa com "alguém da equipe", entregasse uma tarefa e esperasse o resultado voltar. Dependendo da ferramenta, o sub-agente pode ter instruções, ferramentas e permissões diferentes do agente principal.

### A fronteira: o que atravessa, na ida e na volta

- **Na ida**: o **briefing** — o que o agente principal (ou você) delega, incluindo o que deve ser feito, os limites, e o que o sub-agente deve devolver.
- **Na volta**: o **resultado** — não tudo que o sub-agente processou, apenas a resposta relevante para a tarefa.

O que acontece "dentro" do sub-agente é uma caixa preta para a sessão principal.

### Exemplo: investigação de incidente Kubernetes + Prometheus

**Sem sub-agente**: o agente principal consulta o Kubernetes (pods, eventos, restarts) e recebe tudo isso na mesma janela de contexto; depois consulta o Prometheus (latência, erro, CPU, memória) — tudo acumulado na mesma conversa, sequencialmente.

**Com sub-agentes**: a análise do Kubernetes vai para um sub-agente "DevOps Kubernetes Expert"; a análise do Prometheus vai para um sub-agente "Observability Prometheus Expert". Como uma investigação não depende da outra, ambas rodam **em paralelo**, cada uma na sua própria janela de contexto. Ao final, cada sub-agente devolve apenas os dados relevantes para o incidente — não os logs e consultas completos — e o agente principal cruza os dois resultados para continuar o diagnóstico.

### Os dois problemas da sessão única

1. **Janela de contexto**: toda consulta (Kubernetes, métricas, logs, arquivos) despeja informação na mesma janela de contexto. Boa parte dessa informação só é útil temporariamente, mas não "vai embora" — continua ocupando espaço e disputando prioridade com a instrução original, agravando o fenômeno **Lost in the Middle** (informação descartável pode acabar com mais peso do que a instrução inicial).
2. **Tempo**: tarefas independentes (ex.: consulta Kubernetes e consulta Prometheus) acabam executadas sequencialmente em uma sessão única, mesmo quando poderiam rodar em paralelo.

### Os quatro ganhos de delegar para sub-agentes

1. **Economia de janela de contexto**: o sub-agente pode abrir dezenas de arquivos, consultar documentação, executar comandos — nada disso passa para o agente principal, apenas o resultado final.
2. **Especialização por função**: sub-agentes dedicados (Kubernetes, observabilidade, segurança, codificação, etc.), cada um com instruções próprias; o agente principal apenas orquestra e chama cada um quando necessário.
3. **Controle de capacidade/permissão**: dependendo da ferramenta, é possível restringir ferramentas, permissões e até o modelo usado por cada sub-agente (ex.: um sub-agente de Kubernetes com acesso **somente leitura**, ou um sub-agente de código que não enxerga o cluster Kubernetes) — fronteiras de segurança.
4. **Paralelismo (tempo)**: tarefas independentes podem ser delegadas a sub-agentes diferentes e executadas simultaneamente.

### Os três custos da delegação

1. **Na ida — o sub-agente não conhece a sessão principal**: ele não participou da conversa, não sabe decisões tomadas, correções, mudanças de direção, regras nascidas de incidentes anteriores, ou o que já foi rejeitado como opção. Ele só sabe o que chega automaticamente (varia por ferramenta — tipicamente `CLAUDE.md`/`AGENTS.md`, ferramentas disponíveis, hooks) e o que está explicitamente no briefing.
2. **Na ida — o briefing precisa ser completo**: deve responder a pelo menos 5 perguntas: (1) qual é a tarefa, (2) qual é o objetivo, (3) onde buscar as informações, (4) o que ele **não pode** fazer, (5) o que ele deve devolver no final. Quanto mais a tarefa depender do histórico da conversa, mais informação precisa ser empacotada no briefing ou indicado onde obtê-la.
3. **Na volta — você não controla o que fica de fora do resultado**: o sub-agente decide o que retornar; alguma informação necessária pode ficar de fora se o briefing não deixar claro o que a resposta deve conter (ex.: para um incidente Kubernetes: análise, causa raiz/parecer, evidências, sugestões).

### Quando faz sentido delegar para sub-agente

1. A tarefa pode ser explicada sem contar toda a história da conversa.
2. A tarefa vai gerar muita informação que não precisa ficar na sessão principal (logs, múltiplos arquivos, testes, métricas, pesquisa na web).
3. Você quer um agente com função e permissões diferentes (ex.: acesso só leitura a um recurso sensível).
4. A tarefa pode ocorrer em paralelo com outra (loop engineering).

### Quando NÃO faz sentido delegar

1. A tarefa depende de muitas decisões já tomadas na janela de contexto (o briefing acabaria sendo "metade da conversa").
2. Cada resultado intermediário muda o próximo passo (decisão passo a passo, muita interação necessária).
3. A tarefa é pequena — o esforço de montar um briefing não compensa, comparado a simplesmente resolver na sessão principal.

### Sub-agente não é skill

- **Skill** responde: "como essa tarefa deve ser feita?" — está relacionada a workflow e guidelines.
- **Sub-agente** responde: "quem vai executar essa tarefa, e isso acontece dentro ou fora da minha janela de contexto principal?"

Elas se complementam, não se substituem: um sub-agente de Kubernetes/DevOps pode usar uma skill de troubleshoot, seguindo os guidelines da equipe. Confundir os dois conceitos leva a dois exageros: criar sub-agentes excessivamente especializados que deveriam ser skills, ou esperar que uma skill trabalhe isolada em contexto separado (isso é papel do sub-agente).

## Comandos e configurações

Não há comandos executados nesta aula — é conteúdo conceitual de abertura do capítulo. As próximas aulas tratam da parte prática (agentes built-in, criação de sub-agents, roteamento, etc.).

## Pegadinhas

- Pensar em sub-agente como "mais um agente" (em vez de uma fronteira de contexto) leva a briefings incompletos e resultados com lacunas inesperadas.
- O sub-agente não herda automaticamente todo o histórico da sessão principal — presumir que ele "sabe o contexto" é um erro comum.
- Delegar tarefas pequenas para sub-agentes é desperdício de esforço — o ganho de isolamento de contexto só compensa quando a tarefa geraria volume relevante de informação.
- Disparar duas tarefas em paralelo quando uma depende do resultado da outra anula o ganho de paralelismo (ainda resta o ganho de economia de contexto, mas não o de tempo).

## Dúvidas para revisar

- Quais tarefas do projeto Encontros Tech já têm volume de informação suficiente para justificar um sub-agente dedicado (ex.: troubleshoot de Kubernetes, análise de logs)?
- Como estruturar na prática o "briefing" ideal (as 5 perguntas) ao delegar para um sub-agente nas próximas aulas?
- Qual é a diferença concreta, em uma ferramenta como o Claude Code, entre um agente built-in e um sub-agent criado por mim (tema da próxima aula)?
