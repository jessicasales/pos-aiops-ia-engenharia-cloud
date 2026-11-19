# Avaliação humana

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Avaliação de prompts |
| **Aula** | 04 — Avaliação humana (15:53) |
| **Assunto** | Onde o humano é insubstituível, os 3 vieses e como mitigá-los |
| **Data** | 04/11/2026 00:20 |
| **Tags** | avaliacao-humana, vieses, read-in, goal-post-shifting, cherry-picking, blind-review, cross-review |

## Resumo da aula

O determinístico não avalia **fidelidade, completude e acionabilidade** — isso exige interpretação humana. Mas o humano não escala; entra em **momentos estratégicos**.

## Conceitos principais

### Onde o humano é insubstituível

1. **Construir os critérios** de avaliação (o quê avaliar).
2. **Calibrar o LLM juiz**.
3. **Auditoria pontual** quando há dúvida sobre o juiz.

### Os 3 vieses humanos

| Viés | O que é | Mitigação |
|---|---|---|
| **Read-in** | A mente preenche lacunas de erro no automático (olhar superficial) | **Blind review** (output embaralhado, sem saber a origem) |
| **Goal-post shifting** | Baixar a régua da qualidade para o output passar (pressão/pressa) | **Outcome measures** (critérios/checklist definidos ANTES de ver o output) |
| **Cherry picking** | Rodar várias vezes e escolher só o output campeão (prompt não é estável) | **Cross review** (2+ avaliadores independentes, aprovação unânime) |

## Comandos e configurações

Aula conceitual; instrumentos implementáveis por script (ex.: embaralhar outputs para blind review).

## Pegadinhas

- Autoavaliação (avaliar o que você mesmo criou) tende a aprovar — evite.
- Cherry picking esconde instabilidade do prompt — valide a consistência, não um output isolado.

## Dúvidas para revisar

- Onde no meu fluxo o humano entra (critérios, calibração, auditoria)?
- Como implementar blind review e cross review no time?
