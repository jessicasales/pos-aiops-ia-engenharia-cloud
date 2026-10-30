# Anatomia de um Agente: da Decisão à Implementação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Primeiros Agentes |
| **Aula** | 01 — Anatomia de um Agente: da Decisão à Implementação (07:27) |
| **Assunto** | Abertura do capítulo: os três níveis de maturidade de uso de IA (conversacional, assistido, autônomo), reforço da diferença workflow vs. agente, e os componentes que formam um agente |
| **Data** | 30/10/2026 00:45 |
| **Tags** | niveis-de-maturidade, agente-conversacional, agente-assistido, agente-autonomo, chatbot, cli, api, webhook |

## Resumo da aula

Aula de abertura do capítulo "Primeiros Agentes". Estabelece os **três níveis de maturidade** no uso de IA — conversacional, assistido, autônomo — posicionando o workflow (capítulo anterior) como um meio-termo entre o assistido e o autônomo, por ainda ter execução determinística. Reforça a diferença central já trabalhada (previsibilidade do fluxo) e introduz os componentes que compõem um agente de IA, além das diferentes formas de interação possíveis (chatbot, CLI, GUI, API, webhook).

## Conceitos principais

### Os três níveis de maturidade no uso de IA

1. **Conversacional/superficial**: interação direta com uma ferramenta de chat (ChatGPT, Claude.ai) — copiar e colar respostas manualmente. Sem acesso a recursos externos ou ao próprio ambiente do usuário.
2. **Assistido**: uso de agentes de codificação (Claude Code, Codex, Antigravity) com harness (skills, rules, MCP) — o usuário aciona o agente e acompanha/valida a execução. É o nível trabalhado nos módulos anteriores do curso.
3. **Autônomo**: um agente de IA executa todo o processo de decisão e ação sobre uma tarefa com intervenção humana mínima ou, dependendo da maturidade, zero. É o nível que a maioria dos profissionais de IA nunca chega a explorar — e o objetivo deste capítulo/módulo.

### Onde o workflow (capítulo anterior) se encaixa

O workflow conectado a LLM (Chaining, Routing, Paralelização) é um **meio-termo** entre assistido e autônomo: tem execução **determinística** — sabe-se onde começa, onde pode ir e onde termina — mesmo com decisões (routing) ou múltiplas perspectivas (paralelização) envolvidas. Não é ainda um agente porque falta a característica central do agente: **imprevisibilidade controlada**.

### A diferença central, reforçada: previsibilidade do fluxo

Workflow: fluxo determinístico, conhecido de antemão.
Agente: ao receber uma tarefa, não se sabe quantas etapas serão executadas, quantas vezes ele vai acessar um cluster Kubernetes ou um repositório, nem quantas ferramentas vai chamar. Há apenas uma **estimativa/expectativa** do comportamento, nunca uma garantia determinística — o que se pode fazer é dar direcionamento (harness) para obter um certo nível de controle e validação, sem eliminar a imprevisibilidade.

### Formas de interação com um agente

Um agente não é necessariamente só um chatbot — é uma solução de software conectada a um LLM, com autonomia de fluxo, que pode se comunicar por diferentes canais:
- **Chatbot** (conversacional, como ChatGPT/Claude.ai).
- **Linha de comando (CLI)**.
- **Interface gráfica (GUI)**.
- **API** e **webhook** — formas especialmente úteis para integrar múltiplos agentes de IA entre si e com outras aplicações.

### Componentes de um agente

Os mesmos componentes já vistos no harness assistido se repetem no agente autônomo:
- **Modelo** (LLM) — presente em todos os níveis.
- **System prompts** / comandos iniciais.
- **Loop de execução** (engenharia de loop) — o ciclo de decisão/ação/observação.
- **Conexão com ferramentas externas** — via MCP ou ferramentas específicas de um framework/ferramenta.
- **Contratos de comunicação** (API, chatbot, etc.) — conforme o canal de interação escolhido.

### Objetivo do capítulo

Introduzir os fundamentos e primeiros passos na construção de agentes de IA, navegando pelos diferentes componentes, para evoluir progressivamente até o conceito de **AIOps** (tema dos capítulos subsequentes do módulo).

## Comandos e configurações

Não há comandos nesta aula — é conteúdo conceitual de abertura do capítulo.

## Pegadinhas

- Confundir "ter imprevisibilidade controlada por direcionamento (harness)" com "ter controle total do fluxo" — mesmo com harness bem construído, um agente nunca tem a mesma previsibilidade de um workflow determinístico.
- Achar que agente = chatbot é uma simplificação equivocada — a forma de interação (CLI, API, webhook, GUI) é independente da autonomia do agente.

## Dúvidas para revisar

- Quais formas de interação (CLI, API, webhook) serão exploradas na prática nas próximas aulas deste capítulo?
- Como o loop de execução de um agente autônomo construído com LangChain se compara, na prática, ao loop ReAct já estudado com Claude Code/Codex?
- Em que momento do capítulo o conceito de AIOps será formalmente introduzido, conectando tudo que foi visto até aqui?
