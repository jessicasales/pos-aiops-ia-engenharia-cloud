# State

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 05 — State (13:15) |
| **Assunto** | Estado de execução (to-do list) que acompanha o progresso real, complementando o Scratchpad |
| **Data** | 04/11/2026 00:12 |
| **Tags** | state, to-do-list, progresso, scratchpad, kanban, claude-code, spec-driven-development |

## Resumo da aula

O Scratchpad diz **o que deve ser feito** (intenção/plano). O **State** diz **o que foi feito** (realidade). É uma **to-do list** com status (concluído, em andamento, pendente) — como um Kanban, mas armazenado de forma que várias janelas de contexto ou subagentes consultem.

## Conceitos principais

- **Scratchpad = intenção; State = realidade.** Juntos formam a **linha do tempo** de execução de tarefas longas.
- Resolve **Distraction** e **Poisoning**: o arquivo de tarefa é a **referência primária** (ponto de verdade), e o State mostra onde cada tarefa está.
- Implementação livre: arquivo, banco, MCP, ou apontar para Linear/Notion/Kanban. O conceito importa mais.

### Demo (Claude Code)

O Claude Code gera uma to-do list (um JSON por tarefa, com `status`: pending/in_progress/completed) e vai marcando conforme executa. Ao pausar e retomar (`continue`), ele sabe de onde parou pelo State. Muito usado com Spec-Driven Development.

## Comandos e configurações

Aula demonstrativa (Claude Code gerencia o State automaticamente); sem prompt de referência.

## Pegadinhas

- O Claude Code só cria State automaticamente para tarefas complexas/longas — você pode forçar: *"utilize uma to-do list para controlar as alterações de cada projeto"*.
- O arquivo de tarefa é o ponto de verdade; aponte seu agente para ele.

## Dúvidas para revisar

- Vou usar State em arquivo, banco ou integrado a um board (Linear/Notion)?
- Como combinar Scratchpad (plano) + State (progresso) nos meus agentes de longa duração?
