# Codex CLI na Prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Fundamentos |
| **Aula** | 05 — Codex (07:29) |
| **Assunto** | Instalação, autenticação e primeira execução do Codex CLI (OpenAI) |
| **Data** | 29/10/2026 19:14 |
| **Tags** | `codex` `openai` `gpt` `wsl` `terminal` `tarefa-âncora` |

## Resumo da aula

Segunda ferramenta da comparação: **Codex**, da OpenAI — o "Claude Code da OpenAI", usando modelos GPT. Tem versão desktop e CLI; a aula foca no CLI.

## Conceitos principais

### Desktop × CLI
- **Codex Desktop não tem versão para Linux.**
- No Windows, ao abrir uma pasta do **WSL**, o Codex Desktop acessa via sistema de arquivos do **Windows** — toda execução roda em ambiente Windows, exigindo setup (Python, Go, Node...) lá, mesmo trabalhando "no WSL".
- Quem usa Cloud/DevOps no dia a dia (geralmente WSL, Linux ou macOS) deve preferir o **Codex CLI**.
- macOS funciona bem em ambas as versões.

### Planos
- Tem camada **gratuita**, mas com acesso limitado.
- Planos pagos: **Go** (R$39,99), **Plus** (R$99,90/mês), **Pro** (R$525... — valor citado na aula).
- Recomendação: se já tem assinatura de outra ferramenta (ex. Claude Code), testar o Codex na camada gratuita antes de assinar.

### Autenticação e uso
- Login via navegador (copiar link → autenticar → confirmar).
- Comandos com `/` parecidos com o Claude Code: seleção de modelo, nível de raciocínio, `status` (uso de tokens/janela de contexto da sessão), compactar contexto, review de código, detalhes do plano.

### Diferenças observadas na execução da tarefa-âncora
- O Codex mostrou as etapas de forma diferente do Claude Code: rodou validação de sintaxe, listou o arquivo de novo, leu o arquivo, rodou `chmod` — label das ações (`Explore`, etc.) diferente, nem sempre mostra explicitamente quando usou `write`.
- Conclusão do professor: **o conceito (loop + tools) é o mesmo entre ferramentas terminal-native** — só muda a "casca"/comunicação de progresso.

## Links
- Site oficial: https://developers.openai.com/codex/cli/
- Preços: https://developers.openai.com/codex/pricing

## Pegadinhas
- No Windows+WSL, confirme em qual ambiente (Windows ou WSL) o Codex Desktop está realmente executando antes de instalar dependências.
- De novo, o script gerado não foi testado/validado na aula.

## Dúvidas para revisar
- Testar o Codex CLI como alternativa quando o Claude Code estiver indisponível.
