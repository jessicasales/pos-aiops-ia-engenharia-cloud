# Primeira Skill — anatomia do SKILL.md

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 02 — Primeira Skill (24:58) |
| **Assunto** | Estrutura mínima de uma skill e as duas formas de disparo |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `SKILL.md` `frontmatter` `description` `gatilhos` `model-invoked` `user-invoked` `agentskills.io` `escopo` |

## Resumo da aula

Construção de uma skill simples (`gerar-commit`) para entender a **estrutura base**. Skill é um **padrão aberto** (especificação em [agentskills.io](https://agentskills.io)), então o mesmo `SKILL.md` funciona em várias ferramentas — cada uma só muda o diretório onde procura. Uma skill é só **uma pasta com um `SKILL.md` dentro**; scripts, references e assets são opcionais.

## Conceitos principais

### Escopos (igual ao MCP)
- **Projeto**: `.claude/skills/` no repositório → vai para o Git e a equipe toda usa.
- **Usuário**: `~/.claude/skills/` → disponível em todos os seus projetos (e ocupa contexto em todos).
- Nunca colocar **credenciais ou dados sensíveis** numa skill, principalmente se for distribuída.

### Onde cada ferramenta procura
```text
mesmo SKILL.md (name + description + corpo)
├─ Claude Code  → .claude/skills/
├─ Codex        → .agents/skills/
├─ Cursor       → .cursor/skills/   (+ lê .claude/skills/)
├─ OpenCode     → .opencode/skills/ (+ lê .claude/skills/)
└─ Antigravity  → .agents/skills/
```

### Anatomia
```text
.claude/skills/gerar-commit/
└── SKILL.md
    ├── frontmatter → name, description (obrigatórios)
    └── corpo       → os passos (o COMO)
```

### A `description` é a peça mais importante
Precisa ter:
1. **O que faz** (objetivo).
2. **Quando usar** (gatilhos/termos que disparam).
3. **Quando NÃO usar** (ex.: "nunca dispare ao pedir pull request, branch ou merge").

### Duas formas de disparo
- **Model-invoked (automático)**: o modelo decide carregar a skill pela semântica da description.
- **User-invoked (manual)**: você chama como comando `/gerar-commit`. É **determinístico**.

### Campos opcionais do frontmatter (spec)
| Campo | Uso |
|---|---|
| `name` | Minúsculas, números e hífens; respeitar limite de caracteres; igual ao nome da pasta |
| `description` | Máx. **1024 caracteres** |
| `license` | Licença da skill |
| `compatibility` | Ferramenta testada/alvo, dependências (Git, Docker...) |
| `metadata` | Versão, autor etc. |
| `allowed-tools` | Restringe as tools que a skill pode usar (sem ele, pode usar qualquer uma) |

## Comandos e configurações

```bash
mkdir -p .claude/skills/gerar-commit
```

```markdown
---
name: gerar-commit
description: Gera a mensagem de commit no padrão conventional commits a partir do diff em stage. Use ao pedir para commitar ou criar mensagem de commit.
---
# Gerar Commit

Ao gerar um commit:
1. Rode `git diff --staged` e leia as mudanças
2. Classifique o tipo: feat, fix, chore, docs, refactor
3. Monte a mensagem: `tipo: descrição curta no imperativo`
4. Mostre a mensagem e confirme antes de commitar
```

```text
/skills          # lista as skills carregadas (projeto + usuário)
/gerar-commit    # dispara manualmente
```

## Pegadinhas
- Na demo, "crie um commit" **não** disparou a skill; "crie uma mensagem de commit" disparou. A semântica da description decide o disparo.
- Se a skill não aparecer em `/skills`, feche e reabra a sessão — o frontmatter é lido na inicialização.
- **Não coloque README nem arquivo de licença dentro da pasta da skill**: o agente pode achar que fazem parte dela. Documente fora (num repositório de skills).
- Skill é agnóstica, mas o comportamento pode variar por ferramenta/modelo/system prompt — use `compatibility` quando fizer sentido.

## Dúvidas para revisar
- Testar a mesma skill no Claude Code e em outra ferramenta e comparar o disparo.
