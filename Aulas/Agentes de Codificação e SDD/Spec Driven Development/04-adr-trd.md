# ADR e TRD — documentos técnicos (Design Docs)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 04 — ADR TRD (12:51) |
| **Assunto** | Architecture Decision Record e Technical Requirement Document: quando usar cada um e o que cada um deve conter |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `adr` `trd` `design-docs` `decisão-de-arquitetura` `requisitos-não-funcionais` |

## Resumo da aula

PRD cobre regra de negócio e comportamento do usuário, mas não cobre a parte técnica de implementação. Essa é a função dos **Design Docs**: um conjunto de documentos técnicos, dos quais esta aula cobre dois — **ADR** (Architecture Decision Record) e **TRD** (Technical Requirement Document). (O PRD às vezes é classificado como Design Doc na literatura mais recente, por causa da IA, mas o professor não o considera um.)

## Conceitos principais

### ADR × TRD — quando usar cada um
| | ADR | TRD |
|---|---|---|
| Usa quando | Há um **processo de decisão** entre alternativas (ex.: Postgres × MySQL) | Requisito técnico **sem** debate de alternativas (ex.: linguagem já padronizada na empresa) |
| Registra | A decisão em si, o porquê, as alternativas descartadas | O "como" implementar, de forma abrangente |

**Regra de ouro:** "Se alguém pode perguntar por que você usou X e não Y, crie um ADR."

### Campos mínimos de um ADR
1. **Título** — claro, ex. "Escolha do banco de dados".
2. **Status** — proposto / aceito / substituído (quando uma nova decisão revoga a anterior).
3. **Contexto** — a força maior, o motivo, o que precisa ser levantado.
4. **Decisão** — o que foi decidido.
5. **Consequências** — o que essa escolha implica.

### Campos recomendados para enriquecer (vai além do mínimo)
- **Alternativas consideradas** (ex.: MySQL, SQL Server, Oracle).
- **Critérios que pesaram** na escolha (ex.: custo de licença, conhecimento da equipe).
- **Prós e contras** / trade-offs de cada opção.

### Quando criar um ADR
- Decisões de **grande impacto**, caras de reverter.
- Múltiplas equipes/projetos impactados.
- Quando a decisão deve virar **padrão** da empresa/projeto.
- **No momento em que a decisão é tomada** — registrar retroativamente uma decisão antiga não faz sentido (critérios mudam, equipe muda); nesse caso, revise ou documente no TRD.

### TRD (Technical Requirement Document)
É o "T" no lugar do "P" do PRD — documento técnico que complementa o PRD: o que não está no PRD (requisitos de usuário/negócio) deve estar no TRD, e vice-versa.

**O que colocar no TRD:**
- **Requisitos não funcionais** (tempo de resposta, disponibilidade, observabilidade) — **sempre quantificados**, nunca vagos ("alta disponibilidade" não diz nada; precisa de número mensurável, pois vira critério de aceite).
- Arquitetura e contratos (ex.: contrato de API, endpoints, modelo de dados).
- Modelo de banco de dados, estrutura de classes.
- Stack e principais bibliotecas.
- Referências aos ADRs relacionados.

## Pegadinhas
- Requisito não funcional sem número é inútil como critério de aceite — sempre quantifique.
- Registrar ADR fora do momento da decisão tende a ficar desatualizado/sem sentido.

## Dúvidas para revisar
- Próximas aulas: construção prática de PRD, ADR e TRD no projeto do curso.
