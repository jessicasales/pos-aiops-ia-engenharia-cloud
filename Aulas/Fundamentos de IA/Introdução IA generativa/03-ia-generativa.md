# IA Generativa

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | Introdução IA generativa |
| **Aula** | 03 — IA generativa (09:34) |
| **Assunto** | O que diferencia IA generativa do ML tradicional e suas aplicações em Cloud/DevOps |
| **Data** | 04/11/2026 00:30 |
| **Tags** | ia-generativa, geracao-de-conteudo, multimodal, aiops, troubleshooting, orquestrador, well-architected |

## Resumo da aula

A diferença fundamental da **IA generativa** para o ML tradicional: o ML **analisa** (classifica/prevê/agrupa); a IA generativa **cria conteúdo novo** a partir dos dados treinados (texto, código, documentos). Modelos **multimodais** geram além de texto — diagramas, imagens, áudio, vídeo.

## Conceitos principais

### O profissional vira orquestrador

A IA **amplia**, não substitui: você deixa de escrever tudo na mão (YAML, código) e passa a **orquestrar** a IA e **revisar** o que ela entrega. Analogia: a calculadora não substituiu o matemático. Ganham peso **pensamento crítico e arquitetura** sobre decorar sintaxe.

### Aplicações em Cloud/DevOps

| Área | Uso |
|---|---|
| Observabilidade/troubleshoot | Processar volumes de log, correlacionar eventos entre microserviços, analisar stack trace, gerar hipóteses de causa raiz, sumarizar incidentes → post-mortem (reduz MTTR) |
| Automação/CLI | Gerar `kubectl`/scripts; agentes conectados a serviços |
| IaC/arquitetura | Revisar Terraform/CloudFormation, documentar via engenharia reversa, avaliar custo e aderência ao **Well-Architected Framework**, gerar diagramas |
| Documentação | README, runbook, playbook, docs de API — o que ninguém gosta de fazer |

## Comandos e configurações

Aula conceitual.

## Pegadinhas

- IA generativa cria, mas você **valida** — ainda precisa pilotar e revisar.
- Modelos multimodais ampliam o que dá para gerar (diagramas, imagens).

## Dúvidas para revisar

- Quais tarefas de documentação/troubleshoot eu delego primeiro à IA generativa?
- Como estruturo a revisão humana do que a IA gera?
