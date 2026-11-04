# Tree of Thoughts (ToT)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 05 — ToT (18:48) |
| **Assunto** | Ramificar o raciocínio em caminhos/perspectivas, avaliar trade-offs e escolher a melhor opção |
| **Data** | 03/11/2026 23:50 |
| **Tags** | tree-of-thoughts, tot, ramificacao, trade-offs, decisao-arquitetural, migracao-cloud, personas |

> Os prompts abaixo foram transcritos da narração da aula (o instrutor lê cada prompt em tela). A redação exata do material "Código da Aula" pode ter pequenas diferenças de formatação.

## Resumo da aula

Enquanto o CoT cria uma linha de raciocínio **linear** (uma resposta definitiva), o **Tree of Thoughts** cria **ramificações** — múltiplos caminhos ou perspectivas de raciocínio. O modelo gera alternativas, avalia os trade-offs e, no fim, **seleciona a melhor opção**. É como um prompt de brainstorm estruturado: várias hipóteses, análise de todas, escolha de uma.

Caso típico: definir uma arquitetura analisando o cenário sob a ótica de um dev, de um arquiteto de cloud e de um SRE, cada um com sua cadeia de raciocínio, e então escolher a melhor solução.

## Conceitos principais

### CoT vs. ToT — quando usar cada um

| Pergunta | Técnica |
|---|---|
| Existe **uma resposta definitiva**? (diagnóstico, causa raiz, troubleshooting, análise de log, revisão de código) | **Chain of Thoughts** |
| Existem **múltiplas opções/abordagens** válidas? (decisão arquitetural, trade-offs, estratégias de migração, escalabilidade, segurança) | **Tree of Thoughts** |

Regra do instrutor: toda vez que a resposta honesta seria *"depende"*, o CoT não atende — use ToT.

### Como estruturar o prompt ToT

Evolução do CoT: além dos **tópicos de análise**, você adiciona **alternativas/estratégias** e **perspectivas (personas)**. Cada persona analisa cada estratégia pelos mesmos critérios, debatem os trade-offs e chegam a uma recomendação consensual.

### Desvantagens

- **Latência maior** (várias análises).
- **Consumo de tokens maior** (input maior + output que é, na prática, N análises).

Compensa em cenários complexos (ex.: war room com várias especialidades).

## Prompts da aula

<details>
<summary>Prompts Tree of Thoughts (transcritos da aula)</summary>

```markdown
# Prompt 1 — Escolha de vaga (3 consultores debatendo)
Imagine três consultores de carreira experientes avaliando minha situação. Cada um apresenta sua análise considerando as três ofertas, debatem os trade-offs entre si e chegam a uma recomendação consensual.

Contexto: 28 anos, moro sozinho, prefiro trabalho remoto, quero crescer na área de IA, preciso de estabilidade financeira no curto prazo, 2 anos de experiência em cloud.

Ofertas:
- Empresa A (startup): R$ 8 mil, 100% remoto, área de IA, stock options, risco alto
- Empresa B (empresa grande): R$ 12 mil, híbrido 3x/semana, área de DevOps, estabilidade alta
- Consultoria: R$ 10 mil, presencial + viagens, múltiplos projetos, networking intenso
```

```markdown
# Prompt 2 — Estratégia de migração para a cloud (3 estratégias avaliadas)
Avalie três estratégias de migração para o nosso sistema de e-commerce (3 servidores web, PostgreSQL, processamento síncrono, pico na Black Friday).

Estratégia 1 — Lift and shift: EC2 + RDS, migração direta sem mudança de arquitetura
Estratégia 2 — Replatform: containers no ECS + RDS + SQS para processamento assíncrono
Estratégia 3 — Refactoring: serverless com Lambda + API Gateway + DynamoDB

Para cada estratégia, analise: como resolve o pico da Black Friday, principais vantagens para este contexto, principais riscos e limitações, complexidade de migração (baixa/média/alta).

Após avaliar as três, recomende a melhor considerando: equipe de 4 engenheiros, prazo de 3 meses, sem downtime tolerável.
```

```markdown
# Prompt 3 — Plano de escalabilidade (3 especialistas x 3 estratégias x critérios)
Imagine três especialistas sêniores avaliando a seguinte decisão de escalabilidade. Cada um apresenta sua análise, debatem os trade-offs entre si e chegam a uma recomendação consensual.

Perfis:
- Especialista em desenvolvimento: foco em complexidade de código, refatoração, ciclo de desenvolvimento
- Especialista em cloud: foco em AWS, custo, infraestrutura
- Especialista em SRE: foco em operação, observabilidade, resiliência

Contexto: API REST em EC2 m5.xlarge (4 vCPU, 16 GB). Hoje: 1.000 req/s. Meta: 10.000 req/s com latência de 120 ms.

Estratégias a avaliar:
1. Escalabilidade vertical (upgrade da máquina)
2. Escalabilidade horizontal (auto scaling group com instâncias menores)
3. Serverless

Cada especialista deve analisar cada estratégia por: viabilidade técnica, custo, complexidade, risco operacional e escalabilidade futura.
```

</details>

## Pegadinhas

- Não confundir com **Self-Consistency**: no ToT você **escolhe a melhor** alternativa; no Self-Consistency você busca os **pontos em comum** entre as alternativas.
- ToT é mais lento e mais caro — reserve para decisões com múltiplos caminhos válidos.

## Dúvidas para revisar

- Quais decisões de arquitetura do meu time se beneficiariam de um "painel" de personas (dev/cloud/SRE)?
- Quando a resposta é "depende", qual conjunto de critérios eu sempre quero impor na avaliação?
