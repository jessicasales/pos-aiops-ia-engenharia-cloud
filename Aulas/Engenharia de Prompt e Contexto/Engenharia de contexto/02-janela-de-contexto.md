# Janela de Contexto

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 02 — Janela de Contexto (15:51) |
| **Assunto** | Memória de curto prazo da sessão; limites de token, lost in the middle e os 4 context fails |
| **Data** | 04/11/2026 00:12 |
| **Tags** | janela-de-contexto, memoria-curto-prazo, tokens, lost-in-the-middle, poisoning, distraction, confusion, clash |

## Resumo da aula

A **janela de contexto** armazena toda a interação atual com a IA. É a **memória de curto prazo**, existe **por sessão** e é **volátil**. Por baixo dos panos ela empilha: System Prompt + mensagens do usuário + respostas do assistente + chamadas de ferramentas. A cada turno, **todo o histórico é reenviado** ao modelo (a "memória" é construída na unha, como um array).

## Conceitos principais

### Limites de token (por modelo)

| Modelo | Janela |
|---|---|
| Opus 4.x | ~1 milhão de tokens |
| Sonnet | até ~1M (ou 250k) |
| Haiku | ~250 mil tokens |

A partir de ~70-80% de uso entra a **zona crítica**: degradação, maior latência e **maior custo** (a própria API cobra mais por janelas maiores). Recomendação: trabalhar em 60-70% e **limpar a janela** ao terminar cada tarefa. Português gasta mais tokens que inglês.

### Lost in the middle (miolo cego)

O modelo lê bem o **início** e o **fim** da janela; o **meio** ele "esquece". Coloque instruções/role no início e os exemplos/tarefa no fim — não deixe o principal no miolo.

### Os 4 context fails

| Fail | O que é | Mitigação |
|---|---|---|
| **Poisoning** | Dado errado entra e vira referência fixa (contamina tudo) | Curadoria de dados verídicos |
| **Distraction** | Janela cresce demais e o modelo se prende ao histórico, ignorando a tarefa | Janela enxuta, compactação, isolamento |
| **Confusion** | Um detalhe pequeno ganha peso demais e o modelo insiste nele | Gerenciar o contexto |
| **Clash/Crash** | Informações contraditórias (ex.: pediu Markdown, depois JSON) | Evitar instruções conflitantes |

## Comandos e configurações

Aula conceitual, sem prompts de demonstração.

## Pegadinhas

- Cada turno reenvia todo o histórico → mais tokens (cache mitiga, mas o empilhamento é real).
- Não deixe informações críticas no miolo da janela.

## Dúvidas para revisar

- Qual o meu teto prático de ocupação antes de limpar/compactar?
- Como estruturo meus prompts longos para evitar o lost in the middle?
