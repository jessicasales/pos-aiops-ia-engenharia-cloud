### QUESTÃO 3 - Relatório de redução de custos cloud

>Goldie apresentou a meta do próximo trimestre à diretoria: 15% de redução no custo cloud até o fim do período, sem degradar SLA. Doc Brown pegou o breakdown de custos AWS do último mês e repassou a análise inicial para o time. O CSV está abaixo.
>
>```csv
>servico,categoria,custo_mensal_usd,uso_medio_pct,observacao
>EC2 reservada,compute,4200,72,contrato de 1 ano
>EC2 on-demand,compute,8200,45,workloads variaveis
>EKS,compute,6700,58,3 clusters
>RDS PostgreSQL,databases,8200,62,multi-AZ
>ElastiCache Redis,databases,2100,40,cluster de producao
>S3 Standard,storage,3100,,5 buckets principais
>EBS gp3,storage,1600,68,volumes de producao
>CloudWatch Logs,observability,2800,,retencao de 90 dias
>CloudWatch Metrics,observability,900,,
>Data Transfer Out,network,1900,,trafego entre regioes
>NAT Gateway,network,1200,,3 gateways ativos
>Lambda,compute,900,30,~12M invocacoes/mes
>```
>O relatório que vai voltar pra Goldie precisa trazer as oportunidades de economia priorizadas por impacto, quanto cada uma representa em percentual da conta total, o esforço de implementação (baixo, médio, alto) e os riscos ou pré-requisitos envolvidos em cada uma.
>
>**Tarefa**. Aplicando o framework T-A-G, escrever o prompt de IA que, a partir do CSV acima, produza esse relatório alinhado à meta de 15%.
>
>**Entregue**. Prompt, modelo, output e justificativa mostrando como Task, Action e Goal aparecem no prompt.
>
---
#### 🤖 Prompt:
```#Task
#Task
Você é um especialista em Cloud AWS já com ampla experiência. Analise o csv

#Action
Organize oportunidades de economia priorizadas por impacto, quanto cada uma representa em percentual da conta total, o esforço de implementação (baixo, médio, alto) e os riscos ou pré-requisitos envolvidos ema cada uma.

#Goal
Objetivo: reduzir em 15% mostrando oportunidades de economia, quanto cada uma representa em percentual da conta total, o esforço de implementação (baixo, médio, alto) e os riscos ou pré-requisitos envolvidos em cada uma.

csv: 
servico,categoria,custo_mensal_usd,uso_medio_pct,observacao
EC2 reservada,compute,4200,72,contrato de 1 ano
EC2 on-demand,compute,8200,45,workloads variaveis
EKS,compute,6700,58,3 clusters
RDS PostgreSQL,databases,8200,62,multi-AZ
ElastiCache Redis,databases,2100,40,cluster de producao
S3 Standard,storage,3100,,5 buckets principais
EBS gp3,storage,1600,68,volumes de producao
CloudWatch Logs,observability,2800,,retencao de 90 dias
CloudWatch Metrics,observability,900,,
Data Transfer Out,network,1900,,trafego entre regioes
NAT Gateway,network,1200,,3 gateways ativos
Lambda,compute,900,30,~12M invocacoes/mes
```
---
#### 🛠️ Modelo:
ChatGPT - GPT-5.5

---

#### 📦 Output:

># Análise de Oportunidades de Economia AWS
>
>## Resumo da Conta
>
>| Serviço | Custo Mensal (USD) | % da Conta |
>|---------|-------------------:|-----------:|
>| EC2 On-Demand | 8.200 | 25,5% |
>| RDS PostgreSQL | 8.200 | 25,5% |
>| EKS | 6.700 | 20,8% |
>| EC2 Reservada | 4.200 | 13,0% |
>| S3 Standard | 3.100 | 9,6% |
>| CloudWatch Logs | 2.800 | 8,7% |
>| ElastiCache Redis | 2.100 | 6,5% |
>| Data Transfer Out | 1.900 | 5,9% |
>| EBS gp3 | 1.600 | 5,0% |
>| NAT Gateway | 1.200 | 3,7% |
>| CloudWatch Metrics | 900 | 2,8% |
>| Lambda | 900 | 2,8% |
>
>**Custo total mensal:** **USD 32.000**
>
>**Meta de redução (15%):** **USD 4.800/mês**
>
>---
>
># Oportunidades de Economia Priorizadas
>
>| Prioridade | Oportunidade | Economia Estimada (USD/mês) | % da Conta Total | Esforço | Riscos / Pré-requisitos |
>|------------|--------------|----------------------------:|----------------:|---------|-------------------------|
>| ⭐⭐⭐⭐⭐ | Otimizar EC2 On-Demand (Savings Plans, Rightsizing e Auto Scaling) | **2.000** | **6,3%** | Médio | Analisar utilização real das instâncias; workloads precisam possuir perfil de uso conhecido antes da contratação de Savings Plans. |
>| ⭐⭐⭐⭐⭐ | Rightsizing do RDS PostgreSQL | **1.200** | **3,8%** | Médio | Validar consumo de CPU, memória, IOPS e janela de manutenção antes da alteração da classe das instâncias. |
>| ⭐⭐⭐⭐ | Otimização do EKS (Cluster Autoscaler, Karpenter e Spot Nodes) | **900** | **2,8%** | Médio/Alto | Aplicações devem suportar interrupções caso sejam utilizados Spot Instances. |
>| ⭐⭐⭐⭐ | Redução da retenção do CloudWatch Logs | **800** | **2,5%** | Baixo | Confirmar requisitos regulatórios, auditoria e compliance antes de reduzir o período de retenção. |
>| ⭐⭐⭐ | Otimização do S3 (Lifecycle e Intelligent-Tiering) | **600** | **1,9%** | Baixo | Garantir que objetos migrados para classes mais baratas possuam baixa frequência de acesso. |
>| ⭐⭐⭐ | Otimização do NAT Gateway | **300** | **0,9%** | Médio | Revisar arquitetura de rede e utilização de VPC Endpoints para reduzir tráfego via NAT. |
>| ⭐⭐ | Otimização do EBS gp3 | **250** | **0,8%** | Baixo | Confirmar que volumes e snapshots não estejam sendo utilizados antes da remoção. |
>| ⭐⭐ | Rightsizing do ElastiCache Redis | **250** | **0,8%** | Médio | Monitorar utilização de memória e latência para evitar degradação de desempenho. |
>
>## Economia Potencial
>
>| Cenário | Economia |
>|---------|---------:|
>| Conservador | USD 4.800/mês |
>| Potencial | USD 6.300/mês |
>
>A meta de redução de **15%** pode ser alcançada sem mudanças arquiteturais significativas.
>
>---
>
># Plano Recomendado (Quick Wins)
>
>## 1. EC2 On-Demand (Maior Impacto)
>
>### Situação
>
>- Representa **25,5% da conta total**.
>- Utilização média de apenas **45%**, indicando possibilidade de superdimensionamento.
>
>### Ações Recomendadas
>
>- Realizar Rightsizing das instâncias.
>- Contratar Savings Plans para workloads previsíveis.
>- Revisar políticas de Auto Scaling.
>- Desligar ambientes de desenvolvimento e homologação fora do horário comercial.
>- Utilizar Spot Instances para workloads tolerantes à interrupção.
>
>### Economia Estimada
>
>**≈ USD 2.000/mês**
>
>---
>
>## 2. RDS PostgreSQL
>
>### Situação
>
>- Representa **25,5% da conta**.
>- Utilização média de **62%**, indicando espaço para otimização.
>
>### Ações Recomendadas
>
>- Rightsizing das instâncias.
>- Contratação de Reserved Instances para ambientes estáveis.
>- Revisão do armazenamento provisionado.
>- Avaliação da necessidade de réplicas adicionais.
>
>### Economia Estimada
>
>**≈ USD 1.200/mês**
>
>---
>
>## 3. Amazon EKS
>
>### Situação
>
>- Três clusters representam **20,8% da conta**.
>
>### Ações Recomendadas
>
>- Implantar Cluster Autoscaler.
>- Adotar Karpenter para provisionamento dinâmico.
>- Utilizar Spot Nodes quando possível.
>- Consolidar clusters com baixa utilização.
>- Revisar requests e limits dos pods.
>
>### Economia Estimada
>
>**≈ USD 900/mês**
>
>---
>
>## 4. CloudWatch Logs
>
>### Situação
>
>- Retenção configurada para **90 dias**.
>
>### Ações Recomendadas
>
>- Reduzir retenção para 30 ou 45 dias.
>- Exportar logs antigos para Amazon S3.
>- Aplicar compressão quando aplicável.
>
>### Economia Estimada
>
>**≈ USD 800/mês**
>
>---
>
>## 5. Amazon S3
>
>### Ações Recomendadas
>
>- Configurar Lifecycle Policies.
>- Utilizar Intelligent-Tiering.
>- Migrar objetos antigos para Glacier Instant Retrieval ou Glacier Flexible Retrieval.
>
>### Economia Estimada
>
>**≈ USD 600/mês**
>
>---
>
>## 6. Rede
>
>### NAT Gateway
>
>#### Situação
>
>- Existem **3 NAT Gateways ativos**.
>
>#### Ações Recomendadas
>
>- Implementar VPC Endpoints para serviços como Amazon S3 e DynamoDB.
>- Revisar fluxos de tráfego entre sub-redes.
>- Consolidar NAT Gateways quando possível.
>
>### Economia Estimada
>
>**≈ USD 300/mês**
>
>---
>
>## 7. Amazon EBS
>
>### Ações Recomendadas
>
>- Remover volumes órfãos.
>- Excluir snapshots antigos.
>- Ajustar volumes superdimensionados.
>
>### Economia Estimada
>
>**≈ USD 250/mês**
>
>---
>
>## 8. ElastiCache Redis
>
>### Situação
>
>- Utilização média de **40%**.
>
>### Ações Recomendadas
>
>- Rightsizing do cluster.
>- Revisar quantidade de nós.
>- Utilizar Reserved Nodes para cargas previsíveis.
>
>### Economia Estimada
>
>**≈ USD 250/mês**
>
>---
>
># Roadmap de Implementação
>
>| Fase | Itens | Economia Acumulada |
>|------|-------|-------------------:|
>| **Semana 1** | CloudWatch Logs, S3 e EBS | USD 1.650 |
>| **Semanas 2–3** | EC2 On-Demand | USD 3.650 |
>| **Semanas 3–4** | RDS PostgreSQL | USD 4.850 |
>| **Mês 2** | EKS, NAT Gateway e ElastiCache | USD 6.300 |
>
>---
>
># Conclusão
>
>A análise demonstra que aproximadamente **72% dos custos mensais** estão concentrados em **EC2 On-Demand, RDS PostgreSQL e Amazon EKS**, tornando esses serviços as principais oportunidades de otimização.
>
>As recomendações priorizam ações de baixo e médio esforço, como Rightsizing, Savings Plans, otimização de armazenamento e ajustes de retenção de logs, permitindo atingir a meta de **15% de redução dos custos (USD 4.800/mês)** sem necessidade de mudanças arquiteturais profundas.
>
>O potencial de economia identificado é de aproximadamente **USD 6.300/mês**, equivalente a **19,7% da fatura mensal**, proporcionando uma margem confortável acima da meta estabelecida.
>
---
#### 💡 Justificativa: 
Preferi escrever na Task a função mais genérica que é analisar o csv passando que ele tem expertise em uma área necessária pra análise da solução.

Em Action, dei o detalhamento do que seria a task de análise do CSV.

Em Goal escrevi o objetivo central: a oportunidade de redução
