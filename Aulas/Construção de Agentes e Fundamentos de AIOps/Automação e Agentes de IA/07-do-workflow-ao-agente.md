# Do Workflow ao Agente

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Automação e Agentes de IA |
| **Aula** | 07 — Do Workflow ao Agente (04:55) — última aula do capítulo |
| **Assunto** | Encerramento do capítulo: trajetória explícita (workflow) vs. trajetória definida em tempo de execução (agente), e um mapa de decisão entre as duas abordagens |
| **Data** | 30/10/2026 00:35 |
| **Tags** | workflow-vs-agente, trajetoria, loop-de-execucao, roadmap-de-decisao, custo-vs-flexibilidade |

## Resumo da aula

Aula de encerramento do capítulo "Automação e Agentes de IA", consolidando a diferença central trabalhada ao longo de todas as aulas anteriores (Chaining, Outputs e Contratos, Routing, Paralelização): em todos esses padrões, a **trajetória de execução é explícita** — definida pelo desenvolvedor antes de rodar. Um agente autônomo, em contraste, **define sua trajetória durante a execução**, com base no objetivo e no estado observado a cada passo — exatamente como o Claude Code/Codex se comportam ao receber uma tarefa. O capítulo termina com um mapa de decisão entre usar workflow ou agente.

## Conceitos principais

### Trajetória explícita (workflow) vs. trajetória em tempo de execução (agente)

- **Workflow** (tudo visto neste capítulo): o desenvolvedor sabe, antes de executar, **todo o caminho possível** — mesmo com rotas (routing) ou paralelismo, as alternativas e sua lógica de seleção são pré-definidas no código. "Você tem um processo de decisão dentro de cada etapa... a trajetória é explícita."
- **Agente**: a trajetória é **decidida durante a execução**. O agente tem um objetivo, observa um estado atual, escolhe a ação/ferramenta a executar, observa o resultado, e repete — sem que o desenvolvedor saiba de antemão qual será exatamente o caminho. É o mesmo comportamento já observado com Claude Code/Codex ao longo do curso: "você não sabe o que vai ser executado, qual vai ser a ordem... Você sabe o resultado que você espera."

### O loop de execução do agente autônomo

Antecipação do próximo capítulo: objetivo → estado observado → decisão da ação → agir → observar o resultado → repetir o ciclo. É o mesmo padrão ReAct já estudado em Engenharia de Prompt e nos capítulos de Harness, agora implementado **sem** uma ferramenta de codificação assistida por trás — construído do zero com LangChain/LangGraph/DeepAgents.

### Mapa de decisão: workflow ou agente?

Critério central: **o quanto o caminho pode ser antecipado**.
- Se o fluxo pode ser antecipado e determinado com antecedência → **workflow** (sequencial, com routing para decisões simples, com paralelização quando aplicável).
- Se a trajetória não tem um caminho bem definido, ou os imprevistos são numerosos e variados → considerar um **agente**.

### Trade-off central: controle/custo vs. flexibilidade

- Mais **determinismo** (workflow) → mais controle sobre o fluxo, **menor custo**, porém **menor flexibilidade** diante de imprevistos.
- Mais **autonomia** (agente) → mais flexibilidade para lidar com cenários não previstos, porém **menos controle** e **maior custo** (mais chamadas ao modelo, mais incerteza).

Esse trade-off já havia sido sinalizado na aula "Chaining" (usar agente quando um workflow resolveria é desperdício de custo e complexidade) — aqui ele é formalizado como critério central de decisão para todo o módulo.

## Comandos e configurações

Não há comandos nesta aula — é o encerramento conceitual do capítulo, preparando a transição para "Primeiros Agentes".

## Pegadinhas

- Confundir "ter rotas e paralelismo" com "ter autonomia" é um erro comum — mesmo um workflow com múltiplos caminhos possíveis continua tendo uma trajetória **explícita e antecipável**; o que define um agente é a trajetória sendo decidida durante a execução, não a quantidade de alternativas possíveis.
- Escolher agente por "parecer mais robusto" sem considerar o trade-off de custo e previsibilidade é uma decisão de engenharia ruim — o critério deve ser a real necessidade de flexibilidade diante do imprevisto.

## Dúvidas para revisar

- Quais seriam exemplos concretos de AIOps onde o fluxo é tão imprevisível que só um agente resolveria, versus casos (como os vistos neste capítulo) em que workflow já é suficiente?
- Como o capítulo "Primeiros Agentes" vai mostrar a implementação do loop de execução (objetivo → estado → ação → observação) na prática com LangChain/LangGraph?
- Vale combinar as duas abordagens no mesmo sistema — um agente autônomo que, internamente, delega sub-tarefas bem definidas para workflows deterministas (como os construídos neste capítulo)?
