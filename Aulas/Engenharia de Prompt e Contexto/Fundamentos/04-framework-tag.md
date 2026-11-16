# Framework T-A-G (Task, Action, Goal)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 04 — Framework T-A-G (Task, Action, Goal) (11:00) |
| **Assunto** | Framework orientado a resultado (Task, Action, Goal) para quando a resposta precisa atender um objetivo mensurável, SLA ou KPI |
| **Data** | 29/10/2026 22:35 |
| **Tags** | tag, task, action, goal, sla, kpi, rca, incidente, plano-de-estudo |

## Resumo da aula

Segundo framework. O **T-A-G (Task, Action, Goal)** resolve a limitação do R-T-F: ele não tem onde colocar o **objetivo/propósito**. T-A-G é orientado a resultado — adiciona um propósito mensurável à tarefa. O **Goal** é o diferencial: direciona tom, profundidade e foco da resposta para um objetivo de negócio. Como Action + Goal já dão direcionamento, não precisa da Role. Demonstrado com plano de estudos para certificação AWS e RCA de incidente com SLA.

## Conceitos principais

### Os 3 componentes

| Componente | Função |
|---|---|
| **Task** | O que precisa ser feito |
| **Action** | Como fazer — passo a passo, forma de construir, como retornar (categorizar, ranquear, calcular, correlacionar por timestamp, classificar por severidade) |
| **Goal** | O "pra quê" — resultado de negócio ou objetivo mensurável (KPI, SLA, prazo) |

### O Goal é o diferencial

É onde entram KPI, prazo de SLA, meta de redução ("reduzir gastos em 20% em 3 meses"), score mínimo de prova. O Goal direciona o tom, a profundidade e o foco — o que o R-T-F não consegue fazer.

### Quando usar

- Resultado atrelado a **objetivo mensurável**: análise de incidente com SLA, otimização de custos com meta, plano de estudo com nota-alvo.

### Quando NÃO usar

- Tarefa muito simples, sem objetivo claro — nesse caso o Goal fica forçado/vazio e o R-T-F resolve melhor.

## Prompts da aula

<details>
<summary>Prompts T-A-G</summary>

```markdown
# Plano de estudos com meta de certificação
# Task
Crie um plano de estudos semanal para a certificação AWS Solutions Architect Associate.
# Action
Organize por domínios do exame, distribua os tópicos em 12 semanas, inclua recursos gratuitos e pagos, e reserve as 2 últimas semanas para simulados e revisão.
# Goal
Objetivo: aprovação no exame com score mínimo de 750/1000, estudando no máximo 2 horas por dia durante a semana e 4 horas nos fins de semana.
```

```markdown
# Análise de incidente com SLA de RCA
# Task
Analise o seguinte cenário de incidente: o serviço de API de pagamentos está retornando timeout (HTTP 504) para 30% das requisições desde as 14h. O serviço roda em ECS Fargate com 4 tasks, ALB na frente e banco RDS PostgreSQL.
# Action
Faça uma análise estruturada: liste as 5 causas mais prováveis em ordem de probabilidade, para cada causa indique o comando ou métrica AWS para validar, e proponha a ação corretiva imediata.
# Goal
Objetivo: produzir uma análise de causa raiz preliminar em formato de documento que permita ao time de plantão identificar e corrigir a causa raiz em até 2 horas, priorizando ações de menor risco primeiro.
```

</details>

## Pegadinhas

- Sem objetivo mensurável, o Goal vira enfeite — não use T-A-G só porque existe o campo.
- Validar sempre: recursos/cursos sugeridos pelo modelo podem não existir ou estar desatualizados.

## Dúvidas para revisar

- Qual a fronteira prática entre o Goal (T-A-G) e a Expectation (R-I-S-E)? (Goal = resultado de negócio; Expectation = critério de validação/pronto)
- Em um RCA real, como alimentar o Action com dados concretos sem cair no R-I-S-E (que tem o campo Input)?
