# Step-Back Prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 08 — Step back (19:48) |
| **Assunto** | Levantar os princípios/conceitos fundamentais antes de resolver o problema |
| **Data** | 03/11/2026 23:50 |
| **Tags** | step-back, google, principios-fundamentais, contexto-previo, crashloopbackoff, vpc, combinacao-de-tecnicas |

> Prompts transcritos da narração da aula; a formatação exata do material pode variar.

## Resumo da aula

Técnica criada pelo **Google**. A ideia: **dar um passo atrás** e, antes de resolver, fazer o modelo levantar os **conceitos/princípios fundamentais** em torno do problema. Isso **enriquece o contexto** e direciona a análise, reduzindo viés e alucinação.

Enquanto CoT/ToT/Self-Consistency vão **direto** para a resolução, o Step-Back força uma **reflexão prévia sobre os conceitos** e só depois mergulha no detalhe — igual ao que fazemos para resolver um problema: revisão mental dos conceitos, visão geral e aí a análise.

## Conceitos principais

### Por que funciona

- Ao levantar os conceitos **primeiro**, eles entram no contexto como informação **recente** e ganham peso na geração.
- Conecta com a regra do capítulo anterior: início e fim do prompt pesam mais; o Step-Back carrega o contexto conceitual logo no começo.
- Analogia do instrutor: é o "cafezinho fresquinho" — contexto fresco para o modelo usar na análise.

### Estrutura do prompt

1. Enuncie a tarefa/problema.
2. **"Antes de [diagnosticar/recomendar], dê um passo atrás e responda:"** → peça os princípios fundamentais.
3. **"Depois, use esses princípios para [resolver]."**

### Combina com outras técnicas

Step-Back na frente + CoT (tópicos de raciocínio) ou + Self-Consistency (múltiplas perspectivas) na análise final. É aí que extrai o máximo do modelo.

### Quando usar

Comparações para requisitos (carro, notebook, instância), análise de post-mortem, decisões de arquitetura — toda tarefa que precisa levantar um conceito técnico inicial.

### Quando NÃO usar

Tarefas simples. Além disso, **alto consumo de tokens de output** (levanta conceitos + faz a análise).

## Prompts da aula

<details>
<summary>Prompts Step-Back (transcritos da aula)</summary>

```markdown
# Prompt 1 — Compra de carro (TCO)
Preciso comprar um carro com orçamento de R$ 100 mil, para uso urbano, rodando ~30 km por dia no trânsito de São Paulo. Qual carro você recomenda?

Antes de recomendar, dê um passo atrás e responda: quais são os princípios fundamentais para avaliar o custo total de propriedade (TCO) de um veículo para uso urbano? Considere depreciação, consumo, manutenção, seguro e revenda.

Depois, use esses princípios para recomendar o melhor carro para o meu cenário. Considere carro a combustão e carro elétrico.
```

```markdown
# Prompt 2 — Pod em CrashLoopBackOff (memória no Kubernetes)
Tenho um pod do payment-service em CrashLoopBackOff no Kubernetes. Os logs mostram o container sendo encerrado por OOMKilled, exit code 137. [incluir quantidade de restarts, requests/limits e uso de memória antes do crash]

Antes de diagnosticar, dê um passo atrás e responda: quais são os princípios fundamentais de gerenciamento de memória em containers no Kubernetes? Como request e limit trabalham? O que é OOMKilled?

Depois, use esses princípios para diagnosticar o problema e sugerir as soluções.
```

```markdown
# Prompt 3 — Conectividade entre serviços na VPC AWS
O serviço order-service (subnet privada) não consegue se conectar ao inventory-service (subnet privada) na porta 8080. Ambos estão na mesma VPC e o Security Group permite inbound. [incluir CIDRs das subnets]

Antes de diagnosticar, dê um passo atrás e responda: quais são as camadas de controle de tráfego em uma VPC da AWS (route table, Network ACL, Security Group, DNS)?

Depois, use esses princípios para diagnosticar o problema.
```

</details>

## Pegadinhas

- Não é só "pense passo a passo": o diferencial é levantar os **conceitos fundamentais** antes da análise.
- Output grande → caro. Reserve para tarefas que precisam de base conceitual.
- O melhor uso costuma ser **combinado** (Step-Back + CoT/Self-Consistency), não isolado.

## Dúvidas para revisar

- Para quais erros recorrentes (OOMKilled, conectividade de rede) vale fixar um Step-Back que carregue os conceitos antes do diagnóstico?
- Qual combinação Step-Back + técnica de raciocínio dá o melhor custo/benefício nos meus casos de uso?
