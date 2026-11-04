# Self-Refine

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas avançadas de Prompt Engineering |
| **Aula** | 05 — Self Refine (22:06) |
| **Assunto** | Ciclo de autocrítica baseado em critérios para melhorar a qualidade do output |
| **Data** | 03/11/2026 23:58 |
| **Tags** | self-refine, autocritica, criterios, qualidade, dockerfile, overengineering, review-humano |

## Resumo da aula

Se o Chain of Verification pergunta *"está correto?"*, o **Self-Refine** pergunta *"está bom o suficiente?"*. Um Dockerfile pode buildar sem erro (correto) e ainda assim ser **ruim** para produção (imagem pesada, roda como root, sem multistage). O Self-Refine instrui o modelo a olhar o próprio output, **criticar com base em critérios** e gerar uma versão melhor — repetindo o quanto for necessário.

## Conceitos principais

### Três estágios (que se repetem)

1. **Gerar** a resposta inicial.
2. **Criticar** com base em **critérios que você define**.
3. **Melhorar** incorporando a crítica. Depois volta ao passo 2.

### Critérios são obrigatórios

Sem critérios, a crítica é genérica ("melhorei a clareza") e o modelo só reescreve igual. Os critérios **mudam por domínio**:

| Output | Critérios |
|---|---|
| Código | segurança, performance, legibilidade, boas práticas |
| Dockerfile | tamanho da imagem, cache de layers, multistage, usuário não-root |
| Documentação | clareza, passos acionáveis |

### Self-Refine ≠ Chain of Verification

| | Chain of Verification | Self-Refine |
|---|---|---|
| **Pergunta** | Está correto? | Está bom o suficiente? |
| **Natureza** | Binário (certo/errado) | Gradual (sempre pode melhorar) |

São **complementares**: primeiro refine até a qualidade desejada (Self-Refine), depois verifique se está correto (CoVe). O paper (Aman Madaan et al., 2023) mediu ~20% de melhoria só adicionando o ciclo de autocrítica, com qualquer modelo.

### Quando parar

Quando as mudanças viram **cosméticas** (não estruturais), pare — senão cai em *overengineering*. Recomendação: **no máximo ~3 iterações**.

## Prompts da aula

<details>
<summary>Demo 1 — Proposta de palestra (CFP)</summary>

```markdown
# Passo 1 — gerar a proposta
Escreva uma proposta de palestra (CFP) para submeter num evento de tecnologia.
Tema: "Como IA generativa está mudando o dia a dia de times de engenharia de plataforma".
Formato: talk de 30 minutos. Público: engenheiros de software e DevOps, nível
intermediário a avançado. A proposta precisa ter: título, abstract e 3 a 5 tópicos.
```

```markdown
# Passo 2 — autocrítica com critérios (nota 1 a 5)
Critique a proposta que você gerou. Avalie com base nos critérios:
1. Gancho: título e início capturam atenção ou são genéricos?
2. Clareza: quem lê entende o que vai aprender?
3. Originalidade: diferencia de dezenas de outras sobre IA?
4. Público-alvo: nível técnico calibrado para intermediário/avançado?
5. Formato: os tópicos cabem em 30 min sem virar superficial?
Para cada critério, dê nota de 1 a 5 e justifique.
```

```markdown
# Passo 3 — versão melhorada (só corrige nota < 4)
Com base na sua autocrítica, gere uma versão melhorada da proposta.
Corrija todos os pontos onde a nota foi menor que 4.
```

</details>

<details>
<summary>Demo 2 — Dockerfile</summary>

```markdown
# Passo 1 — gerar (vago em segurança de propósito)
Gere um Dockerfile para uma API Node.js com Express. A aplicação usa npm,
tem package.json e o entrypoint é server.js. Gere pronto para build.
```

```markdown
# Passo 2 — autocrítica técnica (nota 1 a 5)
Critique o Dockerfile que você gerou. Avalie:
1. Segurança: roda como root? Tem usuário não-privilegiado?
2. Tamanho da imagem: base mais enxuta possível?
3. Cache de layers: a ordem aproveita o cache do Docker?
4. Multi-stage: separa build de runtime?
5. Boas práticas: tem .dockerignore? Usa COPY em vez de ADD?
Para cada critério, dê nota de 1 a 5 e explique o que melhorar.
```

```markdown
# Passo 3 — versão melhorada
Com base na sua autocrítica, gere uma versão melhorada do Dockerfile.
Corrija todos os pontos onde a nota foi menor que 4.
```

</details>

## Pegadinhas

- Diferente do CoVe, aqui **não há isolamento** → sujeito a viés de confirmação, mas é mais barato e rápido. Use quando o custo do erro é baixo e a velocidade importa.
- "Corrija só o que ficou abaixo de 4" evita mexer no que já estava bom.
- **Não substitui revisão humana**: código, PRD, ADR, TRD, post-mortem — revise sempre.
- Uso no fluxo: refina **specs, planejamento e código** no SDD (qualidade da spec determina qualidade da implementação).

## Dúvidas para revisar

- Quais critérios fixos eu definiria para refinar Dockerfiles/pipelines do time?
- Qual a combinação ideal: Self-Refine primeiro (qualidade), CoVe depois (correção)?
