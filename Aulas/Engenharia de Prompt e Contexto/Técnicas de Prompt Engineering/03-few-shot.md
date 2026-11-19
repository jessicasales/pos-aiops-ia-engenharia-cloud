# Few-Shot Prompt (e One-Shot)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 03 — Few shot (12:32) |
| **Assunto** | Guiar o modelo por exemplos (in-context learning); one-shot vs few-shot, custo e ordem dos exemplos |
| **Data** | 03/11/2026 23:50 |
| **Tags** | few-shot, one-shot, in-context-learning, exemplos, commit-semantico, estilo-de-escrita, custo-tokens |

## Resumo da aula

Se o Zero-Shot não passa exemplo, o **Few-Shot** passa **vários exemplos** no prompt para guiar a resposta. Nomenclatura:

- **One-Shot** → **um** exemplo.
- **Few-Shot** → **dois ou mais** exemplos.

O mecanismo é o **In-Context Learning**: o modelo identifica e repete os padrões dos exemplos. Ele "aprende" com o próprio contexto, mudando o peso dos tokens na geração (Transformer). Esse aprendizado é **momentâneo** — vale só naquela interação; em outra conversa, sem os exemplos, o comportamento não se repete.

## Conceitos principais

### Para que serve na prática

- **Estilo de comunicação**: passando um exemplo do seu jeito de escrever, o modelo replica tom e estrutura (resolve o problema do "post genérico de IA").
- **Padrões internos**: mensagens de commit no padrão da equipe, convenções que só a sua empresa usa.

### Equilíbrio: qualidade > quantidade

- Few-Shot deixa o prompt **mais caro** (mais tokens de input).
- Não adianta 10–20 exemplos repetitivos; muitos exemplos **degradam** a resposta.
- Dica: **3 a 5 exemplos**, com nuances diferentes. Pode incluir exemplos de abordagens **certas e erradas** (ensina o que você quer e o que não quer).

### Ordem importa

O modelo dá mais peso ao **início** e ao **final** do prompt. Coloque o **melhor exemplo por último**.

## Prompts da aula

Material complementar — cada prompt mostra como guiar o modelo via exemplos para replicar padrões (estilo, formato, convenções).

<details>
<summary>Prompts Few-Shot</summary>

```markdown
# Prompt 1 — Escrita de artigo seguindo padrão de estilo
# (ensina o estilo a partir de um exemplo de referência; sem ele, o texto sai genérico/formal)
Quero que você escreva artigos seguindo o padrão de estilo do exemplo abaixo.

## Exemplo de referência:

Título: Por que Kubernetes não é pra todo mundo

Todo mundo fala de Kubernetes como se fosse a solução pra tudo. Spoiler: não é.

Se você tem 3 serviços rodando num VPS de 20 dólares, colocar Kubernetes no meio é como comprar um caminhão pra levar uma mochila. Funciona? Funciona. Faz sentido? Nem de longe.

O problema não é o Kubernetes — é achar que complexidade é sinal de maturidade. Às vezes o docker compose resolve. Às vezes um script bash resolve. E tá tudo bem.

Use Kubernetes quando a escala justificar. Quando o problema for real, não quando o ego pedir.

## Agora escreva um artigo neste mesmo estilo sobre: "Por que monitoramento não é só instalar Grafana"
```

```markdown
# Prompt 2 — Mensagens de commit no padrão da equipe
# (três exemplos no formato tipo(escopo): descrição — o modelo aprende o padrão completo)
Gere mensagens de commit seguindo o padrão da equipe. Siga os exemplos.

Exemplo 1:
Mudança: Adicionou endpoint de health check
Commit: feat(api): add health check endpoint with liveness and readiness probes

Exemplo 2:
Mudança: Corrigiu timeout na conexão com Redis
Commit: fix(cache): increase Redis connection timeout to 5s

Exemplo 3:
Mudança: Atualizou versão do Go de 1.20 para 1.21
Commit: chore(deps): bump Go version from 1.20 to 1.21

Agora gere:
Mudança: Adicionou retry com backoff exponencial nas chamadas ao serviço de pagamento
```

</details>

Nota da demo: mesmo descrevendo a mudança em português, o modelo gera o commit em inglês, seguindo o padrão dos exemplos — prova que ele aprende o padrão, não só traduz.

## Pegadinhas

- Exemplos repetidos ou em excesso **pioram** o resultado e aumentam o custo.
- Few-Shot encarece o prompt (mais tokens de input) — use quando o ganho de consistência justificar.
- O aprendizado é só daquela interação; não "treina" o modelo para o futuro.

## Dúvidas para revisar

- Quais convenções internas (commit, naming, template de ticket) valem virar um conjunto fixo de 3–5 exemplos reutilizáveis?
- Como montar exemplos "certo vs. errado" para ensinar o modelo a evitar um erro recorrente do time?
