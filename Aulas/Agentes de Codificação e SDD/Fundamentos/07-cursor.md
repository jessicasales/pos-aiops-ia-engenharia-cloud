# Cursor na Prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Fundamentos |
| **Aula** | 07 — Cursor (06:03) |
| **Assunto** | A primeira ferramenta IDE-first da comparação: agente dentro do editor |
| **Data** | 29/10/2026 19:14 |
| **Tags** | `cursor` `ide` `agent-mode` `vs-code-fork` `composer` `wsl` `tarefa-âncora` |

## Resumo da aula

Quarta e última ferramenta da tarefa-âncora: **Cursor**, uma **IDE completa** com agente embutido (não terminal-first como as anteriores). Nasceu como fork do VS Code, hoje é construída do zero e funciona com múltiplos modelos.

## Conceitos principais

### Perfil da ferramenta
- Na opinião do professor, **superou o GitHub Copilot** em uso e popularidade, e é "muito superior" a ele.
- Tem camada gratuita, mas **extremamente limitada** — pode dar a falsa impressão de que a ferramenta é ruim. Recomendação: usar versão paga para avaliar de verdade.
- Disponível para Mac, Windows e Linux. No WSL, é importante instalar a **extensão WSL** para funcionar corretamente.

### Modos de agente
| Modo | Uso |
|---|---|
| Planejamento | Igual ao plan mode já visto no Claude Code |
| Debug | Trabalha com um system prompt e funcionalidades voltadas a depuração |
| Multitarefa | — |
| Ask | Perguntar sobre o projeto/codebase sem necessariamente codificar — modo de navegação/descoberta, só leitura |

### Interação
- Painel de agente ao lado do editor — o professor recomenda **monitor ultrawide** para acompanhar navegação de arquivos e chat ao mesmo tempo.
- Suporta **entrada por voz**.
- Permite adicionar arquivos ao contexto manualmente.
- Escolha de modelo: automático ou manual (professor prefere escolher manualmente); **Composer** é o modelo próprio do Cursor.

### Execução da tarefa-âncora
- Precisa estar no modo **Agent** (não "Ask") para executar, não só responder.
- Foi a execução **mais rápida** das quatro ferramentas comparadas no capítulo.
- Interface mostra o diff para revisão antes de aceitar as mudanças.
- Conclusão: muda a interface/UX (IDE vs. terminal), o conceito de fundo (loop + tools) é o mesmo.

## Links
- Site oficial: https://cursor.com
- Preços: https://cursor.com/pricing (planos Pro, Pro+, Ultra; uso de modelos de fronteira incluído conforme plano)

## Pegadinhas
- Não avalie o Cursor pela camada gratuita — é limitada demais para representar a experiência real.
- Confirme o modo ativo (Agent × Ask) antes de colar um prompt que espera execução.

## Dúvidas para revisar
- Comparar minha experiência real usando Cursor Pro vs. a camada gratuita.
- Revisar as quatro execuções da tarefa-âncora lado a lado (Claude Code, Codex, OpenCode, Cursor) e anotar as diferenças de script gerado.
