# Writer/Reviewer e Agent-as-a-Judge

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 06 — Writer/Reviewer e Agent-as-a-Judge (14:42) |
| **Assunto** | Padrão Writer/Reviewer: usar um sub-agent com janela de contexto separada para revisar um documento criado pela sessão principal, evitando o self-preference bias |
| **Data** | 29/10/2026 19:50 |
| **Tags** | agent-as-a-judge, writer-reviewer, self-preference, revisar-spec, skill-de-revisao, parecer |

## Resumo da aula

Aula que conecta o conceito de **LLM-as-a-Judge** (já visto em Engenharia de Prompt/Prompt Evaluation) ao mundo dos sub-agents: **Agent-as-a-Judge**. Em vez de pedir que o próprio agente que criou um documento (ex.: um PRD) o revise na mesma janela de contexto — o que tende a gerar aprovação fácil por **self-preference bias** — delega-se a revisão a um sub-agent com janela de contexto limpa, seguindo uma skill de revisão dedicada (`revisar-spec`). Demonstração prática: criação de um PRD para upload de imagem de capa de evento (persistida em S3), seguida de revisão por um agente `general-purpose` usando a skill `revisar-spec`, que devolve um parecer estruturado e aciona correções no documento.

## Conceitos principais

### O problema do self-preference

Se o mesmo agente/janela de contexto que criou um documento for solicitado a revisá-lo, a tendência é aprovar com mais facilidade o que foi "feito por ele mesmo" — o mesmo viés já estudado com LLM-as-a-Judge (modelos da mesma família tendem a aprovar o trabalho um do outro). Isso vale mesmo dentro da mesma ferramenta: usar o mesmo modelo na mesma sessão para criar e revisar tende a produzir uma revisão enviesada, "fácil demais".

### Agent-as-a-Judge: a solução

Em vez de colocar apenas um **modelo diferente** como juiz (LLM-as-a-Judge), usa-se um **agente completo** — com sua própria janela de contexto separada — para fazer a validação. A simples separação de contexto já traz melhoria no processo de revisão, mesmo que o modelo usado seja o mesmo (ex.: Opus para ambos, se a ferramenta só oferecer modelos de uma família). Quando a ferramenta permite, usar modelos de famílias diferentes para criação e revisão (ou um modelo superior para revisar) aumenta ainda mais a eficácia.

### A skill `revisar-spec` — o critério do juiz

Skill instalada em `.claude/skills/revisar-spec/SKILL.md`, escrita para **execução autônoma**: decide e reporta, nunca pergunta — porque o sub-agent que a executa não tem canal de volta com o autor do documento no meio do processo.

Estrutura da skill:
- **Regra de execução**: nunca fazer pergunta, nunca aguardar confirmação; onde faltar uma decisão, registrar a lacuna com opção recomendada e razão (a decisão fica com quem lê o parecer); onde a evidência do repositório responder, responder com evidência citada (arquivo e linha); não alterar o documento nem o código — o parecer é a única saída.
- **Passo 1 — Ler o documento inteiro**: identificar o que ele promete (comportamento, para quem, sob quais condições, o que está fora de escopo).
- **Passo 2 — Levantar evidência no repositório**: código da área afetada, comportamento equivalente já implementado (precedente), documentos anteriores que já decidiram algo sobre o mesmo assunto.
- **Passo 3 — Avaliar item a item**, com um veredito por item:
  | Veredito | Quando |
  |---|---|
  | `conforme` | Item verificável, sem conflito, sustentado pelo repositório |
  | `lacuna` | Falta algo que a implementação exigiria e o documento não define |
  | `conflito` | O item contradiz outro item, o código atual ou uma decisão anterior |
  | `pendência` | Depende de decisão que a evidência não resolve |

  Critérios de avaliação: verificabilidade (o item é observável como verdadeiro/falso, ou é só um adjetivo vago?), consistência interna, consistência com o código, cobertura de falha (o que acontece quando o caminho feliz não ocorre?), fronteira de escopo (o que ficou de fora foi dito ou apenas ausente?).
- **Passo 4 — Escrever o parecer**: sem preâmbulo, sem elogio, sem recapitulação.

**Critério de achado** (o que calibra a revisão, evitando ruído): relatar apenas o que afeta correção/cumprimento da especificação; não relatar preferência de redação/ordem/nomenclatura; não relatar ausência de algo que o documento já declarou fora de escopo (escopo negativo explícito é decisão tomada, não lacuna); não propor ampliação de escopo; não inventar requisito só para ter o que reportar (um documento sem lacunas recebe um parecer sem lacunas — saída legítima); item duvidoso entra como `pendência`, nunca como `conflito`.

**Formato do parecer**: veredito geral (`pronto para implementar` | `pronto com ressalvas` | `não pronto`) + tabela de itens (veredito + evidência arquivo:linha) + "o que fecha cada achado" (ação concreta) + pendências de decisão (opções, recomendação, razão). Regra do veredito geral: qualquer `conflito` aberto impede "pronto para implementar"; só `pendência` sustenta "pronto com ressalvas".

### Demonstração prática

1. **Brief enviado à sessão principal** (que tem a skill de criação de PRD disponível): especificação de upload de imagem de capa de evento, acessível publicamente, persistida no S3 da AWS (a escolha da tecnologia já vem do próprio pedido do usuário). A sessão principal gerou o PRD completo (contexto, atores, predicados verificáveis, etc.) em `docs/PRDs/`.
2. **Delegação da revisão**: `Use o agente general-purpose para revisar o PRD da capa de evento seguindo a skill revisar-spec. Aplique as correções do parecer no PRD.` Nenhum agente customizado novo foi criado para isso — o `general-purpose` (built-in) foi usado como a "janela" isolada, e a skill `revisar-spec` foi o critério. O sub-agent invocou a skill, levantou evidências no repositório, gerou o parecer (apontando, por exemplo, um "crítico: ganho de dependência registrada" e um "caminho de falha inverso que faltava") e devolveu para a sessão principal, que aplicou as correções no PRD.

### Padrão Writer/Reviewer — generalizável

O padrão demonstrado (um agente/skill "escreve", outro agente com contexto separado "revisa" usando uma skill de critério) pode ser aplicado a qualquer fluxo que precise de revisão: revisão de código após uma feature, revisão de documento técnico, revisão de definição de arquitetura, etc. Recomendação do instrutor: sempre ter uma skill de criação e uma skill de validação — podem até estar no mesmo arquivo de skill, desde que um agente faça a criação e outro (com contexto isolado) faça a validação.

## Comandos e configurações

```yaml
# .claude/skills/revisar-spec/SKILL.md (resumo do front matter)
---
name: revisar-spec
description: 'Revisa um documento de especificação — PRD, spec, RFC — contra o estado real do repositório e devolve um parecer item a item, sem interagir com o autor. Use quando um documento de especificação precisar ser avaliado antes de virar implementação: "revise este PRD", "esta spec está pronta para implementar?", "tem lacuna nesse documento?", "confira a spec contra o código". Escrito para execução autônoma: o procedimento decide e reporta, nunca pergunta.'
---
```

```text
# brief enviado à sessão principal (gera o PRD)
Quero especificar uma funcionalidade nova do Encontros Tech.

Quem cadastra um evento pode enviar uma imagem de capa. A capa aparece na listagem e
na página do evento, precisa ficar acessível publicamente para quem visita o site, e
não pode ficar guardada no banco de dados — vamos jogar no S3 da AWS.

Escreva o PRD dessa funcionalidade.
```

```text
# delegação da revisão a um sub-agent com contexto isolado
Use o agente general-purpose para revisar o PRD da capa de evento seguindo a skill revisar-spec.
Aplique as correções do parecer no PRD.
```

## Pegadinhas

- Pedir para o mesmo agente/sessão que criou um documento também revisá-lo tende a produzir uma aprovação enviesada (self-preference) — mesmo problema do LLM-as-a-Judge visto em Prompt Evaluation.
- Mesmo usando o mesmo modelo (pela limitação de só ter modelos de uma família disponíveis na ferramenta), a simples separação de janela de contexto já melhora a qualidade da revisão — não é só sobre trocar de modelo.
- A skill de revisão precisa ser escrita para execução **autônoma** (decide e reporta, nunca pergunta) — um sub-agent não tem como voltar e perguntar ao autor no meio do processo.
- Um parecer "sem achados" é uma saída legítima e esperada quando o documento realmente não tem lacunas — a skill deve evitar inventar problemas só para ter o que reportar.

## Dúvidas para revisar

- Vale criar um sub-agent customizado dedicado a revisão (em vez de usar o `general-purpose` built-in), com permissões ainda mais restritas (ex.: somente leitura)?
- Como esse mesmo padrão Writer/Reviewer se aplicaria à revisão de código após uma implementação do `software-developer` — usando uma skill de code review em vez de `revisar-spec`?
- Em um fluxo real de equipe, quem deveria ler e decidir sobre as "pendências de decisão" do parecer — o autor do PRD, um tech lead, ou outro papel?
