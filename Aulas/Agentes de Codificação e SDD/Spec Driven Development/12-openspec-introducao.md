# OpenSpec Introdução — Setup, Estrutura e Capabilities

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 12 — OpenSpec Introdução (19:35) |
| **Assunto** | Instalar e inicializar o OpenSpec; entender changes, specs, archive, capability, requirement, scenario |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `openspec` `spec-driven-development` `capability` `requirement` `scenario` `spec-delta` `brownfield` |

## Resumo da aula

Com PRD, TRD, ADR e comandos prontos, falta o **fluxo de construção** — os três pilares do SDD (spec, plano, tasks), agora numa forma que a IA consome diretamente, não só leitura humana. Em vez de montar esse framework do zero, a aula adota o **OpenSpec**.

## Conceitos principais

### Frameworks de SDD existentes (panorama)
| Framework | Observação do professor |
|---|---|
| **GitHub Spec Kit** | Open source, Python, muito bom mas **verboso/engessado** para quem está aprendendo ou trabalha com projetos não-novos |
| **Kiro** (AWS) | Uma das primeiras ferramentas a embutir SDD nativamente |
| **BMAD** | Pensado para múltiplos times |
| **Tessl** | Modelo Spec as Source — registro de specs de bibliotecas |
| **OpenSpec** | O escolhido para o curso |

Recomendação: teste outros também para formar opinião própria — o professor é transparente que GitHub Spec Kit e Kiro não "encaixaram" no seu fluxo, mas isso é preferência pessoal.

### Por que OpenSpec
- **Minimalista**, pouca cerimônia, não engessa a implementação.
- Modelo baseado em **specs + capabilities + delta**: tudo que é implementado e depois arquivado atualiza a especificação declarada, permitindo comparar implementado × mapeado.
- **Não reescreve nada do projeto** — adiciona SDD de forma incremental. Ideal para **brownfield** (projeto já em andamento), como o caso do curso.
- Agnóstico de ferramenta: funciona com Claude Code, Antigravity, Codex, Cursor, OpenCode e mais.

### Instalação e inicialização
```bash
npm install -g @fission-ai/openspec@latest
openspec --version
openspec init     # roda na raiz do projeto já existente (brownfield)
```
`openspec init` pergunta quais ferramentas de codificação usar (marcar várias é possível) e já integra: cria `.claude/commands/` e `.claude/skills/` (e equivalentes para outras ferramentas — `.agent/`, `.opencode/`, `.cursor/`) com os comandos do ciclo: **explore, propose, apply, sync, archive**.

### Comandos de inspeção (read-only, não alteram nada)
```bash
openspec --help     # leque de comandos
openspec list        # changes e specs (vazio logo após o init)
openspec view         # dashboard interativo
openspec config        # ler/ajustar config.yaml
```

### As três estruturas de arquivo que o OpenSpec cria
| Pasta | Papel |
|---|---|
| `changes/` | **Propostas de mudança** — cada feature/modificação gera uma change, com seus próprios arquivos (spec, plano, tasks) |
| `specs/` | **Fonte de verdade consolidada** do projeto — o estado sincronizado após uma change ser aplicada |
| `archive/` | **Histórico** de changes já implementadas e arquivadas |

Fluxo: criar spec/plan/tasks de uma change → implementar → **sincronizar** (fecha a change, atualiza as specs) → **arquivar**.

### Vocabulário central
| Termo | Significado |
|---|---|
| **Capability** | Área coerente de funcionalidade — "modelo de domínio" (ex.: `auth/`, `payments/`, `infra/`) |
| **Requirement** | O que aquela capability precisa garantir — o estado que o OpenSpec deve manter |
| **Scenario** | Caso concreto em **Given/When/Then** — o que torna o requirement verificável |
| **Spec Delta** | Uma change descreve **o que muda**, não reescreve a spec inteira — operações: `ADDED`, `MODIFIED`, `REMOVED` |

"A spec não é um documento gigante: ela é organizada por área."

## Pegadinhas
- Esta aula é só setup — **nenhuma change é criada ainda**; `openspec list` sai vazio de propósito, como prova de que a inicialização não alterou nada do projeto.
- O OpenSpec adiciona arquivos/estrutura ao projeto, mas não mexe no código existente.

## Dúvidas para revisar
- Instalar e inicializar o OpenSpec num projeto real para ver a integração com minha ferramenta de codificação preferida.
