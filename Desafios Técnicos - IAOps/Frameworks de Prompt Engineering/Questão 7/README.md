### QUESTÃO 7 - Runbook para alerta recorrente

Toda semana, em média 4 vezes, o Beacon dispara o mesmo alerta no canal de plantão: [CRITICAL] High memory usage on Chronos API pods (>85% for 10min). Quem assume o plantão gasta de 30 a 40 minutos até resolver, e o tempo varia muito porque não existe procedimento documentado. Lorraine quer um runbook que qualquer plantonista consiga seguir de ponta a ponta sem depender de quem conhece o sistema. O ambiente que o runbook precisa considerar:

Chronos roda no EKS, namespace production, 6 réplicas com HPA configurado (min 4, max 12, CPU target 70%).
Deploy via Argo CD a partir do repositório hvt/chronos-api.
Dependências diretas: Ledger (PostgreSQL) e Reactor (filas SQS).
Observabilidade: métricas expostas em /metrics, logs centralizados no Beacon, dashboards em Grafana.
Ferramentas disponíveis para o plantão: kubectl, aws cli, argocd cli.
Canal de plantão: #oncall-chronos no Slack.
Time sênior de escalação: @chronos-core (SLA de resposta: 15 minutos em horário comercial, 30 fora).
O runbook precisa cobrir os passos iniciais de diagnóstico (com os comandos específicos a rodar), a verificação esperada ao final de cada passo, os critérios objetivos para escalar para o time sênior e o critério para encerrar o incidente.

Tarefa. Aplicando o framework R-I-S-E, escrever o prompt de IA que produza esse runbook procedural completo.

Entregue. Prompt, modelo, output e justificativa mostrando como Role, Input, Steps e Expectation aparecem no prompt.

---
#### 🤖 Prompt:
```text
#ROLE
Você é um especialista DevOps sênior com mais de 15 anos de experiência em stack Kubernetes.

#INPUT
- Chronos roda no EKS, namespace production, 6 réplicas com HPA configurado (min 4, max 12, CPU target 70%).
- Deploy via Argo CD a partir do repositório hvt/chronos-api.
- Dependências diretas: Ledger (PostgreSQL) e Reactor (filas SQS).
- Observabilidade: métricas expostas em /metrics, logs centralizados no Beacon, dashboards em Grafana.
- Ferramentas disponíveis para o plantão: kubectl, aws cli, argocd cli.
- Canal de plantão: #oncall-chronos no Slack.
- Time sênior de escalação: @chronos-core (SLA de resposta: 15 minutos em horário comercial, 30 fora).

#STEPS
- Analise passos iniciais de verificação do alerta do Beacon, mantenedor de observabilidade - [CRITICAL] High memory usage on Chronos API pods (>85% for 10min)
- Verifique ao final de cada passo os critérios para escalar o time sênior
- Aalise os critérios para encerrar o incidente

#EXPECTATION
Espero um runbook completo para que qualquer usuário siga de ponta a ponta sem depender que conheçam o sistema
```
---
#### 🛠️ Modelo:
Gemini Flash 3.6

---
#### 📦 Output:
>Este runbook fornece um procedimento passo a passo padronizado para tratamento e mitigação de incidentes de **High Memory Usage** na aplicação Chronos API.
>
>---
>
># RUNBOOK: [CRITICAL] High Memory Usage on Chronos API
>
>**Serviço:** Chronos API | **Namespace:** `production` | **Cluster:** EKS
>
>**Severidade:** CRITICAL | **SLA de Atendimento:** 15 minutos
>
>**Escalação Sênior:** `@chronos-core` (Slack `#oncall-chronos`)
>
>---
>
>## 1. Comunicação Inicial e Preparação
>
>1. Acesse o Slack no canal `#oncall-chronos`.
>2. Abra a thread da mensagem de alerta enviada pelo Beacon e envie a seguinte mensagem:
>> 🤖 *Investigando o alerta de alta memória na Chronos API. Assumido por: @seu-nome.*
>
>
>3. Configure as variáveis de ambiente no seu terminal:
>```bash
>export NS=production
>export APP=chronos-api
>
>```
>
>
>
>---
>
>## 2. Passos Sequenciais de Verificação e Mitigação
>
>### Passo 1: Diagnóstico do Estado dos Pods e OOMKills
>
>Verifique se a pressão de memória já está provocando reinicializações (*OOMKilled*).
>
>```bash
># Verificar status dos pods, uso atual e contagem de restarts
>kubectl get pods -n $NS -l app=$APP -o wide
>kubectl top pods -n $NS -l app=$APP
>
># Checar se ocorreu OOMKilled recentemente em algum pod
>kubectl get pods -n $NS -l app=$APP -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[*].state.terminated.reason}{"\n"}{end}'
>
>```
>
>* **Critério de Validação:** Identifique se o consumo está uniforme entre as réplicas ou concentrado em pods específicos.
>* **Critério de Escalação:** Se mais de **50% dos pods estiverem em loop de `CrashLoopBackOff` por `OOMKilled**` e o tráfego da API estiver sofrendo degradação (*HTTP 5xx* elevado no Grafana), acione o time sênior imediatamente.
>
>---
>
>### Passo 2: Verificação das Dependências (Ledger e Reactor)
>
>Lixo na memória geralmente ocorre por gargalos de I/O em conexões de banco de dados travadas ou acúmulo de requisições pendentes da fila.
>
>1. **Reactor (SQS):** Verifique se o consumo de filas está acumulando requisições não processadas no Grafana ou via AWS CLI:
>```bash
>aws sqs get-queue-attributes --queue-url <URL_DA_FILA_CHRONOS> --attribute-names ApproximateNumberOfMessages
>
>```
>
>
>2. **Ledger (PostgreSQL):** No Grafana, verifique o pool de conexões (*Active Connections* e *Lock Waits*).
>
>* **Critério de Validação:** Determine se o vazamento de memória é sintoma de um travamento em dependências externas.
>* **Critério de Escalação:** Se o banco PostgreSQL (Ledger) estiver com conexões esgotadas ou o SQS acumulando mensagens de forma descontrolada sem consumo pela API, acione `@chronos-core` e o time responsável pelo banco.
>
>---
>
>### Passo 3: Verificação de Mudanças Recentes (Argo CD)
>
>Confirme se houve algum *deploy* recente que possa ter introduzido um *memory leak*.
>
>```bash
># Verificar o histórico de deploys no Argo CD
>argocd app history $APP
>
>```
>
>* **Mitigação Imediata (Rollback):** Se um deploy ocorreu nos últimos 60 minutos e coincide com a subida no gráfico do Beacon, realize o rollback via Argo CD:
>```bash
>argocd app rollback $APP <REVISION_ID>
>
>```
>
>
>* **Critério de Escalação:** Se o rollback falhar ou a sincronização do Argo CD entrar em estado `Degraded`, acione `@chronos-core`.
>
>---
>
>### Passo 4: Coleta de Evidências (Heap Dump e Logs)
>
>Antes de reiniciar os pods para mitigar a crise, colete dados para análise *post-mortem*.
>
>```bash
># Salvar logs dos pods com alto consumo
>kubectl logs -n $NS -l app=$APP --tail=500 > chronos_crash_logs.log
>
># Se a aplicação expor heap dump/pprof na porta de métricas ou admin:
># Executar comando de dump no pod com maior uso (Exemplo com pprof/gprof/node/java):
>kubectl exec -it <POD_COM_ALTA_MEMORIA> -n $NS -- curl -X POST http://localhost:8080/debug/pprof/heap > heap.dump
>
>```
>
>* **Critério de Escalação:** Se não for possível identificar a causa nem gerar os artefatos de diagnóstico e a memória continuar em nível crítico (>90%), solicite apoio do `@chronos-core`.
>
>---
>
>### Passo 5: Ação de Mitigação de Emergência (Restart Gradual)
>
>Caso não haja deploy recente para rollback e a memória esteja próxima de 100%, faça um *restart* controlado para liberar o consumo sem causar *downtime*.
>
>```bash
># Reinício gradual do Deployment
>kubectl rollout restart deployment/$APP -n $NS
>
># Acompanhar o rollout
>kubectl rollout status deployment/$APP -n $NS
>
>```
>
>---
>
>## 3. Critérios Gerais para Escalação ao Time Sênior (`@chronos-core`)
>
>Acione a escalação no canal `#oncall-chronos` marcando `@chronos-core` se **qualquer** uma das condições abaixo for atingida:
>
>* **SLA de Resposta Esperado:** 15 min (horário comercial) / 30 min (fora do horário comercial).
>* **Condições:**
>1. O *Restart* dos pods não reduziu a memória (o consumo volta a subir para >85% em menos de 5 minutos).
>2. O HPA atingiu o limite máximo (12 réplicas) e todas continuam com uso de memória >85%.
>3. Aumento na taxa de erros `HTTP 5xx` da Chronos API acima de 5% por mais de 5 minutos.
>4. Falha em dependências críticas (PostgreSQL ou SQS) que impeça a liberação da memória da API.
>
>
>
>---
>
>## 4. Critérios para Encerramento do Incidente
>
>O incidente só poderá ser considerado **RESOLVIDO** e encerrado quando todos os itens abaixo forem atendidos:
>
>1. **Uso de Memória Estabilizado:** O consumo de memória dos pods da Chronos API permanecer abaixo de **70% por no mínimo 15 minutos contínuos**.
>2. **Estabilidade das Réplicas:** NENHUM pod em estado `OOMKilled` ou `CrashLoopBackOff` nos últimos 15 minutos.
>3. **Métricas de Negócio Normalizadas:** Taxa de erro `HTTP 5xx` zerada ou dentro da margem padrão (<0.1%) e latência no `/metrics` normalizada.
>4. **Notificação de Fechamento:** Atualização registrada no Slack `#oncall-chronos`:
>> ✅ *Incidente resolvido. Consumo de memória estabilizado em X%. Causas preliminares: [Descrever causa]. Post-mortem será aberto se necessário.*

---
#### 💡 Justificativa: 
Acho que nesse caso o INPUT e o STEPS ficaram um pouco misturados, mas deu pra destrinchar e escrevi as informações prévias no INPUT mesmo e deixando o STEPS com a parte de o que fazer, do que simplesmente informações que já estavam o INPUT.