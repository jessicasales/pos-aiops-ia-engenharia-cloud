# Prompt Parametrizável — Análise de Causa-Raiz de Degradação

---

**Nome:** Jéssica Sales  
**Assunto:** Análise de causa-raiz de degradação em sistema de indexação e busca (Elasticsearch/Cerebro)  
**Data:** 2026-11-26  
**Modelo e esforço:** Claude Sonnet 4.6 — esforço padrão (single-turn, sem chain-of-thought explícito)  
**Palavras-chave:** causa-raiz, RCA, Elasticsearch, degradação, reindexação, heap, circuit breaker, observabilidade, prompt parametrizável

---

> Reutilizável para qualquer incidente de degradação em sistemas de indexação e busca.  
> Substitua os placeholders `{{...}}` pelos artefatos do incidente em questão.

---

## Prompt

```
Você é um engenheiro de plantão sênior especializado em sistemas de indexação, busca e observabilidade.

Recebi os artefatos abaixo sobre uma degradação em produção no sistema {{NOME_DO_SISTEMA}}.
Sua tarefa é correlacionar os três artefatos e chegar à causa-raiz — não a uma lista de sintomas,
mas à causa que, se removida, impede toda a cascata.

---

### ARTEFATO 1 — Configuração do sistema
Fonte: {{FONTE_CONFIG}} (ex.: repositório de infra, ConfigMap, arquivo versionado)

{{ARTEFATO_CONFIG}}

---

### ARTEFATO 2 — Métricas observadas
Fonte: {{FONTE_METRICAS}} (ex.: Sentinel, Grafana, Datadog)
Janela de tempo: {{JANELA_TEMPO}}

{{ARTEFATO_METRICAS}}

---

### ARTEFATO 3 — Logs do sistema
Fonte: {{FONTE_LOGS}} (ex.: kubectl logs, CloudWatch, Loki)
Janela de tempo: {{JANELA_TEMPO}}

{{ARTEFATO_LOGS}}

---

Responda em português, nesta ordem:

**1. Linha do tempo**
Tabela com três colunas: Horário | Evento no log | Métrica correspondente.
Correlacione os três artefatos linha a linha — não descreva cada um separado.

**2. Causa-raiz**
Uma frase direta que nomeia a causa. Em seguida, o raciocínio que a sustenta citando
evidências dos três artefatos. Separe explicitamente: "isso é causa" vs "isso é sintoma".

**3. Cascata**
Diagrama ou lista ordenada mostrando como a causa-raiz gerou cada sintoma observado.
Formato: causa → efeito intermediário → efeito final, com as evidências dos logs/métricas.

**4. Remediação imediata**
O que fazer agora para estabilizar o sistema. Ordene por urgência.
Inclua os comandos ou chamadas de API relevantes quando possível.

**5. Ações preventivas**
Mudanças de configuração, alertas ou processos para evitar que o mesmo incidente se repita.
Para cada ação: o que mudar, onde (config/alerta/processo) e o impacto esperado.

**6. Pré-tratamento para envio externo**
Liste os campos dos artefatos acima que precisam ser removidos ou mascarados
antes de enviar para qualquer modelo ou serviço fora do ambiente interno
(ex.: nomes de índice, IPs, hostnames, nomes de serviços, dados de negócio, janelas de manutenção).
```

---

## Parâmetros

| Placeholder | O que colocar | Exemplo |
|---|---|---|
| `{{NOME_DO_SISTEMA}}` | Nome do serviço afetado | `Cerebro`, `Search API`, `Log Ingestion Pipeline` |
| `{{FONTE_CONFIG}}` | Origem do artefato de configuração | `repositório de infra`, `ConfigMap do cluster` |
| `{{ARTEFATO_CONFIG}}` | Conteúdo completo do arquivo de configuração | `cerebro.yaml`, `elasticsearch.yml`, `values.yaml` |
| `{{FONTE_METRICAS}}` | Sistema de observabilidade que gerou as métricas | `Sentinel`, `Grafana`, `Datadog` |
| `{{JANELA_TEMPO}}` | Período coberto pelos artefatos 2 e 3 | `08:00–10:00 UTC de 2026-05-13` |
| `{{ARTEFATO_METRICAS}}` | Tabela ou JSON de métricas exportado | Tabela com timestamp, p99, heap%, cache_hit% |
| `{{FONTE_LOGS}}` | Origem dos logs | `kubectl logs cerebro-node-3`, `CloudWatch /ecs/search` |
| `{{ARTEFATO_LOGS}}` | Trecho de log cobrindo a mesma janela do artefato 2 | Saída do `kubectl logs` ou exportação do Loki |

---

## Notas de uso

- **Mínimo viável:** os artefatos 1 e 3 (config + logs) já permitem diagnóstico; o artefato 2 (métricas) adiciona a dimensão temporal quantitativa.
- **Mais de três artefatos:** adicione seções `ARTEFATO 4`, `ARTEFATO 5` antes da instrução de resposta, mantendo o mesmo padrão de fonte + conteúdo.
- **Pré-tratamento:** aplique a seção 6 antes de qualquer execução em modelo externo (API pública, produto SaaS). Em modelos internos ou self-hosted, avalie conforme a política de dados da organização.
