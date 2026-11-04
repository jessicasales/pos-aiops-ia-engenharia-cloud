# Engenharia de contexto — Engenharia de Prompt e Contexto

Anotações do capítulo **Engenharia de contexto** do módulo **Engenharia de Prompt e Contexto** (curso Pós AIOps e IA na Engenharia de Cloud).

Engenharia de prompt resolve a **instrução**; engenharia de contexto resolve a **informação** — a certa, na quantidade certa, no momento certo. Como os modelos são **stateless**, tudo o que precisa sobreviver à sessão tem que ser gerenciado por estes componentes.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 11:03 | Contexto engloba prompt; stateless; componentes |
| 02 | [Janela de Contexto](02-janela-de-contexto.md) | 15:51 | Memória de curto prazo; tokens, lost in the middle, 4 fails |
| 03 | [Memória de Longo Prazo](03-memoria-de-longo-prazo.md) | 17:34 | Persistência entre sessões; escopos e tipos |
| 04 | [Scratchpad](04-scratchpad.md) | 08:29 | Rascunho/plano fora da janela |
| 05 | [State](05-state.md) | 13:15 | Progresso real (to-do list) |
| 06 | [Tools](06-tools.md) | 10:40 | Ponte com o mundo externo; curadoria de output |
| 07 | [RAG](07-rag.md) | 17:43 | Recuperar e injetar; lexical/metadados/semântica |
| 08 | [Compactação](08-compactacao.md) | 10:35 | Sumarização, trim, slice (com perda) |
| 09 | [System Prompt](09-system-prompt.md) | 06:47 | Persona, objetivo, escopo, restrições, formato, fallback |
| 10 | [Subagentes](10-subagentes.md) | 10:31 | Agentes especializados, janela isolada, paralelismo |
| 11 | [Sandbox](11-sandbox.md) | 04:54 | Ambiente isolado de execução de código |
| 12 | [Finalizando](12-finalizando.md) | 05:54 | Apanhado geral e ligação com próximos módulos |
| 13 | [Repositório de Projetos](13-repositorio-de-projetos.md) | link | Projetos de exemplo do capítulo |

## Mapa dos componentes (em torno da janela de contexto)

| Grupo | Componentes | Papel |
|---|---|---|
| Memória/armazenamento | Memória de longo prazo, Scratchpad, State | Persistir; plano; progresso |
| Janela | Compactação (sumário/trim/slice) | Reduzir a janela |
| Acesso externo | Tools, RAG | Mundo externo; conhecimento |
| Isolamento | Subagentes, Sandbox | Isolar contexto/persona; isolar execução |

## Os 4 context fails (e mitigações)

| Fail | Mitigação |
|---|---|
| Poisoning (dado errado) | curadoria; sandbox; State como ponto de verdade |
| Distraction (janela inchada) | Scratchpad, compactação, subagentes |
| Confusion (detalhe com peso demais) | gerenciar contexto |
| Clash (instruções conflitantes) | evitar contradições |

> Ligação com os próximos módulos: multiagente → subagentes do Claude Code; memória → `CLAUDE.md`; RAG/Tools → MCPs; ambiente → sandbox. É a base para Harness Engineering e agentes autônomos.
