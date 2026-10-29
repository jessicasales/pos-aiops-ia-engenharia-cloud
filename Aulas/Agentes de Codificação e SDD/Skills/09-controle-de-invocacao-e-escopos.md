# Controle de Invocação e Escopos

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 09 — Controle de Invocação e Escopos (06:54) |
| **Assunto** | Quem pode disparar a skill: só o usuário, só o modelo ou ambos |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `disable-model-invocation` `user-invocable` `frontmatter` `janela de contexto` `subagentes` |

## Resumo da aula

Por padrão, o frontmatter (`name` + `description`) de toda skill é carregado no contexto, e a skill pode ser disparada tanto pelo modelo quanto pelo usuário (`/nome`). Dois campos do frontmatter mudam isso.

## Conceitos principais

| Campo | Efeito | Quando usar |
|---|---|---|
| `disable-model-invocation: true` | A description **sai da janela de contexto**; o modelo nem sabe que a skill existe. Só funciona via `/nome`. | Skill de exceção sempre rodada manualmente; várias skills com objetivo parecido; **economizar contexto** |
| `user-invocable: false` | A skill **some do menu `/`**, mas o modelo continua carregando quando relevante. | Skill que só o agente (ou um **subagente**) deve usar |

Na demo com `terraform-guidelines`:
- Com `disable-model-invocation`, "Valide o projeto Terraform" **não** carregou a skill; `/terraform-guidelines validar o projeto Terraform` carregou.
- Com `user-invocable: false`, `/terraform...` não aparece, mas "quero validar o projeto Terraform com as boas práticas" dispara a skill.

## Comandos e configurações

```yaml
# Só o usuário dispara
---
name: terraform-guidelines
description: Padrão da casa para escrever, editar e revisar Terraform/HCL.
disable-model-invocation: true
---
```

```yaml
# Só o modelo dispara
---
name: terraform-guidelines
description: Padrão da casa para escrever, editar e revisar Terraform/HCL.
user-invocable: false
---
```

```text
/context   # conferir se a skill está ocupando a janela de contexto
/skills    # listar as skills carregadas
```

## Pegadinhas
- Depois de mudar o frontmatter, **feche e reabra o agente** para recarregar as permissões.
- O controle de escopo também é uma ferramenta de **gestão da janela de contexto**.

## Dúvidas para revisar
- Voltar aqui quando chegar no capítulo de **Sub Agentes** (skills usadas só por subagentes).
