# Execução do Prompt — Saídas Padronizadas

## Entrada 1

Modelo utilizado: Claude Haiku 4.5

**Alerta Cru:**
```markdown
2026-05-12 14:02:09 UTC [Sentinel] autoscaler hit max replicas (60/60) on sentinel-api,
queue depth on Relay growing 2k/min, CPU avg 88%, tenant stark-industries
sending 4x baseline volume after onboarding new region
```

**Nota de Triagem Padronizada:**
```markdown
ALERTA: Sentinel - autoscaler atingiu máx replicas (60/60), fila do Relay crescendo 2k/min
IMPACTO: capacidade de processamento saturada; Relay degradado para tenant stark-industries
HIPÓTESE INICIAL: onboarding de nova região gerou 4x volume baseline, sobrecarregou autoscaler
AÇÃO IMEDIATA: validar limite de replicas; considerar aumento de quota ou aumento manual
ESCALAR PARA: @sentinel-core se queue depth não estabilizar em 15min
```

---

## Entrada 2

Modelo utilizado: Claude Haiku 4.5

**Alerta Cru:**
```markdown
2026-05-13 03:11:00 UTC [Relay] ingest reject rate 6% for 8min, tenant wakanda-systems,
buffer saturated after deploy 02:55
```

**Nota de Triagem Padronizada:**
```markdown
ALERTA: Relay - taxa de rejeição de ingestão 6% por 8min
IMPACTO: ingestão de telemetry degradada para tenant wakanda-systems
HIPÓTESE INICIAL: deploy às 02:55 reduziu capacidade ou buffer do Relay
AÇÃO IMEDIATA: rollback do deploy ou aumento manual de buffer
ESCALAR PARA: @relay-core se rejeição não cair abaixo de 2% em 10min
```

---

## Entrada 3

Modelo utilizado: Claude Haiku 4.5

**Alerta Cru:**
```markdown
2026-05-13 11:40:22 UTC [Forge] consumer lag 9min and climbing, batch forge-batch-ingest
delayed after previous job failure, downstream Sentinel starting to lag
```

**Nota de Triagem Padronizada:**
```markdown
ALERTA: Forge - lag de ingestão 9min e subindo, batch forge-batch-ingest atrasado
IMPACTO: processamento em atraso cascateando para Sentinel (dashboards começando a atrasar)
HIPÓTESE INICIAL: falha de job anterior bloqueou fila; consumer não consegue recuperar
AÇÃO IMEDIATA: retrigger manual do job falhado ou restart do consumer
ESCALAR PARA: @data-platform se lag não cair abaixo de 5min em 20min
```

---

## Curadoria

### Como o Prompt Inicial Gerou o Resultado

**Estratégia usada:**

1. **Contexto + Objetivo claro**
   - Explicou o problema (cada um escreve diferente)
   - Definiu o alvo (padronizar abertura de triagem)
   - → Modelo entendeu a restrição de negócio

2. **Exemplos de saída esperada ANTES dos exemplos de entrada**
   - Mostrou 3 notas "boas" prontinhas (formato alvo)
   - Modelo aprendeu o padrão antes de ver alertas crus
   - → Reduziu ambiguidade e tokens desnecessários (few-shot é mais eficiente)

3. **Exemplos de entrada desorganizada (crus)**
   - Mostrou como os dados chegam hoje (timestamp, componente, contexto misturado)
   - Criou o "antes" que justifica o "depois"
   - → Modelo entendeu a transformação necessária (entrada → saída)

4. **Separação clara: "exemplos de saída" ≠ "exemplos de entrada"**
   - Alertou "não misture os dois" no README
   - Evitou confundir o modelo sobre o quê é referência e o quê é teste
   - → Reduziu risco de o modelo copiar exemplos literalmente

Quando o modelo entregou o prompt, eu não havia pedido, mas ele acabou já me dando o retorno das entradas no padrão correto. Então nessa etapa pedi novamente pra ele criar os arquivos separadamente no formato .md e então ficou da forma desejada.
