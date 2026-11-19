# Scratchpad

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 04 — Scratchpad (08:29) |
| **Assunto** | Rascunho de raciocínio/plano persistido pelo ciclo da tarefa, fora da janela de contexto |
| **Data** | 04/11/2026 00:12 |
| **Tags** | scratchpad, plano-de-acao, rascunho, plan-mode, claude-code, spec-driven-development, distraction |

## Resumo da aula

Entre a memória de curto prazo (sessão) e a de longo prazo (fatos duráveis) há um meio-termo: o **Scratchpad** (rascunho). É um "caderno" com o **plano de ação** da tarefa — passo a passo, itens a investigar, hipóteses, resultados intermediários. Dura o **ciclo da tarefa**, não uma única sessão nem para sempre.

## Conceitos principais

- Resolve o **Distraction**: tirar o plano da janela de contexto evita que ele caia no miolo cego e seja ignorado quando a janela enche.
- Permite **múltiplas sessões/janelas** ou **múltiplos agentes** acessarem o mesmo plano compartilhado.
- Muito usado em **Spec-Driven Development** (o plano de ação vira um arquivo de planejamento).

### Demo (Claude Code Plan Mode)

`Shift+Tab` entra no **Plan Mode**: o agente planeja antes de agir e grava o plano em `.claude/` (arquivo externo à janela). Mesmo em Auto Mode ou com múltiplos agentes, o plano não se perde porque está fora da janela de contexto.

## Prompts da aula

<details>
<summary>Artefatos da demo</summary>

```text
# Prompt ditado no Plan Mode (tarefa ampla o bastante para forçar o planejamento)
eu quero converter todos os projetos que hoje estão utilizando o Gemini para utilizar o modelo Claude Haiku
```

```text
# Resumo do plano gerado (contexto + alerta de incompatibilidade)
Contexto: todos os cinco projetos do repositório usam o Google Gemini via LangChain Google GenAI.
Alerta: o projeto 5 também utiliza embed sem suporte na Anthropic.
```

</details>

## Pegadinhas

- Scratchpad ≠ memória de longo prazo: não guarde fatos duráveis aqui, só o plano da tarefa.
- Sozinho, o plano não controla o progresso — para isso use o **State** (próxima aula).

## Dúvidas para revisar

- Onde gravo o scratchpad dos meus agentes (arquivo, `.claude/`, banco)?
- Como o scratchpad se encaixa no meu fluxo de SDD?
