# Por dentro do agente — peças, ferramentas e modos de execução

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Fundamentos |
| **Aula** | 02 — Por dentro do agente (21:59) |
| **Assunto** | Modelo, tools, loop e contexto; ferramentas universais; modos (plan, subagente); critérios para escolher ferramenta |
| **Data** | 29/10/2026 19:14 |
| **Tags** | `tools` `read` `write` `edit` `bash` `grep` `glob` `loop react` `plan mode` `subagente` `terminal` `ide` |

## Resumo da aula

Antes da prática, a aula abre o "capô" do agente: quais peças o compõem, como ele escolhe ferramentas, os modos de execução disponíveis (plan, subagente) e os critérios para escolher entre as ferramentas do mercado (terminal × IDE).

## Conceitos principais

### As quatro peças de um agente de codificação
| Peça | Papel |
|---|---|
| **Modelo (LLM)** | O "cérebro" — recebe input, gera output |
| **Ferramentas (tools)** | As "mãos" — interação com o mundo real (ler, escrever, executar) |
| **Loop de execução** | Ciclo no padrão **ReAct**: observar a tarefa → verificar insumos → raciocinar → agir com tools → observar de novo |
| **Contexto** | Informação/dados passados ao modelo — determina custo e qualidade do resultado |

Faltando qualquer uma dessas quatro peças, não é um agente completo — é algo "capado".

### Núcleo universal de ferramentas
| Ferramenta | Função | Observação |
|---|---|---|
| **Read** | Ler arquivos, alimentar contexto | Ler tudo de uma vez encarece e pode causar alucinação |
| **Write** | Criar arquivo novo do zero | Mais caro que editar |
| **Edit** | Alterar linhas pontuais | **Mais barato** que write — prefira quando a mudança é pequena |
| **Bash** | Executar linha de comando (kubectl, ls, PowerShell...) | |

### Núcleo quase universal (nem toda ferramenta tem)
| Ferramenta | Função |
|---|---|
| **Grep** | Buscar conteúdo dentro de arquivos (agnóstico a SO; o Bash com grep faz o mesmo em Linux) |
| **Glob** | Buscar arquivos por padrão (ex.: todos os `.tf`, todos os `.json`) |
| **Pesquisa web** | A que mais impacta quando ausente — normalmente paga como serviço externo quando não embutida |

### Quem decide usar qual ferramenta
**O modelo**, via loop de raciocínio — não há controle determinístico sobre isso. Quando o agente erra na execução, o problema geralmente é falta de contexto/clareza no pedido, não a ferramenta em si. Prompt vago ("melhora esse código") gera uso ruim de ferramentas; prompt com **alvo definido, contexto e informação do ambiente** faz o agente mapear melhor o que precisa.

### Modos de execução
| Modo | O que faz |
|---|---|
| **Plan (planejamento)** | O agente não escreve nada — levanta insumos (arquivos, docs existentes) e monta um plano de execução. É a implementação prática do conceito de **Scratchpad** da engenharia de contexto (arquivo de planejamento fora da janela de contexto, persistente entre sessões) |
| **Subagente** | Delega parte da tarefa para um contexto isolado — cria-se uma "persona" de subagente |
| **Comandos customizáveis** | Comandos próprios para iniciar tarefas específicas, além dos padrão da ferramenta |

### Terminal × IDE
- **Terminal-first:** Claude Code, Codex.
- **Híbrido/IDE:** VS Code + extensões, Google Antigravity (CLI + IDE), Kiro.
- O que muda é "a casca" — o fluxo de trabalho (loop + tools) é o mesmo.

### Critérios para escolher a ferramenta
1. **Custo** — assinatura, token, plano, o que cabe no orçamento.
2. **Preferência de uso** — terminal × editor.
3. **Integração** — pipeline CI/CD, execução remota em cloud.
4. **Uso dos dados/compliance** — o código enviado é usado para treinar a ferramenta? Essencial alinhar com a política da empresa antes de usar IA no trabalho — "falha muito comum de quem está começando".
5. **Modelo** — ferramentas agnósticas (múltiplos modelos, ex. OpenCode, Cursor) × ferramentas presas a um provedor (ex. Claude Code só modelos Anthropic).

## Pegadinhas
- Não decore os detalhes de cada ferramenta — "não é receita de bolo"; consulte a documentação e vá pegando prática.
- Em projeto de empresa, **sempre confirme a política de uso de IA/compliance** antes de colar código real.

## Dúvidas para revisar
- Checar com a equipe/DPMG qual é a política de uso de ferramentas de IA e dados sensíveis.
