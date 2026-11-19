# Introdução — Técnicas de Prompt Engineering

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 01 — Introdução (04:08) |
| **Assunto** | Diferença entre framework (estrutura do prompt) e técnica (controle do processamento do modelo) |
| **Data** | 03/11/2026 23:50 |
| **Tags** | tecnicas-de-prompt, framework-vs-tecnica, zero-shot, few-shot, chain-of-thoughts, transformer, reasoning |

## Resumo da aula

Abertura do capítulo. Retoma o capítulo anterior (anatomia do prompt + frameworks R-T-F, T-A-G, B-A-B, C-A-R-E, R-I-S-E e a árvore de decisão) e separa dois conceitos que trabalham juntos: **framework** organiza o *input* (o que colocar e em que ordem); **técnica** controla o *processamento* (como o modelo pensa e gera a resposta). As técnicas influenciam o comportamento do Transformer na hora de gerar a saída.

## Conceitos principais

### Framework ≠ Técnica

| | Framework | Técnica |
|---|---|---|
| **O que faz** | Organiza a estrutura do input | Controla como o modelo processa |
| **Analogia 1** | Planta da casa (onde vão os cômodos) | Como você constrói |
| **Analogia 2 (GPS)** | O endereço de destino | O modo de navegação (rota rápida, sem pedágio) |
| **Exemplos** | R-T-F, C-A-R-E, R-I-S-E | Zero-shot, Few-shot, Chain of Thoughts |

Mesma instrução dada de formas diferentes (sem exemplo vs. com três exemplos) produz comportamento totalmente diferente — é a técnica atuando.

### Por que importa

- Técnica não é só organizar o prompt; é **influenciar o comportamento do modelo** na geração.
- Ligação direta com a arquitetura Transformer vista no capítulo anterior: a técnica controla como o Transformer pondera os tokens.
- Frameworks e técnicas são **combinados**, sempre.

### O que o capítulo vai cobrir

Das técnicas fundamentais às de raciocínio avançado: Zero-shot, Few-shot, Chain of Thoughts, Tree of Thoughts e mais.

## Comandos e configurações

Aula conceitual, sem prompts de demonstração ("Código da Aula" vazio).

## Pegadinhas

- Framework e técnica não são excludentes nem substitutos — você usa os dois juntos.
- O modelo já tem uma cadeia de raciocínio própria (implícita); a técnica serve para **dar direcionamento** a esse raciocínio.

## Dúvidas para revisar

- Qual a combinação framework + técnica que melhor se encaixa nas tarefas de diagnóstico de incidente do meu dia a dia?
- Em quais tarefas vale a pena pagar o custo extra de tokens de uma técnica de raciocínio?
