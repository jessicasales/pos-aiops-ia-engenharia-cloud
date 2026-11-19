# Introdução — Técnicas avançadas de Prompt Engineering

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas avançadas de Prompt Engineering |
| **Aula** | 01 — Introdução (03:53) |
| **Assunto** | O que falta entre bom raciocínio e resultado confiável: decomposição, verificação e ação |
| **Data** | 03/11/2026 23:58 |
| **Tags** | tecnicas-avancadas, decomposicao, verificacao, acao, prompt-chain, react, ponte-para-agentes |

## Resumo da aula

Retoma o capítulo anterior (zero/few-shot + CoT, ToT, SoT, Self-Consistency, Step-Back) e aponta a limitação comum: todas operam **dentro de uma única interação**. O modelo pensa bem, mas:

1. **Não decompõe sozinho** — problema grande, ele tenta resolver tudo de uma vez.
2. **Não verifica** — gera a resposta e assume que está certa.
3. **Não age** — produz um plano, mas não executa nada.

Entre um bom raciocínio e um resultado confiável em produção faltam etapas: **decomposição, refinamento, verificação, orquestração e ação**. É o que este capítulo resolve.

## Conceitos principais

### O que o capítulo cobre

| Técnica | Resolve |
|---|---|
| **Prompt Chaining** | Orquestrar prompts em cadeia (output de um alimenta o próximo) |
| **Least-to-Most** | Decompor problema complexo em subproblemas progressivos |
| **Chain of Verification** | Fazer a IA auditar os próprios fatos |
| **Self-Refine** | Ciclo de autocrítica para melhorar a qualidade |
| **ReAct** | Raciocínio + ação (consultar fontes externas) |

### A ponte para os agentes

Este capítulo liga "escrever bons prompts" a "construir agentes autônomos":
- **Prompt Chaining** é a versão manual do que fluxos de automação (n8n, LangChain) fazem.
- **ReAct** é literalmente o padrão que roda por baixo dos agentes de IA.

## Comandos e configurações

Aula conceitual, sem prompts de demonstração.

## Pegadinhas

- "Pensar melhor" (as técnicas do capítulo anterior) não basta para produção: falta decompor, verificar e agir.

## Dúvidas para revisar

- Quais dos meus fluxos atuais são, na verdade, Prompt Chains manuais que eu poderia formalizar?
- Onde a falta de verificação/ação já me causou problema em produção?
