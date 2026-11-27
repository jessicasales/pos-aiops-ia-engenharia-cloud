## Curadoria

Decidi usar o Tree Of Thoughts pra isso visto que é um debate de ideias na tentativa de recomendar o melhor. Primeiro eu escrevi o prompt inteiro como se já fosse utilizar, mas no final inseri:

Antes de analisar, dê um passo atrás e me forneça SOMENTE o prompt parametrizável para analisar esse tipo de situação

Assim pedi pro modelo salvar diretamente na minha pasta Checkpoint 4. Então após isso eu peguei o prompt criado, abri uma nova guia do Claude pra iniciar do zero. Inseri prompt + artefatos abaixo e gravei o retorno em output.md:

```markdown
Relay (barramento de eventos):
- throughput sustentado: 180k msgs/s
- pico observado no incidente da semana passada: 320k msgs/s por 25min
- retenção atual: 4h
- consumidores: Forge (ingestão), Sentinel (alerting em tempo real)

Restrições do time:
- alerting do Sentinel não pode atrasar mais que 60s (SLA com cliente)
- ingestão do Forge pode atrasar até 15min sem violar SLA
- orçamento de infra do trimestre já está 8% acima do previsto
- Steve Rogers lembra que o barramento antigo perdia mensagens sob pico,
  e perda de telemetry é inaceitável para um produto de observabilidade

Situações a analisar: 
- dar prioridade ao Sentinel (alerting em tempo real) na frente do Forge (que pode esperar até 15min);
- guardar o que não foi processado numa fila separada para reprocessar depois (o que se chama dead-letter queue);
- dividir o Relay por cliente, para que um cliente barulhento não atrapalhe os outros;
- aumentar automaticamente o número de consumidores quando a carga sobe.
```

Observações:
Notei que ao pedir pra salvar o prompt parametrizável, na tarefa do checkpoint 3 eu pedi pra inserir como premissa sempre colocar um cabeçalho nos prompts com: Nome, Assunto, Data, Modelo e esforço, Palavras chave. Neste eu não precisei manifestar isso e ele já se lembrou. Porém ao salvar o modelo, eu usava o Opus 4.7 Extra High e ele inseriu que o modelo e esforço havia sido o Claude Sonnet 4.6 — esforço padrão. Não entendi o porquê disso, mas alterei manualmente.

Sem falar mais nada ele leu também o padrão do Checkpoint 3 e quis criar o output.md usando o mesmo formato: cabeçalhos, parâmetros e curadoria.
