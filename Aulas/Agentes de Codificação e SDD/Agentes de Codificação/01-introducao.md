# Introdução — projeto EncontroStack e as 5 etapas de implementação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Agentes de Codificação |
| **Aula** | 01 — Introdução (04:40) |
| **Assunto** | Apresentação do projeto prático EncontroStack e o roteiro das 5 etapas até produção |
| **Data** | 29/10/2026 19:19 |
| **Tags** | `encontros-tech` `flask` `mvc` `claude-code` `codex` `opencode` `cursor` `antigravity` |

## Resumo da aula

Início da parte prática do capítulo: sair do "chat copia-e-cola" para o agente lendo repositório, escrevendo arquivos e rodando comandos de verdade. Projeto usado: **EncontroStack**, aplicação em **Python/Flask** (MVC: rotas, interface web, conexão PostgreSQL) para cadastro de eventos de tecnologia. Aplicação funcional, mas **sem os elementos de produção**.

## Conceitos principais

### As 5 etapas do capítulo (cada uma com uma ferramenta diferente, de propósito)
| Etapa | O que faz | Ferramenta |
|---|---|---|
| 1 | Dockerfile, docker-compose e manifests Kubernetes | **Claude Code** |
| 2 | Script de teste/seed (população de dados) | **Codex** |
| 3 | Infraestrutura como código (Terraform) | **OpenCode** |
| 4 | Endpoints de health/ready (melhoria do projeto) | **Cursor** |
| 5 | Documentação (README) | **Antigravity** |

Motivo de usar todas: mostrar que **o conceito importa mais que a ferramenta** — como você estrutura prompts, comandos, skills é o que transfere entre ferramentas.

## Pegadinhas
- Quem só tiver assinatura de uma ferramenta pode fazer tudo nela — não é obrigatório seguir à risca as 5 ferramentas, mas o professor recomenda a experiência completa.

## Dúvidas para revisar
- Fazer fork do repositório EncontroStack para reproduzir o capítulo (confirmar: fork, não clone direto, para poder commitar).
