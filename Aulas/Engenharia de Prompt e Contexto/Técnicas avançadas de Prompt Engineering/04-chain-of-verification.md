# Chain of Verification (CoVe)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas avançadas de Prompt Engineering |
| **Aula** | 04 — Chain of verification (29:37) |
| **Assunto** | Fazer a IA auditar os próprios fatos, com verificação isolada para evitar viés de confirmação |
| **Data** | 03/11/2026 23:58 |
| **Tags** | chain-of-verification, cove, verificacao, vies-de-confirmacao, factored, terraform, meta-ai-2023 |

## Resumo da aula

O modelo gera resposta **token a token, sempre para frente** (geração autoregressiva) — ele não volta para revisar o que escreveu. Por isso um erro no token 200 persiste no token 500. Esse é um problema de **arquitetura**, não de "inteligência".

O **Chain of Verification** resolve: instrui o modelo a parar, **gerar perguntas sobre o que produziu, respondê-las de forma independente** e só então entregar a versão final. É a IA **auditando o próprio trabalho**.

## Conceitos principais

### Quatro etapas

1. **Gerar** a resposta inicial.
2. **Planejar** as verificações (o modelo cria perguntas sobre a própria resposta).
3. **Executar** as verificações — cada pergunta respondida **isolada**, sem ver a resposta original.
4. **Gerar** a resposta verificada (compara verificações com a resposta original e corrige).

### O isolamento é o ponto crítico

Se o modelo verifica no **mesmo contexto** onde gerou, ele **confirma o que já disse** (viés de confirmação). A pesquisa da **Meta AI (2023)** mostrou isso. Solução: variante **factored** — cada pergunta respondida isoladamente. Na prática, faça a verificação (passo 3) numa **janela de contexto nova**.

### Fluxo de informação

| Transição | O que passa |
|---|---|
| Passo 1 → 2 | Resposta original completa (para tirar perguntas) |
| Passo 2 → 3 | **Só as perguntas** (isolamento) |
| Passo 3 → 4 | As respostas de verificação |
| No passo 4 | Resposta original + respostas de verificação (compara e corrige) |

### CoVe ≠ Chain of Thoughts

CoT melhora o **raciocínio** (pensar passo a passo); CoVe melhora a **confiabilidade** (checar fatos). No Wikidata, CoVe mais que dobrou a precisão vs. few-shot (0,17 → 0,36) e reduziu entidades alucinadas (2,95 → 0,068). Trade-off: é mais **conservador** — erra menos, mas responde menos.

### As 4 variantes (Meta AI 2023), da pior à melhor

1. **Joint** — tudo num prompt (sofre viés de confirmação).
2. **Two-Step** — planejar e executar separados, mesmo contexto.
3. **Factored** — cada pergunta em prompt separado, sem a resposta original.
4. **Factor+Revise** — factored + cross-check explícito antes da resposta final (**melhor resultado**; é o usado nas demos).

> Regra de ouro: se só der para isolar um passo, isole o **passo 3**.

## Prompts da aula

<details>
<summary>Demo 1 — Churrasco (ciclo CoVe em 4 passos)</summary>

```markdown
# Passo 1 (Chat 1) — plano inicial
Estou organizando um churrasco para 20 pessoas no próximo sábado.
O grupo inclui 3 vegetarianos e 2 crianças. O churrasco começa às 12h
e o espaço tem apenas uma churrasqueira pequena (4 espetos). Orçamento máximo: R$800.

Monte um plano completo: lista de compras com quantidades e preços estimados,
o que preparar na véspera e o cronograma do dia.
```

```markdown
# Passo 2 (Chat 1) — perguntas de verificação
Agora analise o plano que você acabou de gerar e crie perguntas de
verificação sobre os pontos críticos dele.

Crie perguntas cobrindo: quantidades suficientes; restrições alimentares
(vegetarianos, crianças); cronograma viável com a churrasqueira; orçamento;
itens essenciais esquecidos.

IMPORTANTE: formule as perguntas como perguntas sobre planejamento de churrasco,
não como perguntas sobre o plano. Elas serão respondidas por alguém que NÃO
terá acesso ao plano. Retorne APENAS as perguntas, sem respondê-las.
```

```markdown
# Passo 3 (Chat 2 - janela NOVA, sem o plano) — responder isolado
Responda as seguintes perguntas sobre planejamento de churrasco para 20 pessoas
(3 vegetarianos, 2 crianças, churrasqueira pequena de 4 espetos, orçamento R$800):

[colar APENAS as perguntas do Chat 1, sem o plano]

Responda cada uma de forma direta e objetiva, com base no seu conhecimento.
```

```markdown
# Passo 4 (Chat 1) — revisão e correção
Aqui estão as respostas de verificação feitas por um especialista independente
que NÃO viu o plano original:

[colar as respostas do Chat 2]

Compare com o plano que você gerou e identifique: 1. o que está errado/incompleto;
2. quais correções; 3. o plano corrigido e completo.
```

</details>

<details>
<summary>Demo 2 — Terraform (CoVe aplicado a IaC)</summary>

```markdown
# Passo 1 (Chat 1) — gerar o Terraform (sem mencionar segurança de propósito)
Gere uma configuração Terraform para uma aplicação web na AWS com:
- VPC com subnets públicas e privadas
- RDS PostgreSQL
- EKS cluster com 2 node groups
- Application Load Balancer
- Security groups para cada componente
Gere o código completo e pronto para aplicar.
```

```markdown
# Passo 2 (Chat 1) — 5 perguntas de boas práticas (sim/não)
Analise a configuração Terraform que você acabou de gerar e identifique os 5
pontos mais críticos de segurança e boas práticas que podem estar errados ou faltando.

Para cada ponto, gere UMA pergunta curta de sim/não.
Exemplo: "RDS PostgreSQL deve ter encryption at rest habilitado?"
Regras: máximo 5; só sim/não; foque em segurança e resiliência; formule como
boas práticas, não sobre o código. Retorne APENAS as perguntas.
```

```markdown
# Passo 3 (Chat 2 - janela NOVA) — responder sobre boas práticas AWS, sem o Terraform
[colar as perguntas; responder cada uma com base em boas práticas, não no código]
```

```markdown
# Passo 4 (Chat 1) — corrigir o Terraform
Aqui vão as respostas de verificação feitas por um especialista independente
que não viu o código Terraform. Compare com as boas práticas, identifique o
que está faltando, corrija o Terraform, adicione comentários e retorne o código corrigido.

[colar as respostas do Chat 2]
```

</details>

## Pegadinhas

- Pedir só "revise a resposta" é **vago** — o modelo tende a dizer que está tudo certo. Perguntas específicas + isolamento fazem a diferença.
- Nos agentes, o isolamento vem **de graça** com **subagentes** (janela de contexto própria) — o agente principal delega a verificação.
- Mais prompts = mais tokens. Use quando o output tem **impacto real** (vai para produção).

### Quando usar / não usar

- **Usar**: IaC, scripts, pipelines CI/CD, configs de segurança (SG, IAM), recomendações de arquitetura/sizing, code review (primeiro filtro), docs operacionais (runbook, post-mortem).
- **Não usar**: brainstorm, geração de ideias, rascunhos internos, exploratório.

> Regra prática: se o output vai ser **executado/aplicado/seguido**, passa pelo CoVe. Se é apoio ou exploratório, não precisa.

## Dúvidas para revisar

- Qual output crítico do meu time (Terraform, pipeline, IAM) eu colocaria num ciclo CoVe fixo?
- Como montar o passo de verificação isolada com subagentes quando eu usar agentes?
