# Self-Consistency

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 07 — Self consistency (20:57) |
| **Assunto** | Gerar análises independentes e convergir nos pontos em comum para ganhar confiança |
| **Data** | 03/11/2026 23:50 |
| **Tags** | self-consistency, convergencia, divergencia, diagnostico-independente, war-room, migracao, confianca |

> Prompts transcritos da narração da aula; a formatação exata do material pode variar.

## Resumo da aula

Parecido com o Tree of Thoughts (também usa múltiplas opções), mas com um objetivo **diferente**: em vez de escolher a melhor alternativa, o **Self-Consistency** gera várias análises **independentes** e identifica os **elementos em comum** (convergências) e as **divergências**.

A lógica: se pontos de vista diferentes chegam a conclusões similares, a confiança é maior. É como buscar vários diagnósticos médicos independentes — quando convergem, você confia mais.

## Conceitos principais

### ToT vs. Self-Consistency

| | Tree of Thoughts | Self-Consistency |
|---|---|---|
| **Múltiplas análises** | Sim | Sim |
| **Há debate entre elas?** | Sim, debatem os trade-offs | **Não** — cada uma é independente, sem ver as outras |
| **Resultado** | Escolhe a **melhor** alternativa | Mapeia **convergências** (confiança alta) e **divergências** (investigar mais) |

Ponto-chave do prompt: pedir que cada análise seja feita **sem considerar a opinião das outras**.

### Usa CoT por dentro

Cada análise independente é, na prática, um Chain of Thoughts (raciocínio passo a passo). Por isso é como **executar N vezes um CoT** + a etapa de convergência → **latência e custo de tokens altos**.

### Quando usar

Decisões de arquitetura complexas, war room (incidente com várias equipes), análise de segurança (risco de falso positivo/negativo), qualquer cenário onde você precisa **ter certeza** e correlacionar ganhos/perdas.

### Quando NÃO usar

Tarefas simples (classificar alerta, formatar log, resposta curta) — gasto de tokens sem ganho.

> Dica: use **3 a 5 análises**. Abaixo de 3 vira CoT; acima de 5 degrada.

## Prompts da aula

<details>
<summary>Prompts Self-Consistency (transcritos da aula)</summary>

```markdown
# Prompt 1 — Diagnóstico do carro (3 mecânicos independentes)
Meu carro está fazendo um barulho metálico ao frear, principalmente em baixa velocidade. O carro tem 4 anos e 60 mil km rodados. Nunca troquei as pastilhas.

Gere três diagnósticos independentes, como se fossem três mecânicos diferentes analisando o problema separadamente. Cada mecânico deve raciocinar passo a passo e chegar ao seu próprio diagnóstico principal, sem considerar a opinião dos outros.

Depois, compare os três diagnósticos e identifique onde convergem (confiança alta) e onde divergem (precisa investigar mais).
```

```markdown
# Prompt 2 — Migração de monolito Java (3 perfis independentes)
Temos uma aplicação monolítica em Java (Spring Boot) rodando em 2 servidores on-premise com PostgreSQL. Equipe de 3 pessoas, prazo de 4 meses, budget limitado. 80 mil usuários/mês com picos sazonais. Precisamos migrar para a AWS.

Gere três análises independentes dos seguintes perfis, cada um avaliando o cenário separadamente:
- Dev: foco em código, framework, refatoração, ciclo de desenvolvimento
- SysAdmin: foco em infraestrutura, operação, monitoramento, estabilidade
- Arquiteto de Cloud: foco em AWS, custo, arquitetura

Cada perfil deve raciocinar passo a passo considerando equipe, prazo, budget e perfil da aplicação, e recomendar a melhor estratégia de migração. Não considere as outras análises.

Depois, compare as três recomendações e indique onde convergem e onde divergem.
```

```markdown
# Prompt 3 — War room: latência degradada (3 perfis independentes)
Incidente em produção: API REST em Java com latência degradada. Banco PostgreSQL. Houve deploy recente. [incluir logs da aplicação]

Gere três diagnósticos independentes dos seguintes perfis, cada um analisando os logs separadamente: Desenvolvedor, SysAdmin e Arquiteto de Cloud. Cada profissional deve raciocinar passo a passo e chegar à sua hipótese.

Depois, compare os três diagnósticos e identifique onde convergem e onde divergem.
```

</details>

## Pegadinhas

- O ponto que separa do ToT é o **"sem considerar as outras análises"** — sem isso, vira debate (ToT).
- Custo alto: N análises CoT + convergência. Só use quando a confiança extra valer o gasto.
- Se o output precisa ter formato consistente, **especifique no prompt** — senão cada execução formata de um jeito.

## Dúvidas para revisar

- Em quais decisões críticas eu quero convergência de 3 perfis antes de agir?
- Como padronizar o output (tabela de convergências/divergências) para o time comparar rápido?
