# Técnicas avançadas de Prompt Engineering — Engenharia de Prompt e Contexto

Anotações do capítulo **Técnicas avançadas de Prompt Engineering** do módulo **Engenharia de Prompt e Contexto** (curso Pós AIOps e IA na Engenharia de Cloud).

Se as técnicas do capítulo anterior ensinam o modelo a **pensar melhor** dentro de uma interação, estas adicionam o que faltava para um resultado confiável em produção: **decompor, verificar e agir**. É a ponte entre escrever bons prompts e construir agentes autônomos.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 03:53 | O que falta: decomposição, verificação, ação |
| 02 | [Prompt Chaining](02-prompt-chaining.md) | 21:01 | Prompts em cadeia, uma responsabilidade cada, com gates |
| 03 | [Least-to-Most](03-least-to-most.md) | 17:07 | Decompor em subproblemas, resolver do simples ao complexo |
| 04 | [Chain of Verification](04-chain-of-verification.md) | 29:37 | IA audita os próprios fatos (verificação isolada) |
| 05 | [Self-Refine](05-self-refine.md) | 22:06 | Autocrítica por critérios para melhorar a qualidade |
| 06 | [ReAct](06-react.md) | 19:52 | Raciocínio + ação; a base dos agentes de IA |

## Resumo rápido

| Técnica | Pergunta que responde | Base de |
|---|---|---|
| Prompt Chaining | Como orquestrar várias etapas? | workflows (n8n, LangChain) |
| Least-to-Most | Como decompor o problema? | Spec-Driven Development |
| Chain of Verification | Está **correto**? | confiabilidade de fatos |
| Self-Refine | Está **bom o suficiente**? | qualidade iterativa |
| ReAct | E se eu precisar de **dados reais**? | agentes de IA |

## Como se combinam

- **Least-to-Most** decompõe → **Prompt Chaining** executa em cadeia → **gates** entre etapas.
- **ReAct** busca os dados reais → **Self-Refine** melhora a qualidade → **Chain of Verification** confirma que está correto.
- Fluxo de engenharia: Least-to-Most decompõe a feature + critérios de aceite → o agente implementa → Chain of Verification valida cada entrega.

## Ponte para os próximos módulos

- **Prompt Chaining** é a versão manual do que os agentes fazem automaticamente.
- **ReAct** é o padrão que roda por baixo dos agentes (Claude Code, Copilot, Amazon Q, Kiro; frameworks LangChain, CrewAI).
- A verificação isolada do CoVe vira natural com **subagentes** (janela de contexto própria).

> As técnicas de raciocínio/verificação consomem mais tokens (prompts encadeados). A escolha é sempre equilíbrio entre **confiabilidade e custo**.
