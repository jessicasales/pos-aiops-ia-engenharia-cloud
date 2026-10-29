# Harness Engineering

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Evolução do Trabalho com IA e Harness Engineering |
| **Aula** | 02 — Harness Engineering (18:57) |
| **Assunto** | Definição formal de Harness e Harness Engineering, seus componentes, os dois papéis (Guide/Feed Forward e Sensor/Feedback) e quando criar um novo componente |
| **Data** | 29/10/2026 16:40 |
| **Tags** | harness, harness-engineering, guide, feed-forward, sensor, feedback, agnostico |

## Resumo da aula

Aula central do capítulo, definindo com precisão o que é Harness e Harness Engineering, listando os componentes que formam um harness (system prompt, MCPs, rules, skills, hooks, memória, sandbox), explicando os dois papéis que qualquer componente pode exercer (Guide/Feed Forward ou Sensor/Feedback), e dando critérios práticos para saber quando vale a pena criar um novo componente de harness.

## Conceitos principais

### Definições

- **Harness**: é **tudo que forma o agente e que não é o modelo (LLM)** em si. Independente da ferramenta (Claude Code, Codex, Cursor, etc.), qualquer coisa diferente do modelo faz parte do harness.
- **Harness Engineering**: a disciplina que determina como configurar o harness. É uma preocupação constante, ainda mais relevante quando se trabalha com agentes autônomos (tema de aulas futuras).

### Analogia do mapa e do GPS

- O **Spec Driven Development** é o mapa, com o endereço de onde se quer chegar (início → fim da tarefa).
- O **Harness** é o GPS: mostra a melhor direção, evita trânsito, avisa sobre pedágios — ou seja, orienta e valida o caminho percorrido entre o início e o fim definidos pelo SDD, evitando "voltas e curvas" desnecessárias (como ter que re-explicar critérios de teste repetidamente, visto nas aulas anteriores do capítulo SDD).

### Componentes que formam o Harness

- **System Prompts**: prompts de inicialização do agente (persona, diretrizes, função principal).
- **MCPs** (Model Context Protocol Servers): comunicação do agente com o mundo externo.
- **Rules**: regras — incluindo arquivos como `CLAUDE.md`/`AGENTS.md`.
- **Skills**: direcionamento para execução de workflows ou validação de tarefas.
- **Hooks**: ganchos/triggers que detectam eventos do agente e disparam ações.
- **Memória**: gerenciamento de informações de curto e longo prazo que o agente vai precisar.
- **Sandbox**: ambiente isolado para executar código/tarefas que poderiam comprometer o ambiente real.
- Também compõem o harness as *tools* nativas de cada ferramenta (ex.: busca na web, leitura/escrita em file system do Claude Code).

### Dois níveis de harness

1. **Harness nativo da ferramenta**: componentes que já vêm prontos (ex.: as tools de busca web e file system do Claude Code).
2. **Harness de autoria própria**: componentes que o próprio usuário cria (skills, system prompts, hooks, rules customizadas, etc.).

### Princípio: componentes devem ser agnósticos de ferramenta

Componentes criados pelo usuário (skills, rules, system prompts, hooks) devem ser desenhados para rodar em **qualquer ferramenta** (Claude Code, OpenCode, Codex, Cursor), não amarrados a uma única plataforma. Essa portabilidade é o que diferencia profissionais e soluções de IA — inclusive explica por que ferramentas como Cursor, GitHub Copilot e OpenCode, mesmo usando os mesmos modelos de base, produzem resultados diferentes: a diferença está no harness (system prompt, MCPs, tools, rules, skills, hooks), não no modelo.

### Os dois papéis de um componente de harness

- **Guide (Feed Forward)**: age **antes** da ação do agente, dando direção/orientação (como o GPS indicando o caminho). Aumenta as chances de o agente acertar a tarefa/ação. Exemplos: `CLAUDE.md` (estrutura do projeto, convenções, nomenclatura), skills (podem atuar como guide).
- **Sensor (Feedback)**: age **depois** da ação, fazendo a validação — um checklist de resultado, verificando se a ação cumpriu o esperado. Exemplos: hooks de lint (verificam se o código gerado segue o formato correto), skills de verificação.

Todo componente de harness deve ser classificado como um desses dois papéis (alguns, como skills, podem servir aos dois).

### Quando criar um novo componente de harness

Sinais de que é hora de criar um componente:
- Você executa a mesma tarefa **duas vezes ou mais**.
- A IA comete o **mesmo erro mais de uma vez**.
- Você **repete a mesma instrução** duas vezes ou mais.
- Você fica **reexplicando** a mesma coisa o tempo todo.
- Você precisa **conferir sempre o mesmo resultado** manualmente.

O papel do harness é ajudar o agente (junto com o modelo) a errar menos, acertar com mais frequência e executar tarefas com mais velocidade — sempre que há algo bloqueando o fluxo ou exigindo supervisão constante, é sinal de que falta um componente de harness ali.

## Comandos e configurações

Não há comandos ou prompts executados nesta aula — é conteúdo conceitual. Os componentes citados (system prompt, MCPs, rules, skills, hooks, memória, sandbox) serão detalhados em capítulos específicos do módulo.

## Pegadinhas

- Não confundir harness com o modelo — trocar de modelo (ex. de Sonnet para um mais caro) não resolve problemas que são, na verdade, de ambiente/configuração do agente.
- Componentes próprios (skills, rules, hooks) devem ser escritos de forma agnóstica à ferramenta — presos a uma única plataforma, perdem reaproveitamento e portabilidade.
- Nem todo componente é só Guide ou só Sensor — algumas skills podem exercer ambos os papéis dependendo de como são usadas.

## Dúvidas para revisar

- Quais componentes específicos (rules, skills, hooks, sub agentes) serão detalhados nos próximos capítulos do módulo?
- Como decidir, na prática, se um problema recorrente deve ser resolvido com uma rule, uma skill ou um hook?
- O projeto Encontros Tech já teve algum componente de harness "informal" criado (ex.: as instruções repetidas sobre testes de Docker/Kubernetes) — vale formalizar isso agora como componentes reais?
