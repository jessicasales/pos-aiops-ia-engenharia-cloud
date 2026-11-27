# Prompt Parametrizável — Mesa-Redonda de Analistas Sênior para Estratégias de Contenção sob Pico

---

**Nome:** Jéssica Sales
**Assunto:** Avaliação de estratégias de contenção/backpressure em sistema sob pico de carga via debate de três analistas sênior
**Data:** 2026-11-26
**Modelo e esforço:** Opus 4.7 Extra High (single-turn, debate simulado em uma única resposta)
**Palavras-chave:** backpressure, saturação, barramento de eventos, SLA, DLQ, autoscaling, sharding, priorização, trade-off, multi-persona, debate, prompt parametrizável

---

> Reutilizável para qualquer decisão de arquitetura sob picos de carga em que há SLAs conflitantes, orçamento restrito e histórico de incidentes que condicionam a solução.
> Substitua os placeholders `{{...}}` pelos dados do caso em questão.

---

## Prompt

```
Você vai simular uma mesa-redonda com TRÊS analistas consultores sênior com perfis distintos
avaliando a situação descrita abaixo. Cada um apresenta sua análise, debatem entre si
confrontando os pontos fracos das propostas uns dos outros, e ao final convergem para uma
recomendação única e acionável.

Responda inteiramente em português.

---

### PERFIS DOS ANALISTAS

- **Analista 1 — {{PERFIL_ANALISTA_1}}**
  (ex.: SRE focado em confiabilidade e SLA; defende margem de segurança sobre custo)
- **Analista 2 — {{PERFIL_ANALISTA_2}}**
  (ex.: arquiteto de plataforma focado em custo e eficiência; questiona overengineering)
- **Analista 3 — {{PERFIL_ANALISTA_3}}**
  (ex.: engenheiro de dados focado em integridade e reprocessamento; obcecado por não perder evento)

Os três perfis devem ser genuinamente diferentes — pontos cegos e prioridades distintos —
para que o debate produza fricção real, não concordância artificial.

---

### SITUAÇÃO

**Sistema avaliado:** {{NOME_DO_SISTEMA}}
**Papel na arquitetura:** {{PAPEL_NA_ARQUITETURA}}
(ex.: barramento de eventos, borda de ingestão, gateway síncrono)

**Problema observado:**
{{DESCRICAO_DO_PROBLEMA}}
(em 2–4 linhas: o que acontece quando o sistema é sobrecarregado e qual o impacto a jusante)

**Métricas do sistema:**
- Throughput sustentado: {{THROUGHPUT_SUSTENTADO}}
- Pico observado: {{PICO_OBSERVADO}} por {{DURACAO_DO_PICO}}
- Retenção/buffer atual: {{RETENCAO_ATUAL}}
- Consumidores a jusante: {{CONSUMIDORES}}
  (para cada consumidor: nome, função, criticidade)

**Restrições do time:**
{{RESTRICOES}}
(lista de bullets cobrindo: SLAs por consumidor, orçamento de infra,
incidentes históricos relevantes, políticas inegociáveis como "não perder evento")

---

### ESTRATÉGIAS A SEREM AVALIADAS

Cada analista deve se posicionar explicitamente sobre CADA uma das estratégias abaixo
(a favor, contra ou condicional — com justificativa):

{{ESTRATEGIAS}}
(lista numerada; exemplos típicos:
 1. priorização de consumidores críticos sobre os tolerantes a atraso
 2. dead-letter queue / fila de reprocessamento
 3. particionamento por tenant/cliente
 4. autoscaling horizontal de consumidores
 5. backpressure explícito no produtor
 6. amostragem/degradação graciosa)

---

### FORMATO DA RESPOSTA

**1. Rodada de análises individuais**
Para cada analista (1, 2 e 3), nesta ordem:
- Diagnóstico em 1 parágrafo (o que ele enxerga como o verdadeiro problema).
- Posição sobre cada estratégia listada, com uma linha de justificativa ancorada
  nas métricas e restrições.
- Ordem de preferência das estratégias, da mais para a menos recomendada.

**2. Debate**
Três trocas no mínimo, no formato:
  > **Analista X:** [afirmação]
  > **Analista Y:** [contra-argumento ou refinamento]
O debate deve atacar os pontos fracos, não validar o óbvio. Pelo menos uma das trocas
deve envolver trade-off entre as restrições (ex.: SLA vs custo, integridade vs latência).

**3. Recomendação convergente**
- Ação imediata (o que fazer no próximo pico, antes de qualquer mudança estrutural).
- Ação de curto prazo ({{HORIZONTE_CURTO_PRAZO}}): quais estratégias entram, em que ordem,
  e qual o critério de pronto para cada uma.
- Ação estrutural: o que fica para depois e por quê.
- Risco residual: o que esta recomendação NÃO resolve, e como monitorar.

**4. Métricas de verificação**
Lista de 3 a 5 métricas/sinais que devem ser observados para confirmar que
a recomendação está funcionando e para disparar revisão se não estiver.
Para cada métrica: nome, limiar, fonte sugerida.
```

---

## Parâmetros

| Placeholder | O que colocar | Exemplo |
|---|---|---|
| `{{PERFIL_ANALISTA_1}}` | Especialidade e viés do 1º analista | `SRE — prioriza SLA e confiabilidade` |
| `{{PERFIL_ANALISTA_2}}` | Especialidade e viés do 2º analista | `Arquiteto de plataforma — prioriza custo e simplicidade` |
| `{{PERFIL_ANALISTA_3}}` | Especialidade e viés do 3º analista | `Engenheiro de dados — prioriza integridade e reprocessamento` |
| `{{NOME_DO_SISTEMA}}` | Nome do componente sob análise | `Relay`, `Kafka ingest`, `API Gateway` |
| `{{PAPEL_NA_ARQUITETURA}}` | O que esse componente faz na plataforma | `barramento de eventos assíncrono e borda de ingestão` |
| `{{DESCRICAO_DO_PROBLEMA}}` | Narrativa curta do comportamento sob estresse | `quando chega mais dado que o normal, a fila acumula e atrasa o alerting a jusante` |
| `{{THROUGHPUT_SUSTENTADO}}` | Capacidade nominal em regime | `180k msgs/s` |
| `{{PICO_OBSERVADO}}` | Pico real medido | `320k msgs/s` |
| `{{DURACAO_DO_PICO}}` | Quanto tempo o pico durou | `25 min` |
| `{{RETENCAO_ATUAL}}` | Janela de buffer disponível | `4h` |
| `{{CONSUMIDORES}}` | Lista de downstreams com função e criticidade | `Forge (ingestão, tolera 15min); Sentinel (alerting, SLA 60s)` |
| `{{RESTRICOES}}` | Bullets com SLAs, orçamento, histórico, políticas | SLA de alerting ≤ 60s; orçamento 8% acima; "não perder evento" |
| `{{ESTRATEGIAS}}` | Opções candidatas a serem comparadas | priorização, DLQ, sharding por tenant, autoscaling |
| `{{HORIZONTE_CURTO_PRAZO}}` | Prazo considerado "curto prazo" para o time | `próximas 2 sprints`, `30 dias` |

---

## Notas de uso

- **Perfis dos analistas:** mantenha-os heterogêneos de propósito; se os três convergem rápido, o debate perde valor. Em caso de dúvida, use o trio padrão (SRE / arquiteto de custo / engenheiro de dados) — cobre as três tensões mais comuns (confiabilidade × custo × integridade).
- **Lista de estratégias:** pode ser aberta pelo usuário ou fechada pelo autor do prompt. Fechada força comparação direta; aberta deixa espaço para o modelo propor opções não óbvias.
- **Mínimo viável:** situação + métricas + restrições + estratégias já bastam. Perfis dos analistas são opcionais — sem eles, o modelo escolhe três perfis razoáveis, mas você perde controle sobre as tensões em jogo.
- **Pré-tratamento para envio externo:** antes de colar valores reais, remova nomes de produto internos, nomes de cliente, hostnames, números de contrato e janelas de manutenção; troque por rótulos genéricos se forem irrelevantes para a decisão.
