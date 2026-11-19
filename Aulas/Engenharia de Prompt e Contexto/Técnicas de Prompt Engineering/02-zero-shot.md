# Zero-Shot Prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 02 — Zero shot (11:47) |
| **Assunto** | Técnica mais simples: pedir sem fornecer nenhum exemplo de retorno, para tarefas de uso comum |
| **Data** | 03/11/2026 23:50 |
| **Tags** | zero-shot, sem-exemplo, tarefa-comum, json, kubernetes, bash, classificacao |

## Resumo da aula

Primeira e mais usada técnica. **Zero-Shot** = criar o prompt **sem fornecer nenhum exemplo** do retorno esperado. O modelo decide sozinho como responder, apoiado na base com que foi treinado. Funciona bem para **tarefas de uso comum** (padrões abertos, amplamente documentados): manifesto Kubernetes, e-mail, classificação de sentimento, script Bash, Terraform, converter Docker Compose em manifesto K8s.

Você pode até pedir um formato específico (tabela, JSON, YAML) — isso **continua sendo Zero-Shot**, porque pedir formato não é dar exemplo. Zero-Shot é qualquer prompt onde você não envia um exemplo de resultado.

## Conceitos principais

### Quando usar

- Tarefa direta com output previsível.
- Conhecimento de **uso comum**, padrão aberto (JSON, YAML, Dockerfile, Bash, policies IAM).
- Sem necessidade de informação específica do negócio.

### Quando NÃO usar

- Padrão específico de organização, de log, template próprio, naming conventions.
- Tarefas ambíguas onde o modelo precisa adivinhar o retorno.
- Quando a qualidade precisa ser **consistente e replicável** — Zero-Shot tende a variar a resposta a cada execução, perdendo consistência.

> Regra prática: assim que houver particularidade da empresa, saia do Zero-Shot (vá para Few-Shot ou uma técnica de raciocínio).

### Boas práticas

- Seja **detalhista** na tarefa — prompt vago faz o modelo improvisar e aumenta risco de alucinação.
- Defina bem o escopo e o fluxo de execução (siga uma estrutura de framework).

## Prompts da aula

Material complementar com os prompts usados na demonstração. Cada um pode ser testado em qualquer LLM (ChatGPT, Claude, Gemini).

<details>
<summary>Prompts Zero-Shot</summary>

```markdown
# Prompt 1 — Organização e priorização de tarefas
# (o modelo entende prioridade pelo contexto — "amanhã", "vence hoje" — sem exemplos)
Organize a lista abaixo em uma tabela com colunas: tarefa, categoria, prioridade (alta/média/baixa).

- Comprar presente pro aniversário do João que é amanhã
- Responder e-mail do contador sobre imposto de renda
- Trocar lâmpada da cozinha
- Marcar dentista
- Pagar fatura do cartão que vence hoje
- Assistir episódio novo da série
```

```markdown
# Prompt 2 — Classificação de severidade de alerta (saída JSON estruturada)
Classifique o alerta abaixo como critical, high, medium ou low. Responda em JSON com os campos: severity, justification e recommended_action.

Alerta: "Pod CrashLoopBackOff no deployment payment-service no namespace production. Restarts: 15 nos últimos 30 minutos."
```

```markdown
# Prompt 3 — Geração de script Bash de automação
Crie um script em Bash que verifique todos os pods em estado de erro no namespace production de um cluster Kubernetes. O script deve listar o nome do pod, status e número de restarts, e enviar um alerta no stdout se algum pod tiver mais de 5 restarts.
```

</details>

## Pegadinhas

- Pedir retorno em JSON/YAML **não** transforma o prompt em Few-Shot: JSON é padrão aberto, o modelo já o conhece. Só precisa de exemplo quando o formato é específico da sua empresa.
- Zero-Shot perde consistência quando a tarefa exige resposta replicável — para isso, suba para Few-Shot/C-A-R-E ou uma técnica de raciocínio.
- Na demo o instrutor usa aba anônima e um modelo "mais fraco" (Claude Haiku) de propósito, para mostrar que Zero-Shot resolve tarefas comuns mesmo sem reasoning pesado.

## Dúvidas para revisar

- Quais tarefas recorrentes do meu time são "uso comum" o suficiente para ficar só no Zero-Shot?
- Onde hoje eu uso Zero-Shot mas deveria subir para Few-Shot por causa de um padrão interno (naming, template de log)?
