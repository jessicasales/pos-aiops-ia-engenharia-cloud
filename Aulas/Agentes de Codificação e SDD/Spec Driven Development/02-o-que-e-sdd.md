# O Que É SDD

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 02 — O Que É SDD (14:45) |
| **Assunto** | Definição de SDD, seus três componentes (spec, plano, tarefas) e os três modos de usar a spec |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `spec-driven-development` `especificação` `planejamento` `tasks` `memory-bank` `least-to-most` `prd` |

## Resumo da aula

Vibe Code é rápido mas vulnerável: sem padronização, não escala com o time, e erro em produção sai caro. **Spec Driven Development (SDD)** é a metodologia onde o desenvolvimento é **dirigido por especificação** — a spec guia o trabalho e a geração de código.

## Conceitos principais

### O que uma especificação precisa ter
- **O quê** (objetivo, o que será entregue) e **por quê**.
- **Limites e restrições** — inclusive o que **não** deve ter.
- **Critérios de aceitação** — como avaliar se a implementação atende o requisito.

Com objetivo + restrições + critérios, você ganha **previsibilidade, padronização e escalabilidade**.

### Os três componentes do SDD
| Componente | Pergunta que responde |
|---|---|
| **Especificação (spec)** | O quê e por quê |
| **Planejamento** | Como implementar (tecnologias, arquitetura) |
| **Tarefas (tasks)** | Decomposição em passos executáveis pelo agente |

A decomposição em tarefas lembra a técnica de prompt **least-to-most** (quebrar em partes menores, do mais fácil ao mais difícil). O resultado final desses três componentes é o **código** — que pode ser Dockerfile, Terraform, manifesto Kubernetes, pipeline etc., não só "código de aplicação".

### Os três modos de usar a spec
| Modo | Como funciona |
|---|---|
| **Spec First** | Cria a spec, executa a tarefa baseada nela, depois **descarta** a spec — ciclo de vida curto, específico daquela entrega |
| **Spec Anchored** | A mais comum hoje — a spec é um **elemento vivo**, descrição viva do sistema, evolui junto com o projeto |
| **Spec as Source** | A spec é a **fonte de verdade** e o código é a saída exata dela (análogo ao Terraform: código → `apply` → infraestrutura). Muito difícil de implementar na prática |

### Spec local × contexto global (Memory Bank)
- A **spec** é escopada a uma feature/regra de negócio/fluxo específico.
- O **Memory Bank** (regras gerais do projeto) é contexto **global**, usado em todas as specs: stack definida, padrões de arquivo, estrutura de projeto, perfis de execução (produção/desenvolvimento) etc. Não repita isso em cada spec — isso é engenharia de contexto: colocar a informação certa, no momento certo, com o custo certo.

### O que faz uma boa spec
1. **Clareza** — sem ambiguidade, sem informação "intrínseca"/dedutível. "Pensar que a IA vai deduzir algo é o maior erro" de quem trabalha com DevOps/Cloud e IA.
2. **Verificável/testável** — critérios objetivos de sucesso (ex.: "lista todos os pods do cluster", não "lista os pods" de forma vaga).
3. **Acionável** — o agente consegue executar sem precisar adivinhar nada.

## Pegadinhas
- O que parece "óbvio" para você não é óbvio para a IA — todo critério precisa estar escrito.
- Spec Anchored é o padrão mais usado; não force Spec as Source sem necessidade.

## Dúvidas para revisar
- Próxima aula trata de Design Docs e PRD (Product Requirement Document) como ponto de partida para construir boas specs.
