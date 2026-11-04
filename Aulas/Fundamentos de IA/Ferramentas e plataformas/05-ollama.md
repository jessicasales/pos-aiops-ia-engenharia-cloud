# Ollama (modelos locais)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | Ferramentas e plataformas |
| **Aula** | 05 — Ollama (09:37) |
| **Assunto** | Rodar modelos (SLMs) localmente; GUI, CLI, API REST, Ollama Cloud e integração com agentes |
| **Data** | 04/11/2026 00:45 |
| **Tags** | ollama, local, slm, gpu, ollama-cloud, api-rest, modelos-open-source |

## Resumo da aula

O **Ollama** roda modelos de IA **localmente** com uma linha de comando — "o Docker dos modelos". Windows/Mac/Linux. Ideal para **SLMs** e modelos open source (Gemma, Llama, Qwen, DeepSeek, CodeGemma...).

## Conceitos principais

- Formas de uso: **GUI** (interface web tipo chat), **CLI** (`ollama run <modelo> "<pergunta>"`), **API REST** (porta padrão 11434).
- **Consumo de recurso**: rodar local consome **GPU, RAM e armazenamento** (ex.: Gemma 4B picou ~93% de GPU; cada modelo ocupa ~GBs). Precisa de máquina que aguente.
- **Ollama Cloud**: roda os modelos na nuvem quando você não tem hardware (tem camada gratuita e paga).
- **Integração com agentes**: Claude Code, Gemini CLI, Codex podem usar modelos do Ollama (`ollama launch cloud` inicia o Claude Code com o modelo mapeado).

## Comandos e configurações

<details>
<summary>Uso básico</summary>

```bash
ollama run gemma3 "o que é Python"
ollama run codegemma "Crie um script em Python para criar uma VM na AWS"
# API REST na porta 11434
```

</details>

## Pegadinhas

- Modelo local consome recurso computacional de verdade — avalie se vale a pena.
- Sem GPU/recurso, use Ollama Cloud.

## Dúvidas para revisar

- Minha máquina aguenta qual tamanho de SLM local?
- Vale rodar um agente de codificação com modelo local por privacidade?
