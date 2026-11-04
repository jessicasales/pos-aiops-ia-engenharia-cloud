# Sandbox

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 11 — Sandbox (04:54) |
| **Assunto** | Ambiente isolado (pasta/container/VM) para executar código/scripts com segurança |
| **Data** | 04/11/2026 00:12 |
| **Tags** | sandbox, isolamento, execucao-de-codigo, container, ci-cd, distraction, poisoning |

## Resumo da aula

O **Sandbox** é uma "caixa de areia" — um ambiente **isolado** (pasta, container ou VM) onde o agente executa código/scripts com segurança, sem comprometer o ambiente real. Exemplo clássico: ao processar CSV/Excel, o agente gera um script Python em runtime, executa num diretório/container isolado e retorna só o **resultado**.

## Conceitos principais

### Sandbox ≠ Subagente

| | Subagente | Sandbox |
|---|---|---|
| **Isola** | Papel/persona e **janela de contexto** | **Execução de código** |

### Problemas que resolve

- **Distraction**: devolve o dado já filtrado/trabalhado, sem poluir a janela.
- **Poisoning**: isola a execução de dados não confiáveis.

### Analogia

É o mesmo conceito do **runner de pipeline CI/CD** (GitHub Actions, GitLab): um ambiente efêmero e isolado para executar. Na área de DevOps, containers tornam o sandbox fácil de implementar.

## Comandos e configurações

Aula conceitual — sem demo no Claude Code (não há sandbox nativo ali). Prática com agentes nos módulos seguintes.

## Pegadinhas

- Não confunda com subagente: aqui o foco é isolar **execução**, não contexto.

## Dúvidas para revisar

- Onde eu precisaria de sandbox (testar manifesto, rodar script) no meu fluxo?
- Container, VM ou pasta isolada para cada tipo de execução?
