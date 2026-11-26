# Checkpoint 05 — Migrando o Forge de lote para tempo real

## O Projeto

O Forge é o **pipeline de dados** da Aegis — é ele que pega o telemetry e transforma em tabela consultável.

**Hoje:** roda em lote (batch)
- De hora em hora um job acorda
- Lê tudo que acumulou
- Processa de uma vez
- Assim o Steve Rogers montou anos atrás

**Objetivo:** mudar para um modelo **orientado a eventos** (event-driven)
- Consumir cada evento do Relay assim que ele chega
- Processar quase em tempo real

## O Desafio

Essa mudança é **grande demais para resolver num prompt só**. Se você jogar tudo de uma vez na IA, a resposta sai rasa e genérica.

## Estado Atual do Forge

### Configuração Atual

- **Ingestão:** um job em cron acorda a cada 60min (`forge-batch-ingest`)
- **Transformação:** 14 etapas de processamento encadeadas (em Spark), ~40min no total
- **Destino:** grava em tabelas no data warehouse, particionadas por hora
- **Ponto frágil:** se um lote falha, o próximo acumula o dobro de volume
- **Dependências:** 
  - Sentinel (lê as tabelas agregadas)
  - Cerebro (indexa os eventos transformados)
  - Relatórios de billing da Pepper (rodam de madrugada)

### Requisitos da Migração

- ✓ Consumir do Relay continuamente, processando em pequenos blocos (no lugar do lote de 1h)
- ✓ Manter quem depende do Forge funcionando durante a transição
- ✓ Nada de virada única (big-bang): migração em passos com **possibilidade de voltar atrás**

---

## A Solução: Encadeamento de Prompts

O caminho aqui é **quebrar a migração em etapas** e resolver uma de cada vez com a IA, cada etapa usando o resultado da anterior — em vez de um único prompt gigante.

Isso se chama **encadear prompts**. Exemplo de fluxo:

1. Um prompt **diagnostica** o estado atual
2. O próximo **propõe** o passo a passo da migração
3. O seguinte **detalha** o plano executável e reversível

A entrega **não é um prompt monolítico**: é essa **cadeia**, com cada elo recebendo a saída do anterior como entrada.

---

## Tarefa

**Escrever a cadeia de prompts parametrizáveis da migração** (use meta-prompting para criá-la) e **executá-la sobre o cenário do Forge**.

## Entregáveis

- Os prompts parametrizáveis da cadeia
- Execução (modelo e output de cada elo)
- Curadoria