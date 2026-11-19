# OpenAI

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Fundamentos de IA |
| **Capítulo** | Ferramentas e plataformas |
| **Aula** | 02 — Open AI (16:14) |
| **Assunto** | ChatGPT (produto) vs. plataforma de desenvolvimento; playground, API e precificação |
| **Data** | 04/11/2026 00:45 |
| **Tags** | openai, chatgpt, playground, api, token, precificacao, codex |

## Resumo da aula

A OpenAII popularizou a IA generativa com o **ChatGPT**. Além do chat (multimodal), há a **plataforma de desenvolvimento** (`platform.openai.com`) com playground, API e gerenciamento.

## Conceitos principais

- **ChatGPT** (`chatgpt.com`): produto de chat. **Plataforma** (`platform.openai.com`): desenvolvimento, chaves de API, limites de orçamento, playground.
- **Playground**: escolher modelo, comparar modelos lado a lado, ajustar temperatura/top-p/max tokens, definir system prompt. Útil para testar/otimizar prompts.
- **API**: consumir modelos via código (Python, JS, C#...). Na pós usa-se **LangChain** para abstrair e ser agnóstico.

### Precificação

| Modelo | Assinatura (ChatGPT) | API (por token) |
|---|---|---|
| — | Free, Go, Plus, Pro | cobrança por milhão de tokens |

Ex.: GPT-5.2 ~US$1,75/milhão input, US$14/milhão output (output mais caro). Modelos mini/nano são bem mais baratos e atendem muitos casos. O instrutor assina o **Plus** (dá acesso ao **Codex**). Configure **alertas/limites** de orçamento.

## Pegadinhas

- Não é obrigatório assinar o ChatGPT para os labs — basta ter acesso a um modelo.
- Output pesa muito mais que input no custo.

## Dúvidas para revisar

- Uso o playground para comparar mini/nano antes de escolher o modelo?
