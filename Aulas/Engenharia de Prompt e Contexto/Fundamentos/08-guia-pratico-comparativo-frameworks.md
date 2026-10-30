# Guia Prático: Comparativo de Frameworks e Árvore de Decisão

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 08 — Guia Prático: Comparativo de Frameworks e Árvore de Decisão (material complementar) |
| **Assunto** | Material de referência rápida: resumo dos 4 componentes, dos 5 frameworks, tabela comparativa, combinações e fluxo de decisão |
| **Data** | 29/10/2026 22:35 |
| **Tags** | guia-pratico, rtf, tag, bab, care, rise, comparativo, arvore-de-decisao, combinacao |

## Resumo da aula

Material complementar (texto, não vídeo) que consolida o capítulo. Serve como referência rápida para escolher e aplicar o framework certo. Reafirma que todo prompt eficaz se apoia nos **4 componentes** (Role/persona, Contexto, Instrução/ação, Output/formato) e que os frameworks são arranjos otimizados desses componentes por tipo de tarefa.

## Conceitos principais

### Os 5 frameworks em uma linha

| Framework | Componentes | Diferencial | Cenário ideal | Limitação |
|---|---|---|---|---|
| **R-T-F** | Role, Task, Format | Formato da saída | Tarefas diretas e previsíveis | Sem espaço para contexto ou sequência |
| **T-A-G** | Task, Action, Goal | Objetivo de negócio | Resultados atrelados a metas/SLAs | Inútil sem objetivo mensurável |
| **B-A-B** | Before, After, Bridge | Transformação (antes→depois) | Migrações e refatorações | Requer estado anterior claro |
| **C-A-R-E** | Context, Action, Result, Example | Exemplo de referência | Consistência e replicabilidade | Precisa ter exemplo disponível |
| **R-I-S-E** | Role, Input, Steps, Expectation | Passos sequenciais | Processos e workflows | Overhead excessivo para tarefas simples |

### Combinando frameworks

Não são mutuamente exclusivos. Comece pelo mais simples que resolve e adicione elementos só quando necessário.

| Base | + Elemento | Resultado |
|---|---|---|
| R-T-F | + Example (C-A-R-E) | Script simples que segue padrão existente |
| T-A-G | + Steps (R-I-S-E) | Objetivo de negócio com procedimento definido |
| B-A-B | + Expectation (R-I-S-E) | Migração com critérios de sucesso por fase |

**Regra de ouro:** se o framework base já resolve, não adicione complexidade. Cada elemento extra deve justificar sua presença.

### Fluxo de decisão (perguntas-guia)

1. A tarefa tem **passo a passo / sequência**? → R-I-S-E
2. Há **estado atual e desejado** (transformação)? → B-A-B
3. Preciso de **consistência via exemplo** de referência? → C-A-R-E
4. O resultado precisa atender **meta/SLA/KPI**? → T-A-G
5. Nenhum dos acima, tarefa direta e previsível? → R-T-F

## Pegadinhas

- Se o prompt não gera bons resultados, provavelmente falta clareza em um dos 4 componentes — volte a eles antes de trocar de framework.
- Few-shot (dar exemplos, via Example do C-A-R-E) é citado como ~80% mais eficiente que zero-shot.

## Dúvidas para revisar

- Vale montar um "cola" pessoal com os 5 frameworks e os prompts-template da Jéssica para o dia a dia de DevOps/SRE?
- O fluxo de decisão cobre casos combinados (ex.: migração COM SLA) — qual framework lidera quando dois critérios se aplicam?
