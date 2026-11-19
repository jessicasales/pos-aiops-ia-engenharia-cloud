# Least-to-Most

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas avançadas de Prompt Engineering |
| **Aula** | 03 — Least to most (17:07) |
| **Assunto** | Decompor o problema em subproblemas e resolver do mais simples ao mais complexo |
| **Data** | 03/11/2026 23:58 |
| **Tags** | least-to-most, decomposicao, subproblemas, milestones, spec-driven-development, dependencias |

## Resumo da aula

Jogar um problema complexo inteiro num prompt gera resultado genérico e superficial. O **Least-to-Most** usa Prompt Chaining para, primeiro, **decompor** o problema em subproblemas e depois **resolver cada um, do mais simples ao mais complexo**, carregando o contexto do que já foi resolvido. O nome diz: do menor (*least*) ao maior (*most*).

## Conceitos principais

### Dois estágios

1. **Decomposição**: o primeiro prompt é de **planejamento** — pede a lista de subproblemas, do mais simples ao mais complexo. *"Retorne apenas a lista"* é o pulo do gato (não deixa o modelo resolver nada ainda).
2. **Resolução sequencial**: cada subproblema em um prompt separado, alimentado pelo anterior (execução em loop).

### Least-to-Most ≠ Chain of Thoughts

| | Chain of Thoughts | Least-to-Most |
|---|---|---|
| **Decomposição** | Interna, num único prompt | Explícita, em múltiplos prompts |
| **Contexto** | Interno (o modelo gerencia) | Externo (você controla o que cada prompt recebe) |

### Adaptação: subproblemas ou milestones

O vocabulário se adapta. Em vez de "subproblemas / resolva o subproblema", você pode usar "**milestones / execute a tarefa**" — gera uma estrutura mais próxima de um plano de projeto (marcos, tarefas, subtarefas, dependências).

### Ligação com Spec-Driven Development

Least-to-Most é o padrão por trás do **SDD**: decompõe a feature em spec (user stories, tasks, subtasks) e só depois manda executar tarefa por tarefa. Ferramentas como Claude Code, GitHub Spec Kit e Amazon Kiro usam esse padrão.

### Quando usar / não usar

- **Usar**: problemas com múltiplas dependências entre etapas (criar infra), planejamento multietapa onde a ordem importa (migração, setup de ambiente), listas de execução para agentes.
- **Não usar**: tarefa direta sem dependências (classificar alerta, gerar script, resumir) → zero/few-shot ou CoT.

## Prompts da aula

<details>
<summary>Prompts Least-to-Most (subproblemas e milestones)</summary>

```markdown
# Decomposição em subproblemas (retorna só a lista)
Preciso criar a infraestrutura na AWS para uma aplicação web com a
seguinte arquitetura: API em containers rodando no EKS, banco PostgreSQL
gerenciado no RDS, cache Redis no ElastiCache e API Gateway na frente.
A infra precisa estar em multi-AZ, com ambientes de staging e produção separados.

Decomponha a criação dessa infraestrutura em subproblemas agrupados
por dependência. Para cada subproblema, liste o que ele envolve e
de quais subproblemas anteriores ele depende. Ordene do mais
fundamental ao mais complexo.
Retorne apenas a lista.
```

```markdown
# Resolução do subproblema 1 (mesma janela de contexto)
Estou criando a infraestrutura na AWS para uma aplicação web: API em
containers (EKS), PostgreSQL (RDS), Redis (ElastiCache), API Gateway.
Multi-AZ, com ambientes staging e produção separados.

Resolva o subproblema 1.
```

```markdown
# Continuar a cadeia (minimalista)
Resolva o próximo subproblema pendente.
```

```markdown
# Variação por milestones (plano de projeto)
Preciso criar a infraestrutura na AWS [...mesma arquitetura...].

Crie uma lista de milestones com tarefas e sub-tarefas para a criação
dessa infraestrutura. Organize por ordem de execução, considerando
dependências entre os milestones. Retorne apenas a lista.
```

```markdown
# Execução progressiva por milestone
Execute a próxima tarefa.
```

</details>

## Pegadinhas

- **Erro em cascata**: se o modelo erra no subproblema 2, os 3, 4, 5 carregam o erro; se a decomposição estiver errada, tudo erra. Validar cada etapa é fundamental (próxima aula: Chain of Verification).
- "Retorne apenas a lista" é o que impede o modelo de começar a resolver antes da hora.

## Dúvidas para revisar

- Quais entregas de infra/projeto do meu time ganhariam com uma decomposição em milestones + dependências?
- Como ligar isso ao fluxo de SDD que usarei nos próximos módulos?
