# Customização: Contexto e Rules

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 15 — Customização OpenSpec (12:25) |
| **Assunto** | Configuração do `openspec/config.yaml` com `context` global e `rules` por etapa, para ancorar o agente nos documentos já criados (TRD/ADR/PRD) |
| **Data** | 29/10/2026 15:35 |
| **Tags** | openspec, config.yaml, context, rules, proposal, specs, tasks, design |

## Resumo da aula

Com as duas changes de infraestrutura concluídas (Docker e Kubernetes), o curso migra para implementação de funcionalidades de código, usando os PRDs já criados (PRD Health/Ready e PRD Seed). Antes disso, o instrutor mostra como customizar o comportamento do OpenSpec via `openspec/config.yaml`, usando dois recursos nativos da ferramenta (sem harness): `context` (informação universal, entra em todo artefato gerado) e `rules` (regras específicas por etapa do fluxo: proposal, specs, tasks, design).

## Conceitos principais

### Onde cada campo entra

| Campo | Alcance |
|---|---|
| `context` | Universal — entra em TODO artefato gerado (proposal, specs, tasks, design) |
| `rules.proposal` | Só no artefato `proposal.md` |
| `rules.specs` | Só no artefato de specs |
| `rules.tasks` | Só no artefato `tasks.md` |
| `rules.design` | Só no artefato `design.md` |

### Os três campos do `config.yaml`

- `schema: spec-driven` — define o template/fluxo utilizado (mantido como default no projeto; profiles e a hierarquia de resolução de schema ficam para o capítulo "SDD Avançado").
- `context: >-` — bloco de texto com informações gerais do projeto e da estrutura de documentação, inserido no prompt de **todas** as etapas, para o agente não precisar procurar nos documentos repetidamente.
- `rules:` — mapa de listas, uma por etapa (`proposal`, `specs`, `tasks`, `design`), com regras que só entram no artefato correspondente.

Importante: tudo que é adicionado no `config.yaml` é **somado** ao prompt de execução — não remove nada do comportamento padrão do OpenSpec. Remover/sobrescrever comportamento é tratado em outra etapa futura do curso.

### `context` usado no projeto (Encontros Tech)

O contexto vincula o agente à arquitetura real já implementada: app web de gestão de eventos, arquitetura em camadas (router → service → model), e explicita o papel de cada documento:
- **TRD** = verdade técnica global (stack, arquitetura, RNFs, índice de ADRs) — consultar, nunca reescrever.
- **ADRs** = decisões imutáveis (status: aceito) — referenciar, nunca reabrir.
- **PRDs** = comportamento em formato Dado/Quando/Então — critério de aceite.

### `rules` usadas, por etapa

- **proposal**: incluir plano de rollback e mapear o *blast radius* (tamanho do impacto da proposta); sinalizar impacto em disponibilidade/alta disponibilidade.
- **specs**: cobrir cenários de falha e de borda, não só o caminho feliz; mapear o PRD de origem e os predicados cobertos por aquela especificação — essencial para rastreabilidade: toda spec/change que referencia um PRD deve registrar isso explicitamente, aumentando o contexto disponível sobre aquela feature.
- **tasks**: cada tarefa deve ter um comando de validação explícito; incluir uma tarefa de verificação (*gate*) antes de prosseguir.
- **design**: ancorar as decisões de implementação nos ADRs aceitos e no TRD, sem reabrir ADR.

### Por que usar `context` em vez de redigitar em cada prompt

Usar o `context` do `config.yaml` é uma boa prática porque essas informações são automaticamente injetadas no prompt de cada etapa do OpenSpec — o agente não precisa procurar nos documentos do projeto a cada execução. O instrutor menciona que existem outras formas de fazer isso (gerenciamento de memória), a serem exploradas depois.

## Comandos e configurações

```yaml
# openspec/config.yaml
schema: spec-driven
context: >-
  [REVIEW] Encontros Tech — app web de gestão de eventos, arquitetura em camadas
  (router → service → model); specs evoluem em openspec/specs/.
  [PAPEL DOS DOCS] TRD (docs/trd.md) = verdade técnica global (stack · arquitetura
  · RNFs · índice de ADRs) — consultar, não reescrever. ADRs (docs/adrs/*.md) =
  decisões imutáveis (status: aceito) — referenciar, nunca reabrir. PRDs
  (docs/*-prd-*.md) = comportamento em Dado/Quando/Então — critério de aceite.
rules:
  proposal:
    - Incluir plano de rollback e mapear blast radius
    - Sinalizar impacto em disponibilidade / HA
  specs:
    - Cobrir cenários de falha e borda, não só o caminho feliz
    - Mapear o PRD de origem e os predicados cobertos
  tasks:
    - Cada task com comando de validação explícito
    - Incluir uma task de verificação (gate) antes de prosseguir
  design:
    - Ancorar decisões nos ADRs aceitos e no TRD, sem reabrir ADR
```

## Pegadinhas

- O `config.yaml` **adiciona** comportamento ao prompt padrão do OpenSpec — não remove nem sobrescreve nada do que já existe por padrão.
- Esse recurso é 100% nativo do OpenSpec, sem envolver harness — profiles e hierarquia de resolução de schema (mais avançado) ficam para outro capítulo.
- Mapear o PRD de origem nas specs não é feature automática do OpenSpec "puro" — precisa ser explicitamente pedido via `rules.specs`, senão a rastreabilidade entre PRD e spec se perde.

## Dúvidas para revisar

- Quais outras regras por etapa fariam sentido adicionar no projeto (ex.: segurança, observabilidade, performance)?
- Como as `rules` interagem quando há múltiplos profiles/schemas configurados (tema do capítulo "SDD Avançado")?
- Vale revisar o `context` periodicamente para garantir que ele continua refletindo a arquitetura real do projeto conforme ela evolui?
