# Commands — transformando prompts reutilizáveis em comandos

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 11 — Commands (10:29) |
| **Assunto** | Criar comandos customizados (ex. `/docs/brainstorm`) para não copiar e colar prompts repetidamente |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `commands` `claude-code` `arguments` `frontmatter` `escopo` `harness` |

## Resumo da aula

Até aqui os prompts de brainstorm/PRD/ADR/TRD foram usados via copiar-e-colar. Isso não escala para vários projetos nem para compartilhar com a equipe. Solução: o recurso de **comandos (commands)**, presente em praticamente todas as ferramentas de agente de codificação — já visto via `/` no Claude Code, OpenCode etc.

## Conceitos principais

### O que é um comando
Um comando é um **prompt salvo em arquivo**, chamado por nome em vez de colado inteiro. No Claude Code: pasta `.claude/commands/`, arquivos `.md` com o conteúdo do prompt.

```bash
.claude/commands/docs-brainstorm.md    # conteúdo = o prompt de brainstorm
```
Uso: `/docs-brainstorm` no lugar de colar o prompt inteiro.

### Argumento dinâmico (`$ARGUMENTS`)
Adicionar `$ARGUMENTS` no corpo do arquivo de comando permite passar texto extra na chamada:
```text
/brainstorm quero definir para a aplicação uma feature de uso com S3
```
O texto após o nome do comando é injetado onde `$ARGUMENTS` aparece no prompt salvo.

### Subpastas para organizar
```text
.claude/commands/docs/prd.md   →  /docs:prd (ou /docs prd, dependendo da ferramenta)
```
Permite agrupar comandos por categoria (ex. `docs/`).

### Frontmatter do comando
```yaml
---
name: Criação PRD
description: Comando de criação de PRDs
---
```
Melhora a listagem/descrição do comando quando exibido no menu `/`.

### Escopo (igual ao MCP)
| Escopo | Onde |
|---|---|
| Usuário/global | `~/.claude/commands/` |
| Projeto | `.claude/commands/` no repositório |
| Local | Variante não compartilhada (depende da ferramenta) |

### Cada ferramenta tem sua pasta própria
| Ferramenta | Pasta de comandos |
|---|---|
| Claude Code | `.claude/commands/` |
| OpenCode | `.opencode/commands/` |
| Cursor | `.cursor/commands/` |

O recurso é praticamente universal — só muda o formato/local do arquivo; consulte a documentação de cada ferramenta.

## Pegadinhas
- O nome do arquivo deve coincidir com o nome usado para chamar o comando — siga o padrão de cada ferramenta.
- Reiniciar a sessão (fechar/abrir) costuma ser necessário para o comando novo aparecer na listagem.

## Dúvidas para revisar
- Transformar os prompts de brainstorm, PRD, TRD e ADR usados nas aulas anteriores em comandos reais no meu projeto, organizados em `docs/`.
