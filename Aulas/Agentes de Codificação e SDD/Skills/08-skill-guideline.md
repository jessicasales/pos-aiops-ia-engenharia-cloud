# Skill de Guideline — Terraform

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 08 — Skill Guideline (22:41) |
| **Assunto** | Transformar um documento de padrões/boas práticas em skill de guideline |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `guideline` `terraform` `terraform-best-practices` `skill-creator` `brainstorm` `modules` `terraform validate` `Context7` `autocontida` |

## Resumo da aula

Skill não é só workflow: também pode carregar **base de conhecimento e padrões** (guidelines, convenções de nome, estrutura de projeto) para a IA criar e revisar do seu jeito. A aula pega um guideline de Terraform simplificado a partir de [terraform-best-practices.com](https://www.terraform-best-practices.com) (Anton Babenko) e, com `/skill-creator` + brainstorm, cria a skill **`terraform-guidelines`** em escopo de projeto.

No teste (EKS + RDS na AWS com VPC própria, ambientes dev e prod), a skill disparou sozinha, consultou a **última versão** do Terraform e do provider AWS via MCP **Context7**, e gerou `modules/` (network, kubernetes, database) + `environments/` (dev, prod).

## Conceitos principais

### Skill de guideline × skill de workflow
- Guideline: **não tem passos a executar**; o valor é injetar a regra certa na hora certa (criação **e revisão**).
- Pode ter uma skill de guideline e outra de workflow trabalhando juntas (ex.: workflow com **Trivy** para validar Terraform, como foi feito com hadolint no Docker).

### Decisões tomadas no brainstorm
| Decisão | Escolha |
|---|---|
| Momento de uso | Escrever/editar **e revisar** Terraform |
| Escopo além do doc | + estrutura de arquivos e versionamento de provider |
| Público | Uso real |
| Multiambiente | **Uma pasta por ambiente**, cada uma com seu state, consumindo `modules/` |
| Referência ao documento | **Copiar para dentro da skill** — skill **autocontida** |
| Testes | Sempre `terraform fmt`, `init`, `validate` |

### As quatro regras extras (o documento fonte não cobria)
1. Projeto novo → sempre consultar a **última versão** do Terraform e do provider (AWS, Azure, Google...). "Versão sempre atual, nunca de memória."
2. **Módulos sempre criados do zero**, nunca da comunidade (compliance/segurança, comum em bancos).
3. Estrutura sempre com **modules**, visando reaproveitamento e organização.
4. Sempre testar com **`terraform validate`**.

A skill-creator detectou que a regra 2 **contradiz o documento fonte** e tratou isso explicitamente na skill.

## Prompts da aula

```text
/skill-creator Entre em modo brainstorm. Eu quero criar uma skill de Terraform, mas essa skill não deve ser uma skill de workflow. O objetivo dessa skill é orientar a inteligência artificial a seguir os padrões de construção, guidelines e convenções de nomes já definidos no meu documento de construção de aplicações com Terraform — o documento de especificação técnica. O documento segue abaixo.
@docs/guideline-terraform.md
Ignore completamente o harness library. Essa skill será criada a nível de projeto.
```

```text
Quero criar um projeto Terraform para criar um ambiente Kubernetes com RDS na AWS. O objetivo é que esse ambiente seja totalmente independente, com a sua própria VPC, com o seu próprio banco dentro da VPC, e seja autocontido. Eu preciso ter dois ambientes: de desenvolvimento e também de produção.
```

Estrutura gerada:
```text
modules/
├── network/
├── kubernetes/   # inclui IAM do cluster
└── database/
environments/
├── dev/
└── prod/
```

## Pegadinhas
- Referencie o documento com **`@arquivo`**, não cole o conteúdo inteiro.
- A IA "escreve de qualquer jeito" porque você deixou e não definiu o padrão — guideline em skill resolve isso sem ficar copiando prompt.
- Guideline pequeno cabe no próprio `SKILL.md`; se crescer, separar em references.
- Considere regra para projeto de um único ambiente (a skill aplica pasta por ambiente mesmo com um só).

## Dúvidas para revisar
- Transformar os padrões que já tenho documentados (Docker, manifests Kubernetes, pipelines) em skills de guideline.
- Material da aula: `guideline-terraform.md` no `.zip`.
