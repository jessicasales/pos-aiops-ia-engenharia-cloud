# OpenCode na Prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Fundamentos |
| **Aula** | 06 — OpenCode (07:32) |
| **Assunto** | Ferramenta open source e agnóstica de provedor/modelo |
| **Data** | 29/10/2026 19:14 |
| **Tags** | `opencode` `open-source` `agnóstico` `opencode-zen` `ollama` `node.js` `terminal` `tarefa-âncora` |

## Resumo da aula

Terceira ferramenta: **OpenCode**, diferente das anteriores por ser **open source**, instalável gratuitamente e compatível com **diversos provedores e modelos** (não amarrado a uma empresa de IA).

## Conceitos principais

### Requisitos e plataformas
- Único pré-requisito: **Node.js** instalado.
- Funciona em Mac, Windows e Linux. É voltada para linha de comando, mas também tem interface web (`opencode web` — não é a forma mais usada pelo professor).

### Provedores e modelos
- Dá para rodar localmente com **Ollama** (Llama), mas exige hardware forte — não recomendado para a maioria ("experiência ruim" sem isso).
- Suporta: Amazon Bedrock, Anthropic (⚠️ o professor alerta que a **Anthropic está banindo contas que usam esse caminho** — atenção), GitHub Copilot, Vertex AI, OpenAI, entre outros.
- **OpenCode Zen**: gateway curado de modelos do próprio OpenCode (Kimi, MiniMax, Qwen, atualizado continuamente). Assinatura: **US$5 no primeiro mês, US$10 nos seguintes**. É o que o professor mais usa com o OpenCode.

### Conectar um provedor
```text
/connect              # conectar um provider
```
Fluxo: gerar chave de API no provedor escolhido (ex. Google AI Studio) → `/connect` → colar a chave → selecionar o modelo (ex. Kimi).

### Interface
- Mostra quantidade de contexto usado, tokens e custo da sessão em tempo real — recurso elogiado pelo professor.
- Pedido de permissão para `write` igual às outras ferramentas (`allow always`).
- Execução da tarefa-âncora mostrou claramente as chamadas a `Write` e `Read`.

## Links
- Site oficial: https://opencode.ai
- Preços / gateway de modelos: https://opencode.ai/zen

## Pegadinhas
- Rodar modelo local (Ollama) sem hardware adequado traz má experiência — evite, salvo se seu hardware aguenta.
- Cuidado ao conectar a Anthropic como provedor dentro do OpenCode — risco de banimento da conta segundo o professor.
- Não é a ferramenta principal do professor, mas é o backup quando o Claude Code está indisponível.

## Dúvidas para revisar
- Avaliar o OpenCode Zen como alternativa de backup barata.
