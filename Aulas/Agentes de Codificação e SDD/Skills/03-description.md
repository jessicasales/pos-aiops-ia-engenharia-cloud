# Description — o roteador da skill

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 03 — Description (14:09) |
| **Assunto** | Como a description decide qual skill é carregada |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `description` `gatilhos` `roteamento` `frontmatter` `janela de contexto` `/context` `disparo determinístico` |

## Resumo da aula

A **description** é tão importante quanto o corpo da skill: é ela que faz o agente decidir **quando** carregar a skill. Na inicialização, a ferramenta carrega só o **frontmatter** de todas as skills (name, description, metadata, allowed-tools). O `SKILL.md` completo só entra no contexto quando o agente decide usar a skill — e essa decisão vem da description. É isso que economiza janela de contexto, e é isso que quebra quando a description está "furada".

A aula cria uma segunda skill (`gerar-pr`) só para **disputar o roteamento** com a `gerar-commit` e mostrar o efeito na prática.

## Conceitos principais

### O custo das skills no contexto
- `/context` mostra a linha **Skills** pequena (na demo, ~9,6 mil tokens, ~1% da janela) porque só o frontmatter fica carregado.

### Experimento 1 — sem gatilho × com gatilho
| Description | Pedido "faça o PR" |
|---|---|
| "Gera um texto de descrição de PR a partir do diff. Use ao trabalhar com git." (só descreve) | ❌ Não carregou a skill |
| "...Use quando o usuário pedir para criar um pull request ou usar o termo 'faça o PR'." | ✅ Carregou a skill |

### Experimento 2 — gatilhos iguais em skills opostas
- Com termos repetidos nas duas skills, "faça a mensagem de commit" subiu só a `gerar-commit` — mas **podia subir a errada ou as duas**.
- Ao colocar na `gerar-commit` "não utilize quando for solicitado para criar mensagem de commit", o agente passou a chamar a `gerar-pr`. A cláusula de exclusão funciona — e pode atrapalhar se mal escrita.
- Se você **quer** que duas skills carreguem juntas, use triggers parecidos de propósito. Se são opostas, evite ambiguidade.

### Roteamento é probabilístico
- Depende do **modelo** e da **ferramenta**: pode disparar no Claude Code e não no OpenCode; variar entre modelos (ex.: Qwen × Kimi).
- Forma **determinística**: chamar como comando (`/gerar-pr`, `/gerar-commit`). "Aí você não está torcendo para o modelo entender: está mandando."

### Checklist da description
1. O que a skill faz.
2. Quando usar (gatilhos/termos).
3. Quando **não** usar.

## Comandos e configurações

```bash
mkdir -p .claude/skills/gerar-pr
```

```markdown
---
name: gerar-pr
description: Gera um texto de descrição de PR a partir do diff. Use quando o usuário pedir para criar um pull request ou usar o termo "faça o PR".
---
# Gerar PR
1. Rode `git diff` e leia as mudanças
2. Escreva um parágrafo descrevendo o PR
```

```text
/context   # ver ocupação da janela (linha Skills)
/skills    # conferir se as skills foram carregadas
/gerar-pr  # disparo determinístico
```

## Pegadinhas
- Skill que "não dispara" geralmente não é configuração errada: é **description furada**. Teste.
- Skill nova não aparece? Feche e reabra a sessão (frontmatter é lido na inicialização).
- Refinar description por ferramenta/modelo é trabalho contínuo.

## Dúvidas para revisar
- Testar o mesmo par de skills no Claude Code e em outra ferramenta/modelo.
