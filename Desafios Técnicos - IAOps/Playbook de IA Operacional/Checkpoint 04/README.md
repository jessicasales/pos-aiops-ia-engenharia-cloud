# Checkpoint 04 — Segurando a sobrecarga do Relay

## O Problema

Lembra que o Relay é o barramento por onde **todo o telemetry dos clientes passa** antes de chegar no resto da plataforma.

Quando um cliente grande dispara muito mais dado que o normal:
- O Relay recebe mais do que consegue entregar
- A fila começa a acumular
- Esse atraso vai empurrando o Sentinel junto
- O alerta que deveria sair na hora **atrasa**

O Tony Stark quer uma estratégia para segurar esse excesso quando ele acontece — o nome técnico disso, em sistemas de fila, é **backpressure**. O problema: não existe resposta única. Dá para resolver de várias formas, e cada uma tem um preço. Estes são os dados que o time juntou (o que se sabe do Relay hoje e as regras que a solução tem que respeitar):

## Estado Atual e Restrições

### Relay (barramento de eventos)

- **Throughput sustentado:** 180k msgs/s
- **Pico observado:** 320k msgs/s por 25min (semana passada)
- **Retenção atual:** 4h
- **Consumidores:** Forge (ingestão), Sentinel (alerting em tempo real)

### Restrições do Time

- **Sentinel:** alerting não pode atrasar mais que 60s (SLA com cliente)
- **Forge:** ingestão pode atrasar até 15min sem violar SLA
- **Orçamento:** trimestre já 8% acima do previsto
- **Histórico:** barramento antigo perdia mensagens sob pico → perda de telemetry é **inaceitável** para um produto de observabilidade

## Caminhos em Discussão

Existe mais de um caminho defensável. Alguns dos que estão em cima da mesa:

1. Dar prioridade ao Sentinel (alerting em tempo real) na frente do Forge (que pode esperar até 15min)
2. Guardar o que não foi processado numa fila separada para reprocessar depois (dead-letter queue)
3. Dividir o Relay por cliente, para que um cliente barulhento não atrapalhe os outros
4. Aumentar automaticamente o número de consumidores quando a carga sobe

Pode ser um desses, pode ser uma combinação. O que você vai construir é um prompt parametrizável que recebe esse cenário (o estado + as restrições) e faz a IA comparar mais de um caminho, pesando prós e contras, antes de recomendar — em vez de cuspir uma resposta única. Como a decisão é cara, o raciocínio importa tanto quanto a recomendação.

---

## Tarefa

**Escrever o prompt parametrizável que apoia essa decisão** (recebe o cenário como entrada; use meta-prompting para criá-lo) e **executá-lo sobre o cenário do Relay**.

## Entregue

- Prompt parametrizável
- Execução (modelo e output)
- Curadoria