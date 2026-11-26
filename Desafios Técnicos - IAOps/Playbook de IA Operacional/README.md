# Playbook de IA Operacional

## Operação contínua na Aegis

Deixa eu te apresentar o palco deste desafio. A Aegis é uma empresa de observabilidade e possuem o seu produto, um SaaS de observabilidade e resposta a incidentes: outras empresas plugam seus ambientes nela e passam a enxergar métricas, logs e alertas num lugar só. 

São quatro sistemas sustentando essa operação:

- **Relay** — barramento de eventos assíncrono e borda de ingestão: todo o telemetry dos clientes entra por ele e é distribuído para o resto da plataforma
- **Forge** — pipeline de dados e data warehouse, onde o telemetry vira série temporal e tabela consultável
- **Sentinel** — produto core de observabilidade e alerting que o cliente de fato usa
- **Cerebro** — sistema de indexação e busca, aquele que acha a agulha no palheiro de logs

### Fluxo de Telemetry

```
Clientes (telemetry)
        │
        ▼
Relay (ingestão + eventos) ───────────────┐
        │                                 │
        ▼                                 │
Forge (pipeline + data warehouse) ────────┤
        │                                 │
        ▼                                 ▼
Cerebro (indexação e busca) ────────────► Sentinel (observabilidade + alerting)
                                          │
                                          ▼
                                          Time / plantão
```

### O Time

A estrutura que toca isso é enxuta, e você vai esbarrar com essas pessoas ao longo dos checkpoints:

- **Tony Stark** — CTO, responde pela direção técnica
- **Pepper Potts** — CEO, lê tudo pela ótica de custo e crescimento
- **Carol Danvers** — Head of Product, prioriza o que entra no roadmap
- **Steve Rogers** — Staff engineer veterano, escreveu boa parte da plataforma antiga
- **Natasha Romanoff** — Segurança e compliance, carimba os padrões internos
- **Bruce Banner** — Lidera engenharia de dados e os modelos que rodam sobre o Forge
- **Sam Wilson** — Lidera a SRE e o plantão
- **Nick Fury** — Diretor de operações, cobra previsibilidade de ponta a ponta

## O Desafio: Um Playbook de IA Operacional

A Aegis decidiu que o uso de IA pelo time de engenharia não pode mais ser ad-hoc — cada um com seu prompt solto no histórico do chat. 

O Nick Fury quer um **playbook de IA operacional**: uma biblioteca de prompts versionada, testada e tratada como código, que qualquer engenheiro do time possa pegar e confiar. Esse é o trabalho que cai na sua mesa.

### Duas Regras de Método

Tem duas regras que valem pro desafio inteiro:

1. **Todo prompt é parametrizável** — recebe os dados variáveis por parâmetro (snapshot, alerta, artefatos, provedor) para ser reutilizável em vários contextos, não um prompt que serve a um caso só

2. **Meta-prompting como ferramenta** — você dirige a IA para gerar e refinar o prompt, em vez de redigir tudo na mão. O meta-prompt em si não precisa ser entregue; o que entra na biblioteca é o prompt parametrizável final, com sua curadoria

### Escopo e Progressão

Este desafio trabalha com o modelo recebendo os dados no próprio prompt (chat, playground ou API), com os exemplos colados na entrada — **sem agentes de codificação nem tools externas** (isso vem no módulo de agentes).

Nos próximos dez checkpoints a biblioteca nasce, amadurece e termina como um repositório testado em pipeline. A complexidade cresce a cada passo: os primeiros são mais diretos, os últimos cobram decisão e síntese, não execução.

Pressuposição: você está fluente nos cinco frameworks de prompt engineering. Eles vão aparecer como ferramenta de trabalho, não como conteúdo para exercitar de novo.