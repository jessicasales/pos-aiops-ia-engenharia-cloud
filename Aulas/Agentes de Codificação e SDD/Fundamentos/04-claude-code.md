# Claude Code na Prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Fundamentos |
| **Aula** | 04 — Claude Code (12:30) |
| **Assunto** | Instalação, autenticação, primeira execução e comandos básicos do Claude Code |
| **Data** | 29/10/2026 19:14 |
| **Tags** | `claude-code` `anthropic` `assinatura` `autenticação` `terminal` `aws-cli` `tarefa-âncora` |

## Resumo da aula

Primeira de quatro aulas que rodam a **mesma tarefa-âncora** (provisionar rede + EC2 na AWS via Bash/AWS CLI) em ferramentas diferentes, para comparar diretamente. Aqui: Claude Code, da Anthropic, ferramenta baseada em terminal (com extensão para VS Code), multi-SO (Mac, Linux, Windows).

## Conceitos principais

### Planos e autenticação
- **Sem camada gratuita** para o Claude Code — precisa de assinatura a partir do **Pro**.
- Planos do Claude: Free (só Claude.ai web/iOS), **Pro** (US$17/mês anual ou US$20/mês mensal, dá acesso ao Claude Code), **Max** (5x e 20x).
- Três formas de autenticar: assinatura, API da Anthropic (console, chave de API), ou provedores terceiros (Amazon Bedrock, Microsoft Foundry, Vertex AI).
- **Recomendação do professor: usar a assinatura**, não a API — com API o custo varia por token ("taxímetro ligado", sem previsibilidade); com assinatura o valor é fixo e, ao esgotar o limite, trava até o próximo ciclo.

### Primeiros passos
```text
claude          # inicia o Claude Code no diretório atual
claude --help   # ver se está instalado / ajuda
```
No primeiro uso: escolha de tema (Dark/Light, variações de cor) e fluxo de autenticação via navegador (copiar link, autorizar, colar token).

### Comandos úteis (`/`)
| Comando | Função |
|---|---|
| `/clear` | Limpa a sessão / janela de contexto — um dos mais usados |
| `/model` | Troca o modelo em uso (ex.: Opus ↔ Sonnet 4.6) |
| `/compact` | Compacta/resume a janela de contexto |
| `/plan` | Entra em modo de planejamento |
| (diff) | Mostra o que mudou na sessão atual |
| (code review) | Revisão de código baseada nas alterações feitas |
| MCP, Skills | Mencionados — aprofundados em aulas futuras |

## Prompt da aula (tarefa-âncora, usada em todas as ferramentas)

```text
Crie um shell script em Bash que provisione, via AWS CLI, toda a infraestrutura de
rede necessária para executar uma instância EC2 em uma VPC nova na AWS.

## Objetivo
O script deve criar, do zero, todos os componentes necessários para que uma EC2
fique acessível via SSH a partir da internet, dentro de uma subnet pública.

## Recursos a serem criados (nesta ordem de dependência)
1. VPC com bloco CIDR configurável (default: 10.0.0.0/16) e DNS hostnames habilitado
2. Internet Gateway e attachment na VPC
3. Subnet pública com bloco CIDR configurável (default: 10.0.1.0/24) em uma AZ
4. Route Table com rota 0.0.0.0/0 apontando para o Internet Gateway + associação à subnet
5. Habilitar map-public-ip-on-launch na subnet
6. Security Group permitindo:
   - SSH (porta 22) apenas a partir do IP público de quem executa o script (descoberto dinamicamente)
   - HTTP (porta 80) de qualquer origem (0.0.0.0/0)
7. Key Pair (criar e salvar a chave privada localmente com permissão 400, caso ainda não exista)
8. Instância EC2 usando os recursos acima
```

Na execução, o Claude Code usou **Write** (criar o shell script, pedindo permissão na primeira vez — dá para "permitir a edição por toda a sessão") e **Bash** (dar permissão de execução `chmod`).

## Links
- Site oficial: https://claude.com/claude-code
- Preços: https://claude.com/pricing

## Pegadinhas
- O script gerado **não foi validado nem testado** na aula — é só para mostrar o comportamento do agente.
- Assinatura × API: escolha pensando em previsibilidade de custo, não só preço nominal.

## Dúvidas para revisar
- Comparar o resultado desta tarefa-âncora com o de Codex, OpenCode e Cursor (aulas seguintes).
