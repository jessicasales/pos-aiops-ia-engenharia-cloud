# Controle de Energia e Ação Assíncrona

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 07 — Controle de Energia e Ação Assíncrona (08:27) |
| **Assunto** | Implementação do PRD 002 (ligar/desligar Droplet) — primeira feature de escrita do MCP, com `destructive_hint`, ação assíncrona e correção de timing nos testes |
| **Data** | 30/10/2026 01:15 |
| **Tags** | destructive-hint, tool-annotations, acao-assincrona, opsx-apply, shutdown-gracioso, power-on |

## Resumo da aula

Segunda feature do MCP didático de DigitalOcean (PRD 002, detalhado na nota da aula 05): ligar e desligar Droplets. É a **única feature de escrita** do projeto, e por isso ensina conceitos que a consulta (PRD 001) não cobre — anotação `destructive_hint`, natureza assíncrona de uma ação de cloud, e separação de tools por ação em vez de uma tool genérica com parâmetro de estado. A implementação seguiu o mesmo ciclo da aula anterior (skill `build-mcp-server` → OpenSpec → `/opsx:apply`), com uma interrupção real por falta de instrução explícita e uma correção de bug de timing durante a execução dos testes.

## Conceitos principais

### Repetir o pedido sem o "não desenvolva ainda" — e a consequência

```text
/build-mcp-server docs/prds/002-controle-de-energia-de-droplets.md
```

Diferente da aula anterior, o pedido **não incluiu** o complemento "analise e especifique, não desenvolva nada ainda" — e o agente começou a implementar diretamente. A execução precisou ser interrompida manualmente:

```text
Não implemente ainda.
```

Lição prática explícita do material da aula: omitir essa instrução leva à implementação direta sem passar pela etapa de especificação/revisão — o comportamento default da skill, quando a especificação já parece suficientemente clara, é seguir adiante.

### Decisões em aberto levantadas pelo agente

Depois de interrompido, o agente levantou os pontos que faltavam decidir:
1. **Feature direta vs. change do OpenSpec**: decisão de abrir uma change (mantendo o padrão rastreável de SDD já usado no PRD 001).
2. **`destructive_hint: true` em `power_on_droplet`, vs. declarar o valor de forma explícita** ("Destructive Explicit"): a segunda opção exigiria ajustar os testes; a decisão foi manter como estava (ficou sem resposta escrita explícita no material, mas o comportamento manteve a anotação original).
3. **Desfazer a implementação já iniciada, ou mantê-la como ponto de partida**: decisão de desfazer e recomeçar via change, seguindo o mesmo formato da change anterior (consulta de Droplets) — inclusive solicitando explicitamente a adição de estrutura de testes semelhante à do PRD 001.

```text
Abra uma change, siga a recomendação.
Desfaça a alteração já feita.
Adicione a estrutura de testes semelhante à change anterior.
```

O agente reverteu o código já escrito, releu a change da consulta de Droplets para manter consistência de formato, e então gerou a nova change (proposta, spec, design, tasks) para o controle de energia.

### Decisões de design registradas na change

- **Só `shutdown` e `power_on` entram no escopo** — nada de `reboot` ou `destroy` (coerente com o PRD, que excluiu corte de energia forçado e qualquer ação destrutiva de verdade).
- **Duas tools, uma ação cada** (`shutdown_droplet` e `power_on_droplet`), em vez de uma única tool genérica com o estado desejado como parâmetro — reforça a regra já vista no `AGENTS.md` do boilerplate (aula 05): "separe leitura de escrita... prefira `create_x`, `update_x`, `delete_x`" em vez de uma tool genérica com parâmetro `method`.
- **Consulta prévia do estado** antes de enviar a ação — necessária para implementar o comportamento do PRD de "já está no estado pedido → informa sem erro" (AC06).

### `/opsx:apply` — correção de bug de timing durante os testes

```text
/opsx:apply
```

Durante a implementação, o agente identificado e corrigiu, sozinho, um problema real nos testes de integração: os testes criavam o Droplet e **tentavam ligar/desligar imediatamente**, antes de a máquina estar de fato disponível (ainda em provisionamento) — gerando erros intermitentes. O agente ajustou o fluxo de teste para esperar a disponibilidade antes de agir, de forma análoga ao padrão de `aguardar(...)` já visto na aula 03 (testes da ferramenta LangChain de Droplets).

### Estrutura de código final

Em `src/mcp_server/tools/droplets.py` (mesmo módulo da aula 06, ampliado): três tools registradas — `list_droplets` (PRD 001), `shutdown_droplet` e `power_on_droplet` (PRD 002), cada uma com sua docstring/descrição — reforçando novamente que é essa descrição (docstring) que permite ao agente de IA identificar qual ferramenta usar e para quê. Os dados estruturados (`PowerAction`, `DropletsSummary`, etc.) seguem documentados no esquema das tools.

## Comandos e configurações

```text
# Pedido correto (lição da aula 06, repetida aqui como aviso)
/build-mcp-server docs/prds/002-controle-de-energia-de-droplets.md analise e especifique, não desenvolva nada ainda
```

```text
# Interrupção necessária quando o complemento foi esquecido
Não implemente ainda.
```

```text
# Respostas às decisões em aberto
Abra uma change, siga a recomendação.
Desfaça a alteração já feita.
Adicione a estrutura de testes semelhante à change anterior.
```

```text
/opsx:apply
```

## Pegadinhas

- Esquecer o complemento "não desenvolva ainda" no pedido à skill faz o agente avançar direto para a implementação — se o objetivo é passar primeiro pela etapa de revisão/especificação, essa instrução precisa ser explícita todas as vezes, não só na primeira.
- Testes de integração contra recursos de cloud recém-criados podem falhar de forma intermitente se não esperarem o recurso ficar de fato disponível (ex.: tentar ligar/desligar um Droplet que ainda está em provisionamento) — um padrão de espera/retry é necessário, não opcional, em testes de integração reais.
- Uma tool de ação como `power_on_droplet`, mesmo não sendo tecnicamente "destrutiva" no sentido de apagar dados, ainda carrega `destructive_hint` ou equivalente por alterar o estado de um recurso real — a escolha de anotação (hint explícito vs. implícito) tem implicações diretas nos testes que validam essas anotações (como visto no `AGENTS.md` da aula 05).
- Separar ações em tools distintas (`shutdown_droplet`, `power_on_droplet`) em vez de uma tool única parametrizada reduz a chance de o agente de IA escolher o parâmetro errado e facilita a leitura/auditoria de cada ação isoladamente.

## Dúvidas para revisar

- Como ficaria o teste do cenário "Droplet já está no estado pedido" (AC06 do PRD) na prática — a resposta da API da DigitalOcean para uma ação redundante precisa de tratamento especial no código, ou já vem de forma previsível?
- Vale a pena, em um MCP de produção, adicionar alguma salvaguarda (confirmação, allowlist) às tools de escrita, mesmo que o PRD didático tenha decidido explicitamente não ter nenhuma?
- Como o padrão de "consulta prévia do estado antes de agir" poderia ser generalizado para outras ações de escrita em outros provedores de cloud (AWS, Azure, GCP), além da DigitalOcean?
