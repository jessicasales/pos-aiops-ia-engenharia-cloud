### CHECKPOINT 2 - Padronizando as notas de triagem

Toda vez que o Sentinel dispara um alerta, o plantonista abre uma nota de triagem. O problema é que hoje cada um escreve do seu jeito, e isso atrapalha quem assume o turno seguinte. A Carol Danvers quer um padrão único de nota. Atenção a uma coisa neste checkpoint: ele tem duas listas diferentes de exemplos — o formato de saída (a nota pronta) e as entradas (os alertas crus). Não misture os dois.

Formato de saída esperado — é assim que a nota pronta deve ficar. O time consolidou três exemplos do padrão que considera bom; isto é referência de formato, não é entrada do prompt:
```text
ALERTA: Relay - taxa de rejeição de ingestão acima de 2% por 5min
IMPACTO: ingestão de telemetry degradada para ~12% dos tenants
HIPÓTESE INICIAL: deploy do Relay às 09:14 reduziu o buffer de ingestão
AÇÃO IMEDIATA: rollback iniciado via Argo CD
ESCALAR PARA: @relay-core se a rejeição não cair em 10min
```
```text
ALERTA: Forge - lag de ingestão acima de 15min
IMPACTO: dashboards do Sentinel atrasados para todos os tenants
HIPÓTESE INICIAL: pico de volume do tenant acme-corp saturou o consumer
AÇÃO IMEDIATA: aumento manual de partições do consumer do Relay
ESCALAR PARA: @data-platform se lag não estabilizar em 20min
```
```text
ALERTA: Cerebro - latência de busca p99 acima de 4s
IMPACTO: investigação de incidentes lenta para o time interno
HIPÓTESE INICIAL: reindexação noturna não concluiu antes do horário comercial
AÇÃO IMEDIATA: pausar reindexação e priorizar shard quente
ESCALAR PARA: @search-infra se p99 não cair em 15min
```
Entradas para usar no prompt — agora sim, os alertas crus que o prompt recebe por parâmetro e transforma em nota. São estes três (e só estes) que você vai rodar para testar:

Entrada 1:
```text
2026-05-12 14:02:09 UTC [Sentinel] autoscaler hit max replicas (60/60) on sentinel-api,
queue depth on Relay growing 2k/min, CPU avg 88%, tenant stark-industries
sending 4x baseline volume after onboarding new region
```
Entrada 2:
```text
2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems,
buffer saturated after deploy 02:55
```
Entrada 3:
```text
2026-05-13 11:40:22 UTC [Forge] consumer lag 9min and climbing, batch forge-batch-ingest
delayed after previous job failure, downstream Sentinel starting to lag
```
Você vai construir um prompt parametrizável que produza a nota padronizada a partir de qualquer alerta cru. A decisão de método aqui é sua: dá pra ensinar esse padrão ao modelo de mais de uma forma, e é essa escolha que você vai justificar.

Tarefa. Escrever o prompt parametrizável de geração de notas de triagem (use meta-prompting para criá-lo) e executá-lo contra os três alertas crus acima.

Entregue. Prompt parametrizável, execução (modelo e output) nos exemplos e curadoria.

---
#### 🤖 Prompt:
```text
Você é um SRE Sênior de plantão (on-call). Sua tarefa é padronizar notas de alerta do sistema Sentinel em português, de forma concisa, acionável e sem alucinação.

PARÂMETROS DE ENTRADA:
1. ALERT_RAW: ```{{ALERT_RAW}}```
2. THRESHOLDS: {{THRESHOLDS | default: "Relay reject >2% por 5min = CRÍTICO; Forge lag >5min = CRÍTICO; Autoscaler max replicas >3min = ALTA"}}
3. OWNER_MAP: {{OWNER_MAP | default: "Relay=@relay-core, Forge=@forge-batch, Sentinel=@sentinel-api, Autoscaler=@platform"}}
4. CONTEXTO_EXTRA (opcional): ```{{CONTEXTO_EXTRA | default: "N/A"}}```
5. IDIOMA_SAIDA: {{IDIOMA | default: "pt-BR"}}

REGRAS:
- Traduza a entrada (geralmente em EN) para pt-BR técnico.
- NÃO invente números. Use apenas o que está em ALERT_RAW + CONTEXTO_EXTRA. Se faltar dado, escreva "desconhecido" ou "~".
- Correlacione causa provável nesta ordem: 1) deploy recente 2) saturação (buffer/queue/CPU) 3) max replicas / autoscaler 4) falha job upstream 5) spike de tenant/região.
- Defina IMPACTO em 1 linha: o que degradou + escopo (tenant, % ou serviço downstream).
- Defina AÇÃO IMEDIATA em 1 linha: rollback, scale, pause, retry, investigar. Se não houver ação clara, sugira a mais segura.
- Defina ESCALAR PARA usando OWNER_MAP + condição temporal (ex: "se não cair em 10min").

FORMATO DE SAÍDA OBRIGATÓRIO (exatamente 5 linhas, sem markdown extra):
ALERTA: [Serviço] - [o que] + [threshold/tempo]
IMPACTO: [o que degradou] para [escopo]
HIPÓTESE INICIAL: [causa mais provável com horário/evidência]
AÇÃO IMEDIATA: [ação em andamento/proposta via ferramenta]
ESCALAR PARA: [time/owner] se [condição]

EXEMPLO:
Entrada: "2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems, buffer saturated after deploy 02:55"
Saída:
ALERTA: Relay - taxa de rejeição de ingestão acima de 2% por 5min
IMPACTO: ingestão de telemetry degradada para ~12% dos tenants
HIPÓTESE INICIAL: deploy do Relay às 09:14 reduziu o buffer de ingestão
AÇÃO IMEDIATA: rollback iniciado via Argo CD
ESCALAR PARA: @relay-core se a rejeição não cair em 10min

Agora processe ALERT_RAW acima e retorne APENAS as 5 linhas.
Parâmetros para customizar por alerta
Parâmetro	Para que serve	Exemplo
{{ALERT_RAW}}	Log bruto do Sentinel	Entrada 1, 2 ou 3
{{THRESHOLDS}}	Evita que o LLM chute severidade	CPU >85% por 5min = ALTA
{{OWNER_MAP}}	Padroniza escalação	Forge=@forge-batch
{{CONTEXTO_EXTRA}}	Deploy, tenant baseline, região	deploy 02:55, tenant stark-industries 4x baseline
{{IDIOMA}}	Mantém padrão	pt-BR

Entrada 1:
2026-05-12 14:02:09 UTC [Sentinel] autoscaler hit max replicas (60/60) on sentinel-api,
queue depth on Relay growing 2k/min, CPU avg 88%, tenant stark-industries
sending 4x baseline volume after onboarding new region

Entrada 2:
2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems,
buffer saturated after deploy 02:55

Entrada 3:
2026-05-13 11:40:22 UTC [Forge] consumer lag 9min and climbing, batch forge-batch-ingest
delayed after previous job failure, downstream Sentinel starting to lag
```
---
#### 🛠️ Modelo Prompt:
OpenCode - Muse Spark 1.3 Free Medium

---
#### 📦 Output:

>ALERTA: Sentinel-api - autoscaler em max replicas (60/60) com CPU média 88%
>IMPACTO: processamento degradado com fila do Relay crescendo 2k/min para tenant stark-industries
>HIPÓTESE INICIAL: spike de tenant/região com stark-industries a 4x do baseline após onboarding de nova região
>AÇÃO IMEDIATA: investigar saturação e avaliar aumento do limite de réplicas
>ESCALAR PARA: @platform se max replicas persistir por mais 10min
>
>ALERTA: Relay - taxa de rejeição de ingestão 6% por 8min (threshold >2% por 5min)
>IMPACTO: ingestão degradada para tenant wakanda-systems
>HIPÓTESE INICIAL: deploy às 02:55 com buffer saturado
>AÇÃO IMEDIATA: avaliar rollback do deploy das 02:55
>ESCALAR PARA: @relay-core se rejeição não cair em 10min
>
>ALERTA: Forge - consumer lag 9min e subindo (threshold >5min)
>IMPACTO: batch forge-batch-ingest atrasado com downstream Sentinel começando a degradar
>HIPÓTESE INICIAL: falha do job upstream anterior travando forge-batch-ingest às 11:40 UTC
>AÇÃO IMEDIATA: investigar job anterior e avaliar retry do batch
>ESCALAR PARA: @forge-batch se lag não cair em 10min