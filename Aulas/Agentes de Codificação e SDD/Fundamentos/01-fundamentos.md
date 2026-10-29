# Fundamentos — a evolução dos agentes de codificação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Fundamentos |
| **Aula** | 01 — Fundamentos (14:23) |
| **Assunto** | Linha do tempo do autocomplete ao agente assíncrono; agente × harness |
| **Data** | 29/10/2026 19:14 |
| **Tags** | `agente` `harness` `loop de execução` `agentic loop` `Devin` `harness engineering` `probabilístico` |

## Resumo da aula

Abertura do módulo "Agentes de Codificação". Até aqui o curso trabalhou engenharia de prompt e de contexto interagindo via chat (copiar e colar). Agora o foco muda para **delegar** tarefas a um agente que lê, edita e executa código direto no ambiente, num loop de execução — sem o copiar-e-colar manual.

## Conceitos principais

### Linha do tempo até os agentes de hoje
| Momento | Marco | Característica |
|---|---|---|
| Pré-boom de IA | Autocomplete de IDE | Simples, previsível, pouco inteligente |
| ~2020 | GitHub Copilot | Autocomplete prevê função inteira, mas ainda depende 100% do dev |
| 2022 | ChatGPT | Chat: copiar prompt, colar código, copiar erro, colar de volta — sem acesso à base de código |
| — | Chat no Copilot | Mais contexto (abrir arquivo, colar saída de terminal), ainda em formato chat |
| — | Agentes síncronos (Claude Code, Cursor) | Loop real de escrever→executar→observar, mas o dev ainda aprova cada passo |
| ~2024 (Devin) | Agentes assíncronos/background | Executa num ambiente próprio (como uma VM isolada), sem rodar na sua máquina; hoje a maioria das ferramentas oferece isso |

O que destravou isso agora: evolução dos modelos, velocidade das ferramentas, capacidade de isolar ambientes e amadurecimento do mercado como um todo.

### Agente ≠ LLM
O modelo (LLM) é só um componente. **O agente é a combinação de**: o modelo + as ferramentas do ecossistema + o componente de **loop** que orquestra tudo.

### O loop do agente
1. Observa a tarefa.
2. Verifica se tem os insumos necessários (se não, decide o que fazer).
3. Toma a ação (executar ferramenta, obter arquivo, escrever código).
4. Volta a observar.

### Agente × automação de CI/CD
| | Automação tradicional | Agente de IA |
|---|---|---|
| Natureza | Determinística | **Probabilística** |
| Resultado | Mesmo input → mesmo output | Mesmo input pode gerar caminhos/decisões diferentes a cada execução |

Por ser probabilístico, nada é 100% previsível — a mesma tarefa pode usar 3 ou 5 chamadas de ferramenta dependendo do momento. Isso justifica montar um **harness** bem calibrado para ganhar assertividade, economizar tempo e dinheiro.

### Harness Engineering
- É a capacidade de criar o **ecossistema em torno do agente** (o ambiente): regras de projeto, skills, hooks (validações e eventos), subagentes, permissões etc.
- Muitas vezes o harness pesa **mais que o modelo**: um agente com Opus mal configurado pode render pior que um com Sonnet bem calibrado.
- Case citado: "Guerra da lente" — subiu de 30º para 5º lugar só ajustando o harness, sem trocar o modelo.
- Regra prática: toda vez que uma execução falhar e você corrigir manualmente, **transforme essa correção em regra, hook ou skill** — o harness evolui com o uso.

### Paradigmas que o módulo vai usar
Engenharia de prompt + engenharia de contexto (já vistas) + **engenharia de agentes** (mais consumo que criação) + **Harness Engineering** (termo em alta em 2026).

## Pegadinhas
- Não confundir "modelo melhor" com "harness melhor" — um harness desestruturado pode anular a vantagem de um modelo mais forte.
- A falta de previsibilidade é normal (probabilístico); o objetivo do harness é reduzir essa variância, não eliminá-la.

## Dúvidas para revisar
- Que falhas recorrentes no meu dia a dia (DPMG, infra) já poderiam virar regra/skill/hook?
