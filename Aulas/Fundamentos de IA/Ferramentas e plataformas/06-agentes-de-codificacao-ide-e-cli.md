# Agentes de Codificação — IDE e CLI

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | Ferramentas e plataformas |
| **Aula** | 06 — Agentes de Codificação - IDE e CLI (22:30) |
| **Assunto** | Panorama dos agentes de codificação em IDE e em CLI |
| **Data** | 04/11/2026 00:45 |
| **Tags** | agentes-de-codificacao, ide, cli, claude-code, cursor, kiro, gemini-cli, copilot, opencode |

## Resumo da aula

Agentes de codificação são assistentes no desenvolvimento — e vão **além de código**: fluxo DevOps, Cloud, SRE, validação de documentos, conteúdo. Dividem-se em **IDE** (experiência visual) e **CLI** (terminal).

## Conceitos principais

### IDE (editor integrado)

| Ferramenta | Notas |
|---|---|
| **GitHub Copilot** | Popularizou o autocomplete + chat; integra em VS Code, Visual Studio, JetBrains, etc. Planos: Free (limitado, Haiku/GPT-5 mini), Pro (~US$10/mês, modelos melhores, 300 premium requests), Pro+ (~US$40, 5x mais) |
| **Cursor** | Fork do VS Code; hoje o mais popular. Free, Pro (~US$20), Pro+, Ultra (~US$200), Business |
| **Kiro** | Fork do VS Code (hoje AWS); pioneiro no **modo de planejamento** (spec: requirements/design/tasks). Planos Free/Pro/Pro+/Power |
| **Codex** | OpenAI (via assinatura ChatGPT Plus+) |
| **Google Anti-Gravity** | Fork do VS Code; abre direto no modo agente; planejamento + teste com Chrome integrado |

### CLI (terminal) — destaque em DevOps/Cloud

| Ferramenta | Notas |
|---|---|
| **Claude Code** | Anthropic; hoje o principal. Via assinatura Claude (Pro/Max); sem camada gratuita |
| **GitHub Copilot CLI** | Mesma conta da IDE |
| **Gemini CLI** | Google, open source (Node); boa camada gratuita, janela de 1M tokens |
| **OpenCode** | Comunidade, open source; usa **vários modelos** (Claude, GPT, Gemini, conta GitHub) |
| **Kiro CLI** | Via assinatura Kiro (substituiu o Amazon Q CLI) |

### Tendência

Combinar **IDE + terminal integrado** (extensões de Claude Code/OpenCode/Gemini CLI no VS Code). O instrutor usa ~90% CLI por flexibilidade em múltiplos arquivos/projetos e automação.

## Pegadinhas

- Planos gratuitos dão modelos de entrada (Haiku/mini) — não é o potencial real.
- Claude Code não tem free; começa no Pro.

## Dúvidas para revisar

- IDE ou CLI para o meu fluxo de DevOps/Cloud?
- Qual combinação de ferramentas montar (ex.: Cursor + Claude Code)?
