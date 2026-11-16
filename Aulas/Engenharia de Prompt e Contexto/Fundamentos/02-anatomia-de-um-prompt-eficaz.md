# Anatomia de um Prompt Eficaz

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 02 — Anatomia de um Prompt Eficaz (33:53) |
| **Assunto** | Os 4 componentes base de um prompt (Role, Contexto, Instrução, Output) e como cada um muda a resposta da IA |
| **Data** | 29/10/2026 22:35 |
| **Tags** | role, contexto, instrucao, output, json-schema, prompt-estruturado, markdown |

## Resumo da aula

Antes de entrar em frameworks e técnicas (chain-of-thought, few-shot), o instrutor cobre o básico: a estrutura universal de um prompt profissional. A analogia é o restaurante — "me traz comida" não funciona; "filé mignon, batata frita, sem salada, molho à parte" funciona. Um prompt eficaz tem **4 componentes base**: Role, Contexto, Instrução (restrições) e Output. Cada um é demonstrado isoladamente no Gemini para mostrar o impacto individual, e depois combinados.

## Conceitos principais

### Os 4 componentes base

| Componente | Função | Pergunta que responde |
|---|---|---|
| **Role** | Define quem o modelo é e a área de conhecimento | Quem é o modelo? |
| **Contexto** | Informações do cenário/ambiente do problema | Qual o cenário? |
| **Instrução** | A tarefa a executar + restrições (o que fazer e o que NÃO fazer) | O que fazer? |
| **Output** | Formato de entrega da resposta | Como entregar? |

### Role muda a base de conhecimento consultada

Exemplo "manga": sem role, o modelo mistura fruta, peça de roupa e mangá. Com role de alfaiate → fala de manga de camisa; de hortifruti → variedades de fruta; de otaku → categorias de mangá. A role direciona a perspectiva.

### Contexto direciona a investigação

Pergunta genérica de latência → lista vaga que serve para tudo. Mesma pergunta com stack, sintoma e métricas (Node.js no ECS Fargate, PostgreSQL no RDS, latência subiu após deploy, RDS em 85% CPU) → o modelo aponta causas prováveis reais (N+1, falta de índice, plano de query).

### Instrução precisa de verbo específico

"Me ajuda com Kubernetes" → o modelo adivinha. "Explique a diferença entre Deployment, StatefulSet e DaemonSet", "Compare ECS Fargate e EKS", "Recomende uma estratégia blue-green" → verbo claro define a entrega. Vale também dizer **o que NÃO fazer** (restrições).

### Output garante formato consumível

Sem formato → texto corrido. Com formato (tabela Markdown, JSON, ou JSON schema explícito) → saída previsível e integrável. Crítico para agentes que integram com outros serviços (contrato de dados em JSON/YAML).

## Prompts da aula

<details>
<summary>Prompts de Role, Contexto, Instrução e Output (demonstrações)</summary>

```text
# Role — sem persona
Me fale sobre manga

# Role — alfaiate
Você é um alfaiate especializado em camisas sob medida.
Me fale sobre manga.

# Role — hortifruti
Você é um especialista em frutas tropicais que trabalha num hortifruti.
Me fale sobre manga.

# Role — otaku
Você é um especialista em cultura pop japonesa e dono de uma loja de mangás.
Me fale sobre manga.
```

```text
# Contexto — sem contexto
Como reduzir a latência da minha aplicação?

# Contexto — com contexto técnico
Temos uma API em Node.js rodando no ECS Fargate, com banco PostgreSQL no RDS.
A latência do endpoint /pedidos subiu de 200ms para 1.2s após o deploy de sexta.
O RDS está em 85% de CPU. Não houve mudança de infra, apenas código.
Como reduzir a latência?
```

```text
# Instrução — vaga
Me ajuda com Kubernetes.

# Instrução — específicas
Explique a diferença entre Deployment, StatefulSet e DaemonSet no Kubernetes.
Compare ECS Fargate e EKS para rodar microsserviços de uma startup com 3 desenvolvedores.
Recomende uma estratégia de deploy blue-green para uma API que não pode ter downtime.
```

```text
# Output — tabela Markdown
Liste os serviços AWS para hospedar containers.
Formato: tabela Markdown com colunas Serviço | Tipo (serverless/managed) | Caso de uso ideal | Custo relativo.
Máximo 5 serviços. Ordene do mais simples ao mais complexo.

# Output — JSON com schema explícito
Liste os 5 alertas mais comuns em clusters Kubernetes.
Formato: array JSON seguindo este schema:
{
  "alert_name": "string",
  "severity": "critical | warning | info",
  "component": "string",
  "typical_cause": "string",
  "first_action": "string (comando kubectl)"
}
Retorne apenas o JSON, sem explicações.
```

```text
# Prompt estruturado completo (4 componentes) — runbook OOMKills
# Role
Você é um SRE senior com 10 anos de experiência em Kubernetes e AWS.
# Contexto
Temos um cluster EKS com 50 nodes e estamos tendo OOMKills frequentes nos pods de API.
# Instrução
Crie um runbook de troubleshooting para diagnosticar e resolver OOMKills.
# Output
Formato: tabela Markdown com colunas Passo | Comando | O que verificar | Ação.
Máximo 10 passos. Use apenas comandos kubectl reais, não genéricos.
```

</details>

## Pegadinhas

- Dados de serviços podem vir **desatualizados** — o modelo é treinado com dados antigos e, sem busca na internet, não conhece serviços/limites atuais. Foque na estrutura e sempre valide.
- Testar em vários modelos (Gemini, Claude, OpenAI): o comportamento muda. Prompt engineering é experimentação.

## Dúvidas para revisar

- Quando usar JSON schema explícito vs. só pedir JSON? (schema = contrato fechado, ideal para integração de agentes)
- Os 4 componentes são sempre obrigatórios? Não — é uma base universal; os frameworks seguintes ajustam quais componentes usar por cenário.
