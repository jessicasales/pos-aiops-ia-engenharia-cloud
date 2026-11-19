# Documentação Técnica Assistida por IA

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | GenIA - Cotidiano técnico |
| **Aula** | 05 — Documentação Técnica Assistida por IA (09:46) |
| **Assunto** | Transformar dados brutos em documentação (post-mortem, runbook, README) com IA |
| **Data** | 04/11/2026 00:55 |
| **Tags** | documentacao, post-mortem, runbook, readme, google-sre, markdown, janela-de-contexto |

## Resumo da aula

Ninguém gosta de documentar — e a IA é ótima nisso: pega dados brutos (anotações de incidente, procedimentos, código, logs de commit) e gera post-mortem, runbook, README, release notes, PRD, design docs, SLI/SLO.

## Conceitos principais

- **Dica de ouro**: ao resolver um incidente com Claude Code/Gemini CLI, todo o contexto da investigação já está na **janela de contexto** — peça o **post-mortem** ali mesmo, sem precisar persistir dados.
- Exemplos: gerar post-mortem no **formato Google SRE** (resumo, impacto, timeline, causa raiz, resolução, lições, ações); transformar um procedimento manual em **runbook** (pré-requisitos, passos, comandos, verificação, rollback, troubleshoot).
- **Seja específico**: peça "retorne em Markdown" (senão pode gerar Word). Emojis: os LLMs usam muito — peça para não usar se preferir.

## Prompts da aula

<details>
<summary>Exemplos</summary>

```text
# Post-mortem (formato Google SRE)
Com base nas anotações abaixo de um incidente, crie um post-mortem seguindo o
formato do Google SRE com as seções: resumo, impacto, timeline, causa raiz,
resolução, lições aprendidas e ações. Retorne em Markdown.
[anotações]

# Runbook
Transforme esse procedimento manual em um runbook estruturado com pré-requisitos,
passos detalhados, comandos exatos, verificação de cada passo, procedimento de
rollback e troubleshoot. Retorne em Markdown.
[procedimento]
```

</details>

## Pegadinhas

- Sem "retorne em Markdown", o modelo pode assumir Word.
- A qualidade do doc depende da riqueza do contexto (log estruturado > anotações vagas).

## Dúvidas para revisar

- Vale um template de post-mortem/runbook da empresa para a IA seguir?
- Posso gerar o post-mortem direto da janela do agente ao resolver o incidente?
