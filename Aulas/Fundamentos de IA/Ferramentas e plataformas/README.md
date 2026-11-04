# Ferramentas e plataformas — Fundamentos de IA

Anotações do capítulo **Ferramentas e plataformas** do módulo **Fundamentos de IA** (curso Pós AIOps e IA na Engenharia de Cloud).

Panorama prático das formas de consumir IA: providers (OpenAI, Anthropic, Google), modelos locais (Ollama), agentes de codificação (IDE/CLI) e os serviços de IA dos três clouds.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 02:57 | Panorama e dica de testar antes de assinar |
| 02 | [OpenAI](02-openai.md) | 16:14 | ChatGPT vs. plataforma; playground, API |
| 03 | [Anthropic](03-anthropic.md) | 15:38 | Claude.ai, console, Claude Code |
| 04 | [Google AI Studio](04-google-ai-studio.md) | 11:35 | Gemini, AI Studio, camada gratuita |
| 05 | [Ollama](05-ollama.md) | 09:37 | Modelos locais (SLMs), GUI/CLI/API |
| 06 | [Agentes de Codificação - IDE e CLI](06-agentes-de-codificacao-ide-e-cli.md) | 22:30 | Copilot, Cursor, Kiro, Claude Code, Gemini CLI... |
| 07 | [AWS Bedrock](07-aws-bedrock.md) | 09:58 | Bedrock + Amazon Q |
| 08 | [Azure Foundry](08-azure-foundry.md) | 09:05 | Microsoft Foundry |
| 09 | [GCP Vertex AI](09-gcp-vertex-ai.md) | 06:11 | Vertex AI (corporativo) |
| 10 | [Formas de Serviço de IA](10-formas-de-servico-de-ia.md) | 04:29 | IaaS/PaaS/SaaS aplicado à IA |

## Resumo rápido

- **Providers**: OpenAI (GPT), Anthropic (Claude), Google (Gemini) — cada um com chat + console/playground + API (por token).
- **Local**: Ollama roda SLMs/open source (consome GPU/RAM); tem Ollama Cloud.
- **Agentes de codificação**: IDE (Copilot, Cursor, Kiro, Anti-Gravity) e CLI (Claude Code, Gemini CLI, OpenCode, Kiro CLI). Tendência: IDE + terminal integrado.
- **Clouds**: AWS Bedrock (+ Amazon Q), Azure Foundry, GCP Vertex AI — catálogo de modelos + playground; cuidado com custo (apague recursos).
- **Formas de serviço**: API (IaaS, controle total) → agente (PaaS) → serviço pronto (SaaS). Escolha por requisito/custo.
