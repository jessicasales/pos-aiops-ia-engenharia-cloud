# Framework C-A-R-E (Context, Action, Result, Example)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 06 — Framework C-A-R-E (Context, Action, Result, Example) (15:30) |
| **Assunto** | Framework de precisão por referência (Context, Action, Result, Example); o Example é a ponte para o few-shot prompting |
| **Data** | 29/10/2026 22:35 |
| **Tags** | care, context, action, result, example, few-shot, terraform, feedback, template |

## Resumo da aula

Quarto framework. O **C-A-R-E (Context, Action, Result, Example)** resolve o que o B-A-B não faz: mostrar um **exemplo concreto** do resultado esperado. O **Example** é o diferencial — dá ao modelo uma referência de qualidade/formato/tom. É um passo em direção ao **few-shot prompting** (que será visto depois). Demonstrado com feedback de desempenho (com e sem Example) e Terraform module seguindo padrão da empresa.

## Conceitos principais

### Os 4 componentes

| Componente | Função |
|---|---|
| **Context** | Cenário completo: quem você é, stack, restrições, convenções |
| **Action** | Ação específica com verbo claro (não "me ajuda a criar") |
| **Result** | Como o resultado deve ser formatado/estruturado; critérios de sucesso (o que é "pronto") |
| **Example** | Referência concreta do resultado esperado — formato, tom, convenções |

### O Example elimina ambiguidade

Sem Example, o feedback sai em formato genérico e **muda a cada execução**. Com Example (um feedback do ciclo passado), o modelo replica tom, exemplos concretos e formato — e repete de forma consistente. É a ponte para o few-shot.

### Result define "pronto" antes de começar

Previne o problema clássico: a IA entrega algo tecnicamente correto mas em formato que não serve. O Result força a definição dos critérios de sucesso.

### Quando usar

- Tarefas que exigem **precisão e consistência**: módulo Terraform seguindo padrão existente, feedback no formato do ciclo anterior, documentação seguindo template da empresa, e-mail padronizado, código estruturado.

### Quando NÃO usar

- Tarefa simples demais para justificar o overhead.
- Perguntas rápidas de resposta curta.
- Não há exemplo de referência disponível.

## Prompts da aula

<details>
<summary>Prompts C-A-R-E</summary>

```markdown
# Feedback de desempenho COM Example (C-A-R-E completo)
# Context
Sou tech lead de um time de 6 engenheiros em uma empresa de SaaS B2B. Estamos no ciclo de avaliação semestral. Preciso dar feedback individual seguindo o formato que o RH definiu.
# Action
Elabore um feedback de desempenho para uma engenheira plena que entrega muito bem tecnicamente (sempre cumpre prazos, código com boa cobertura de testes) mas precisa melhorar a comunicação com stakeholders de produto — ela evita reuniões e responde de forma muito técnica quando o PM faz perguntas.
# Result
O feedback deve ter 3 seções: "Pontos Fortes" com exemplos concretos, "Áreas de Desenvolvimento" com sugestões acionáveis, e "Próximos Passos" com metas mensuráveis para o próximo ciclo. Tom construtivo e direto, sem jargão corporativo.
# Example
Aqui está um feedback que escrevi no ciclo passado para outro membro do time, no formato e tom que quero manter:

**Pontos Fortes:**
O João foi peça-chave na entrega do projeto de migração do monólito. Ele liderou a definição da arquitetura de microsserviços e conduziu 3 design reviews com o time. Destaque para a documentação dos ADRs — ficou clara e serviu de referência para decisões futuras.

**Áreas de Desenvolvimento:**
O João precisa desenvolver mais autonomia na priorização. Em duas situações no trimestre, ele esperou direcionamento meu para decidir entre tarefas que poderia ter priorizado sozinho. Sugestão: usar a matriz de impacto/esforço antes de escalar.

**Próximos Passos:**
- Liderar pelo menos 1 design review por sprint sem acompanhamento do tech lead (até março)
- Priorizar autonomamente tarefas de até 3 story points sem escalar (próximo ciclo)
```

```markdown
# Terraform module com padrões da empresa (C-A-R-E completo)
# Context
Trabalhamos com Terraform na AWS. Seguimos o padrão de módulos do terraform-aws-modules como referência de estrutura. Usamos workspaces para separar ambientes (dev, staging, prod). Backend em S3 para state lock. Convenção de naming: kebab-case para recursos, snake_case para variáveis.
# Action
Crie um Terraform module para provisionar um bucket S3 com versionamento, encryption com KMS e lifecycle rules para transição para Glacier após 90 dias.
# Result
O module deve conter: main.tf, variables.tf com descrições e validações, outputs.tf com ARN e nome do bucket, e um README.md com exemplo de uso. Seguir as convenções de naming definidas no contexto.
# Example
(trecho do module de SQS já em produção, como referência de padrão)

resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  tags = merge(var.tags, { Module = "sqs-queue" })
}

variable "queue_name" {
  description = "Nome da fila SQS"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+$", var.queue_name))
    error_message = "O nome da fila deve usar kebab-case."
  }
}
```

</details>

## Pegadinhas

- Observação do instrutor sobre Terraform/AWS: o **backend S3 não precisa mais do DynamoDB** para state lock (o lock nativo em S3 já existe) — por isso ele remove o DynamoDB do contexto no exemplo.
- Para gerar código de verdade, o ideal é usar o C-A-R-E numa ferramenta de codificação (Claude Code, Gemini CLI), não na interface de chat — vai para outro nível.
- Few-shot (exemplos) é citado como ~80% mais eficiente que zero-shot (ver guia prático).

## Dúvidas para revisar

- Como montar uma biblioteca de Examples reutilizáveis (feedbacks, modules) para padronizar os prompts do time?
- Qual a diferença prática entre o Example do C-A-R-E e o few-shot prompting formal que será visto adiante?
