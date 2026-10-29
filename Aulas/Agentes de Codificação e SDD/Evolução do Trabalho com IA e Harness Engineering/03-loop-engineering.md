# Loop Engineering

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Evolução do Trabalho com IA e Harness Engineering |
| **Aula** | 03 — Loop Engineering (22:41) |
| **Assunto** | As três camadas de ciclo de execução do agente (ReAct, Inner Loop, Outer Loop), back pressure, avaliadores determinísticos vs. probabilísticos, e o comando `go` do Claude Code |
| **Data** | 29/10/2026 16:55 |
| **Tags** | loop-engineering, react, inner-loop, outer-loop, back-pressure, avaliador-deterministico, avaliador-probabilistico, go |

## Resumo da aula

Aula que fecha o capítulo, detalhando a **engenharia de loop**: a disciplina que define práticas de otimização para o ciclo de execução do agente de IA — indo além do ciclo básico ReAct já estudado em engenharia de prompt. O instrutor apresenta as três camadas de ciclo (ReAct, Inner Loop, Outer Loop), explica o conceito de *back pressure* (pressão de correção aplicada de volta ao agente) e como ele se conecta diretamente aos componentes do harness (principalmente sensores), e mostra como esse controle permite execuções autônomas e de longa duração — citando a filosofia de Boris Cherny (criador do Claude Code), que afirma "não promptar mais", e sim "escrever loops".

## Conceitos principais

### Definição

**Loop Engineering**: disciplina que define as práticas de otimização para o ciclo de execução do agente de IA. Vai além do ciclo ReAct básico (reasoning/análise → ação → observação → repetição), trazendo componentes e práticas para ter maior controle sobre esse ciclo e executar tarefas de longa duração.

### As três camadas de interação

Cada camada reduz a necessidade de interação direta do humano com a IA:

1. **ReAct** — o ciclo básico: análise → ação → observação → repetição, até a tarefa ser concluída.
2. **Inner Loop** — adiciona critérios de avaliação mais robustos à observação do ReAct.
3. **Outer Loop** — orquestra múltiplos Inner Loops para resolver uma tarefa complexa/macro.

### O problema do ReAct "puro": observação fraca

No ReAct básico, a observação que determina se a tarefa foi concluída é o próprio modelo se autoavaliando, sem critérios externos — uma avaliação "fraca". Isso se relaciona com o que foi visto em Prompt Evaluation: modelos da mesma família tendem a aprovar o que outros modelos da mesma família fizeram (ex.: Sonnet aprova o que Opus fez, e vice-versa), enquanto modelos de famílias diferentes (OpenAI vs. Anthropic vs. Google) tendem a ser mais criteriosos entre si.

### Inner Loop e Back Pressure

O Inner Loop é semelhante ao ReAct, mas incorpora componentes do harness (principalmente **sensores**) na etapa de observação, criando mecanismos de avaliação mais criteriosos. Quando um sensor detecta um problema, ele "empurra" o erro de volta para o agente, forçando a correção — esse mecanismo é chamado de **back pressure**. O ciclo então reinicia (análise → ação → observação) até passar pelos critérios.

Dois tipos de sensores/avaliadores usados no Inner Loop:

- **Avaliadores determinísticos**: código estático que avalia o output de forma objetiva. Exemplos: um linter (para TypeScript, Python, Dockerfile, Terraform), SonarQube com gate de qualidade.
- **Avaliadores probabilísticos (de inferência)**: a própria IA avaliando a resposta contra critérios de aceite definidos (mesma lógica do Prompt Evaluation), podendo ser instruída a justificar quando o critério não é atendido.

Combinar os dois tipos de avaliadores no Inner Loop gera respostas mais eficientes, assertivas e coerentes com o que realmente se precisa — reforçando a importância de definir claramente critérios de aceite nos PRDs/TRDs, e também orientar a IA sobre como atingir esses critérios.

### Outer Loop: orquestrando múltiplos Inner Loops

O Inner Loop resolve uma tarefa pontual/simples (ex.: codificar uma feature). Para tarefas complexas, segue-se o mesmo princípio de decomposição usado em gestão de projetos (sprints, Kanban): quebrar a tarefa grande em tarefas simples. O **Outer Loop** é o loop orquestrador — o "loop grandão" que recebe a tarefa macro e a decompõe, disparando vários Inner Loops (um por sub-tarefa), permitindo:
- Execução de tarefas de longo prazo/duradouras.
- Mais autonomia para o agente.
- Paralelismo entre tarefas, ganhando velocidade sem perder assertividade — porque cada Inner Loop mantém seus próprios critérios determinísticos/probabilísticos baseados no harness.

### Exemplo prático: PRD de autenticação

Um PRD de sistema de autenticação com múltiplas funcionalidades (criação de usuário, login, controle de permissão) é passado ao agente. O **Outer Loop** analisa o PRD como um todo e decompõe cada funcionalidade em um **Inner Loop** próprio (um Inner Loop para criação de usuário, outro para login, outro para controle de permissão, etc.).

### O comando `go` do Claude Code

O instrutor cita o comando `go` do Claude Code como exemplo de ferramenta de Outer Loop: ao configurá-lo para uma tarefa, o Claude Code só finaliza e retorna quando a tarefa estiver realmente concluída segundo os critérios definidos — permitindo execução prolongada sem interação direta constante. Mas isso só funciona bem se três pré-requisitos estiverem presentes:
1. Harness bem estruturado para ajudar na execução.
2. Memória bem estruturada com as informações e preferências necessárias.
3. Critérios de aceite muito bem definidos.

### A engenharia de prompt não morreu

Mesmo com Loop Engineering e Harness Engineering, a engenharia de prompt continua relevante — ela é usada para definir os Outer Loops e estruturar o próprio harness/ambiente.

## Comandos e configurações

```
# comando mencionado como mecanismo de Outer Loop no Claude Code
go
```

Não há outros prompts ou comandos específicos executados nesta aula — é conteúdo conceitual, fechando o capítulo "Evolução do Trabalho com IA e Harness Engineering".

## Pegadinhas

- Confiar apenas na autoavaliação do próprio modelo (ReAct puro) é um critério fraco — sem sensores externos (determinísticos ou probabilísticos), a "observação" não garante qualidade real do resultado.
- Modelos da mesma família tendem a se aprovar mutuamente com mais facilidade — isso é um viés a considerar ao desenhar avaliações automatizadas.
- Usar o comando `go` (ou equivalente de outras ferramentas) não é "mágica" — sem harness, memória e critérios de aceite bem definidos, a execução de longa duração não funciona de forma confiável.

## Dúvidas para revisar

- Quais sensores determinísticos (linters, SonarQube, etc.) fazem sentido configurar no projeto Encontros Tech para os próximos capítulos do curso?
- Como estruturar na prática um Outer Loop usando o comando `go` do Claude Code em um PRD como o de autenticação citado no exemplo?
- A relação entre Outer Loop e Sub Agentes (capítulo futuro do módulo) — um Outer Loop sempre delega para sub agentes, ou pode delegar para o mesmo agente em chamadas sequenciais?
