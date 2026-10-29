# Introdução às Skills

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 01 — Introdução (18:37) |
| **Assunto** | O que é uma skill, quando usar e quais são os tipos |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `skill` `harness` `memória procedural` `carregamento sob demanda` `workflow` `guide` `sensor` `MCP` |

## Resumo da aula

A aula abre o capítulo sobre os componentes do **Harness**, começando pelo mais usado: as **skills**. Uma skill é uma *habilidade* que você ensina ao agente — na prática, um workflow, um fluxo de execução com o seu jeito de fazer uma tarefa (criar pipeline CI/CD, Dockerfile, PRD, ADR, troubleshooting de cluster etc.).

A grande vantagem sobre copiar e colar prompts é o **carregamento sob demanda**: o agente só carrega a skill quando a tarefa pede, protegendo a janela de contexto.

## Conceitos principais

### Os três tipos de memória do agente
| Memória | O que é | De onde vem |
|---|---|---|
| **Episódica** | O que aconteceu na sessão (eventos, interação) | Janela de contexto |
| **Semântica** | Fatos e conhecimento do mundo | Treino do modelo |
| **Procedural** | *Saber como fazer* uma tarefa | **Skill** |

A skill preenche a lacuna da memória procedural.

### O que colocar (e o que não colocar) numa skill
- ❌ Coisas que o modelo já sabe (ex.: rodar `kubectl` — já está na base de conhecimento).
- ✅ **O seu modo de trabalhar**: o processo de troubleshooting que *você* faz no Kubernetes, como a empresa escreve um documento, como montar um PRD/ADR. "Aquilo que só fulano sabe fazer."

### Quando criar uma skill
- Fluxo que você executa uma ou mais vezes e vive copiando e colando prompt.
- Workflow que precisa ser **distribuído para a equipe** ou ficar vinculado a um projeto.
- Skills tendem a ser **generalistas** (servem a vários projetos).

### Quando *não* criar
- Fluxo executado uma única vez.
- Fluxo específico de um único projeto que não será reaproveitado.

### Skill × MCP
- **MCP** acessa serviço externo; **skill** ensina um fluxo/habilidade.
- Um não substitui o outro — **se complementam**.

### As três categorias de skills
1. **Workflow** — automação, ordem de execução, passo a passo de tarefas.
2. **Documentos e assets** — guidelines, padrões de nomenclatura, estrutura de projeto, system design, templates de documentos/design docs. Funcionam mais como validação e boas práticas.
3. **Ferramentas** — ensinam o agente a usar um MCP ou uma CLI (inclusive ferramentas internas).

### Skill como *guide* ou *sensor* no Harness
- Principalmente **guide**: carregada antes da ação, orienta o passo a passo.
- Também pode ser **sensor**, normalmente **sensor de inferência**: valida guidelines, system design, padrões.
- Cuidado: sensor de inferência depende da interpretação do modelo — deixe **critérios de aceite muito claros** e combine com **sensores determinísticos**.

## Pegadinhas
- Skill não é "lixeira de prompt": se o modelo já sabe fazer, não precisa.
- Colocar tudo de uma vez no contexto (vários prompts) polui a janela — skills resolvem isso carregando só o necessário.
- Sensor de inferência pode ou não executar a validação; não confie só nele.

## Dúvidas para revisar
- Quais fluxos do meu dia a dia são "só eu sei fazer" e virariam boas skills?
- Onde no meu Harness eu preciso de sensor determinístico além da skill?
