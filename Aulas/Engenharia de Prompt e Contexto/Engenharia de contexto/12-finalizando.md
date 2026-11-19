# Finalizando — Engenharia de contexto

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 12 — Finalizando (05:54) |
| **Assunto** | Apanhado geral: como os componentes se conectam em torno da janela de contexto |
| **Data** | 04/11/2026 00:12 |
| **Tags** | revisao, janela-de-contexto, componentes, context-fails, harness-engineering, agentes |

## Resumo da aula

Revisão do capítulo. Tudo gira em torno da **janela de contexto** (a RAM/informação quente). Em volta dela, os componentes:

| Grupo | Componentes | Papel |
|---|---|---|
| Memória/armazenamento | Memória de longo prazo, Scratchpad, State | Persistir entre sessões; plano; progresso |
| Janela | Compactação e descarte (sumário, trim, slice) | Reduzir a janela (com perda) |
| Acesso externo | Tools, RAG | Comunicar com o mundo; buscar conhecimento |
| Isolamento | Subagentes, Sandbox | Isolar contexto/persona; isolar execução |

## Conceitos principais

### Cada componente mitiga um context fail

Poisoning, Distraction, Confusion, Clash — cada recurso ajuda a resolver um ou mais. (Tabela de referência fornecida na aula.)

### Ligação com os próximos módulos

Engenharia de contexto conecta com **Harness Engineering** (engenharia de environment) e com **agentes autônomos**. Nos agentes de codificação, os conceitos viram recursos concretos:

| Conceito | Implementação |
|---|---|
| Multiagente | subagentes do Claude Code |
| Memória | `CLAUDE.md` + preferências |
| RAG/Tools | MCPs |
| Ambiente | sandbox |

## Comandos e configurações

Aula de fechamento, sem prompts.

## Pegadinhas

- Os conceitos ficaram abstratos de propósito — a implementação prática vem nos módulos de agentes.

## Dúvidas para revisar

- Qual mapa dos componentes de contexto para o meu primeiro agente autônomo?
- Qual context fail é o meu maior risco hoje, e qual componente o mitiga?
