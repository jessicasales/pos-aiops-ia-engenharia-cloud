# Fundamentos — Engenharia de Prompt e Contexto

Anotações do capítulo **Fundamentos** do módulo **Engenharia de Prompt e Contexto** (curso Pós AIOps e IA na Engenharia de Cloud).

O capítulo cobre a base da engenharia de prompt: os 4 componentes de um prompt eficaz e os 5 frameworks de prompting, cada um com seu cenário ideal.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [O que é Prompt Engineering e por que importa](01-o-que-e-prompt-engineering.md) | 06:02 | Definição, por que a qualidade do input importa, o que o módulo cobre |
| 02 | [Anatomia de um Prompt Eficaz](02-anatomia-de-um-prompt-eficaz.md) | 33:53 | Os 4 componentes base: Role, Contexto, Instrução, Output |
| 03 | [Framework R-T-F (Role, Task, Format)](03-framework-rtf.md) | 13:05 | Framework simples para tarefas diretas de uso comum |
| 04 | [Framework T-A-G (Task, Action, Goal)](04-framework-tag.md) | 11:00 | Orientado a resultado — meta/SLA/KPI |
| 05 | [Framework B-A-B (Before, After, Bridge)](05-framework-bab.md) | 16:42 | Transformação — migrações, refatorações, transições |
| 06 | [Framework C-A-R-E (Context, Action, Result, Example)](06-framework-care.md) | 15:30 | Precisão por exemplo — passo para o few-shot |
| 07 | [Framework R-I-S-E (Role, Input, Steps, Expectation)](07-framework-rise.md) | 14:47 | Procedural — runbooks, diagnósticos, workflows |
| 08 | [Guia Prático: Comparativo de Frameworks e Árvore de Decisão](08-guia-pratico-comparativo-frameworks.md) | material | Referência rápida: comparativo, combinações, fluxo de decisão |

## Resumo rápido dos frameworks

| Framework | Diferencial | Use quando |
|---|---|---|
| R-T-F | Formato da saída | Tarefa direta e previsível |
| T-A-G | Objetivo de negócio | Resultado atrelado a meta/SLA |
| B-A-B | Transformação (antes→depois) | Migração / refatoração |
| C-A-R-E | Exemplo de referência | Consistência e replicabilidade |
| R-I-S-E | Passos sequenciais | Processo / workflow |
