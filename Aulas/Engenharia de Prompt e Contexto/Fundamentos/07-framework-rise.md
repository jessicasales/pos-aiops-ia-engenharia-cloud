# Framework R-I-S-E (Role, Input, Steps, Expectation)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 07 — Framework R-I-S-E (Role, Input, Steps, Expectation) (14:47) |
| **Assunto** | Framework mais estruturado (Role, Input, Steps, Expectation) para tarefas procedurais com passo a passo; primeiro passo antes do Chain of Thought |
| **Data** | 29/10/2026 22:35 |
| **Tags** | rise, role, input, steps, expectation, runbook, sre, procedural, chain-of-thought |

## Resumo da aula

Último framework da série. O **R-I-S-E (Role, Input, Steps, Expectation)** é o mais estruturado — ideal para tarefas que seguem **processos/workflows** com passo a passo. É o primeiro framework a definir uma sequência de execução, e é o passo anterior ao **Chain of Thought**. Muito usado no fluxo de Cloud/DevOps/SRE (pipelines, diagnósticos, runbooks, onboarding). Demonstrado com mudança de cidade (relocação) e runbook de OOMKilled no EKS.

## Conceitos principais

### Os 4 componentes

| Componente | Função |
|---|---|
| **Role** | Expertise e profundidade — não só quem, mas com qual nível de conhecimento/senioridade |
| **Input** | Dados concretos: logs, métricas, configs, contexto do ambiente. Sem Input o modelo inventa dados |
| **Steps** | Sequência lógica de execução — a "receita" que o modelo deve seguir. É o diferencial do framework |
| **Expectation** | Critérios de validação/sucesso — o que significa "pronto". Vai além do formato (Result do C-A-R-E) |

### Steps é o diferencial

É o único framework que define ordem de etapas e o que acontece em cada uma — garante que nada seja pulado e que a sequência lógica seja respeitada.

### Expectation amarra a entrega

Define quando o modelo "terminou" e se o resultado está completo. O modelo só para quando a expectativa é cumprida (critérios de escalação, tempo máximo por etapa, critério de rollback).

### Quando usar

- Tarefas procedurais com sequência definida: runbooks, diagnósticos passo a passo (Kubernetes, cloud), onboarding de serviço, plano de migração com milestones, investigação com metodologia, automação de pipelines e implementação de código.

### Quando NÃO usar

- Tarefas criativas ou abertas onde os Steps engessariam: brainstorm de ideias, soluções de arquitetura abertas ("me dê ideias para melhorar a observabilidade"), criação de conteúdo livre, respostas conceituais/explicações.

## Prompts da aula

<details>
<summary>Prompts R-I-S-E</summary>

```markdown
# Runbook de resposta a incidente OOMKilled
# Role
Você é um SRE sênior com 8 anos de experiência em Kubernetes, observabilidade com Prometheus e Grafana, e resposta a incidentes de alta severidade (SEV1/SEV2) em ambientes de produção AWS.
# Input
- Ambiente: cluster EKS (Kubernetes 1.29) com 15 nodes em us-east-1
- Serviço afetado: API de pagamentos (namespace: payments)
- Sintoma: 3 pods em OOMKilled nos últimos 30 minutos
- Configuração atual: memory request 512Mi, memory limit 1Gi
- Prometheus mostra consumo de memória crescente desde o deploy v2.4.1 (há 2 horas)
- Nenhum outro namespace afetado
- SLA do serviço: 99.95% uptime, latência p99 < 500ms
# Steps
1. Confirmar o estado atual dos pods e coletar logs de OOMKilled
2. Analisar métricas de memória no Prometheus (últimas 4 horas, correlacionar com o deploy)
3. Verificar se o problema é no container principal ou no sidecar (istio-proxy/envoy)
4. Avaliar se é memory leak ou se o sizing está subdimensionado
5. Definir ação imediata de mitigação (ajuste de limits, rollback ou scale horizontal)
6. Documentar critérios de escalação (quando envolver o time de desenvolvimento)
7. Propor ajustes definitivos e critério de validação pós-fix
# Expectation
Espero um runbook operacional completo com:
- Comandos kubectl prontos para copiar e colar em cada etapa
- Queries PromQL para investigação de memória
- Árvore de decisão: leak vs subdimensionamento → ação correspondente
- Tempo máximo por etapa (total não deve passar de 45 minutos)
- Critérios claros de quando escalar para SEV1 e acionar o time de desenvolvimento
- Critério de rollback: quando reverter para v2.3.9 ao invés de tentar ajustar
```

```markdown
# Mudança de cidade com checklist completo (exemplo não técnico)
# Role
Você é um consultor de relocação com 15 anos de experiência em mudanças interestaduais no Brasil, especializado em famílias com crianças.
# Input
- Família: casal + 2 filhos (8 e 12 anos, em idade escolar)
- Origem: São Paulo/SP (apartamento alugado, 90m²)
- Destino: Florianópolis/SC (bairro a definir)
- Orçamento total para mudança: R$ 15.000
- Prazo: 60 dias a partir de hoje
- Ambos os pais trabalham remoto
- Prioridades: qualidade de vida, boas escolas, custo de vida menor
# Steps
1. Analisar custo de vida comparativo SP vs Florianópolis (moradia, alimentação, transporte, educação)
2. Recomendar 3 bairros em Florianópolis que atendam as prioridades da família
3. Listar escolas particulares e públicas bem avaliadas nos bairros recomendados
4. Estimar custos detalhados da mudança (frete, viagem, depósito do aluguel, primeiros meses)
5. Montar cronograma de 60 dias com marcos semanais
6. Criar checklist de documentação e providências (transferência escolar, endereço, contas)
# Expectation
Espero um plano de ação completo em formato de documento estruturado com:
- Tabela comparativa de custos SP vs Florianópolis
- Ranking dos 3 bairros com prós e contras
- Cronograma visual com marcos semanais e responsáveis
- Checklist final com critério de conclusão para cada item
- Orçamento detalhado que não ultrapasse R$ 15.000
```

</details>

## Pegadinhas

- O Gemini **não faz busca na internet** por padrão — dados de custo de vida, escolas e serviços podem estar desatualizados. Para esses cenários, use uma ferramenta com busca (engenharia de contexto, vista adiante).
- R-I-S-E produz um **plano de ação / runbook** a executar, não a resposta final com dados reais (o modelo não tem acesso ao cluster). A execução real vem com ferramentas de codificação nos próximos módulos.
- Não use R-I-S-E em tarefas sem fluxo linear — engessa o resultado.

## Dúvidas para revisar

- Como esse runbook R-I-S-E será executado de fato por uma ferramenta de codificação (a IA rodando as queries kubectl/PromQL) nos próximos módulos?
- Qual a transição do R-I-S-E para o Chain of Thought — o que o CoT adiciona sobre os Steps?
