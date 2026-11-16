# O que é Prompt Engineering e por que importa

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 01 — O que é Prompt Engineering e por que importa (06:02) |
| **Assunto** | Definição de engenharia de prompt e de contexto, por que a qualidade do input determina a do output, e o que o módulo vai cobrir |
| **Data** | 29/10/2026 22:35 |
| **Tags** | prompt-engineering, engenharia-de-contexto, zero-shot, few-shot, chain-of-thought, custo, versionamento |

## Resumo da aula

Aula de abertura do módulo. O instrutor apresenta o objetivo: ensinar **engenharia de prompt** e **engenharia de contexto** — a disciplina de projetar a interface com a IA. O prompt é o input, e a qualidade do que entra determina a qualidade do que sai. O foco é tirar o aluno do modelo de "tentativa e erro" (ficar interagindo em bate-volta com o chat) e levá-lo para o uso de técnicas documentadas em papers (zero-shot, few-shot, chain-of-thought, entre outras), que reduzem o número de interações e trazem respostas estruturadas.

## Conceitos principais

### O que é engenharia de prompt

Disciplina criada para **desenvolver, otimizar e refinar** os inputs (prompts) enviados à IA. Vai além de estruturar o pedido: inclui saber **avaliar a qualidade da resposta, o tempo de resposta e o custo**, porque tudo isso determina a eficiência e a viabilidade de um projeto.

### Por que custo importa

Rodar um projeto o tempo todo em um modelo caro (ex.: Opus) pode fazer o projeto "não se pagar". Saber escolher o modelo certo — equilibrando custo, latência e qualidade — faz parte da engenharia de prompt.

### Tentativa e erro vs. engenharia de interação

| Abordagem | Característica |
|---|---|
| Tentativa e erro | Bate-volta sem método, 5+ interações até chegar perto do que se quer |
| Engenharia de interação | Técnicas documentadas (zero-shot, few-shot, CoT) + contexto; menos interações, resposta estruturada |

### Não existe receita coringa

Não há "template matador" nem os "10 prompts essenciais" que funcionam em todo cenário. Existem **estruturas** que funcionam bem e que às vezes precisam ser ajustadas. Técnicas diferentes servem para tarefas diferentes: gerar código, analisar logs, escrever documentação.

## Pegadinhas

- Achar que existe um prompt pronto universal. Não existe — cada tarefa exige uma abordagem.
- Esquecer que o modelo influencia o resultado: um modelo com reasoning profundo pode mascarar um prompt ruim. A melhora deve vir do prompt, não só do modelo.

## Dúvidas para revisar

- Quais técnicas documentadas (zero-shot, few-shot, CoT) serão vistas nas próximas aulas e em que cenário cada uma se aplica?
- Como a engenharia de contexto (versionar prompts, analisar comportamento por modelo) se conecta com a engenharia de prompt no fluxo de criação de agentes?
