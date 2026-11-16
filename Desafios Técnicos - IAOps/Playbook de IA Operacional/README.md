# Operação contínua na Aegis

Deixa eu te apresentar o palco deste desafio. A Aegis é uma empresa de observabilidade e possuem o seu produto, um SaaS de observabilidade e resposta a incidentes: outras empresas plugam seus ambientes nela e passam a enxergar métricas, logs e alertas num lugar só. São quatro sistemas sustentando essa operação. O Relay é o barramento de eventos assíncrono e a borda de ingestão: todo o telemetry dos clientes entra por ele e é distribuído para o resto da plataforma. O Forge é o pipeline de dados e o data warehouse, onde o telemetry vira série temporal e tabela consultável. Em cima disso roda o Sentinel, o produto core de observabilidade e alerting que o cliente de fato usa. E o Cerebro é o sistema de indexação e busca, aquele que acha a agulha no palheiro de logs.

Em alto nível, o telemetry flui assim pela plataforma — vale ter esse desenho na cabeça:
```text
flowchart LR
    Clientes["Clientes<br/>(telemetry)"] --> Relay["Relay<br/>ingestão + eventos"]
    Relay --> Forge["Forge<br/>pipeline + data warehouse"]
    Relay --> Sentinel["Sentinel<br/>observabilidade + alerting"]
    Forge --> Sentinel
    Forge --> Cerebro["Cerebro<br/>indexação e busca"]
    Cerebro --> Sentinel
    Sentinel --> Time["Time / plantão"]
```

O time que toca isso é enxuto, e você vai esbarrar com essas pessoas ao longo dos checkpoints. Tony Stark é o CTO e responde pela direção técnica. Pepper Potts, a CEO, lê tudo pela ótica de custo e crescimento. Carol Danvers é a Head of Product, que prioriza o que entra no roadmap. Steve Rogers é o staff engineer veterano que escreveu boa parte da plataforma antiga, e muita coisa ainda roda como ele deixou. Natasha Romanoff fecha a ponta de segurança e compliance, é dela o carimbo nos padrões internos. Bruce Banner lidera engenharia de dados e os modelos que rodam sobre o Forge. Sam Wilson lidera a SRE e o plantão. E Nick Fury é o diretor de operações da plataforma, que cobra previsibilidade de ponta a ponta.

A Aegis decidiu que o uso de IA pelo time de engenharia não pode mais ser ad-hoc — cada um com seu prompt solto no histórico do chat. O Nick Fury quer um playbook de IA operacional: uma biblioteca de prompts versionada, testada e tratada como código, que qualquer engenheiro do time possa pegar e confiar. Esse é o trabalho que cai na sua mesa.

E tem duas regras de método que valem pro desafio inteiro, presta atenção nelas. Primeira: todo prompt do playbook é parametrizável — ele recebe os dados variáveis por parâmetro (o snapshot, o alerta, os artefatos, o provedor), pra ser reusável, e não um prompt que serve a um caso só. Segunda: a forma recomendada de criar esses prompts é via meta-prompting — você dirige a IA pra gerar e refinar o prompt, em vez de redigir tudo na mão. O meta-prompt em si não precisa ser entregue; o que entra na biblioteca é o prompt parametrizável final, com a sua curadoria. E só pra deixar o escopo claro: aqui você trabalha com o modelo recebendo os dados no próprio prompt (chat, playground ou API), com os exemplos colados na entrada — este desafio não usa agentes de codificação nem tools externas, isso vem no módulo de agentes.

Nos próximos dez checkpoints a biblioteca nasce, amadurece e termina como um repositório testado em pipeline. A complexidade cresce a cada passo: os primeiros são mais diretos, os últimos te cobram decisão e síntese, não execução. Uma coisa eu já assumo aqui — que você está fluente nos cinco frameworks de prompt engineering que viu comigo. Eles vão aparecer como ferramenta de trabalho, não como conteúdo pra exercitar de novo.