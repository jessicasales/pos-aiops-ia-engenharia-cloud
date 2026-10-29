# Skills Prontas — não reinvente a roda

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 10 — Skills Prontas (10:21) |
| **Assunto** | Consumir skills prontas da comunidade e dos cloud providers com segurança |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `skills.sh` `find-skills` `skill-creator` `npx skills add` `AWS` `GCP` `Azure` `segurança` `supply chain` |

## Resumo da aula

Primeira dica para montar o Harness: **não reinvente a roda**. Antes de criar uma skill, procure uma pronta (comunidade, equipe, empresa ou oficial do provider). Se ela faz só parte do que você quer, **estenda**: crie uma skill complementar que é invocada junto com a skill base (ex.: uma "IAM Enterprise" com as regras da empresa que carrega a skill oficial de IAM da AWS).

## Conceitos principais

### Onde procurar
| Recurso | O que é |
|---|---|
| [skills.sh](https://skills.sh) | Agregador de repositórios de skills — leaderboard, busca por tópico e por agente |
| `skill-creator` (Anthropic) | Criar as suas skills |
| `find-skills` (Vercel) | Buscar skills pelo próprio agente, sem ir ao site |

### Skills oficiais dos cloud providers
| Provider | Repositório |
|---|---|
| AWS | https://github.com/aws/agent-toolkit-for-aws |
| Google Cloud | https://github.com/google/skills |
| Azure | https://github.com/microsoft/azure-skills |

| Assunto | AWS | Google Cloud | Azure |
|---|---|---|---|
| Containers / Kubernetes | `aws-containers` | `gke-basics` | `azure-kubernetes` |
| Custo | `aws-billing-and-cost-management` | `gke-cost` | `azure-cost` |
| "A dor de cada um" | `aws-iam` | `gke-observability` | `azure-diagnostics` |

Outras do Azure: `azure-ai`, `azure-deploy`, `azure-prepare`, `azure-validate`.

## Comandos

```bash
npx skills add <owner>/<repo>            # o repositório inteiro
npx skills add <owner>/<repo>/<caminho>  # só uma skill
```

Depois de instalar: conferir em `/skills` e abrir o arquivo em `.claude/skills/` antes de usar.

## Pegadinhas
- Instalar o repositório inteiro da AWS traz **31 skills** de uma vez — prefira só as que vai usar.
- A listagem dos repositórios muda todo mês: confira se o nome da skill ainda existe.
- **Prefira skills oficiais.** Skill de terceiro é **código de terceiro** entrando num agente que já tem acesso ao seu repositório. Baixe e leia antes, principalmente se tiver `scripts/` (Python, PowerShell, Shell) — pode haver código malicioso ou exfiltração. Mesmo cuidado que com imagens Docker e módulos Terraform.

## Dúvidas para revisar
- Avaliar `gke-cost`/`gke-observability` e as skills de Azure para os ambientes que administro.
