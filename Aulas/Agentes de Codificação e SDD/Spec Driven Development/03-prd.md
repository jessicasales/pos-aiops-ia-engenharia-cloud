# PRD — Product Requirement Document

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 03 — PRD (12:04) |
| **Assunto** | O documento de requisitos de produto: princípios, notação Gherkin e seções mínimas |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `prd` `design-docs` `gherkin` `given-when-then` `critérios-de-aceite` |

## Resumo da aula

**PRD (Product Requirement Document)** é o documento relacionado a **produto**: o que será entregue, os comportamentos, o porquê e para quem. Não é invenção da era de IA — é prática de engenharia de software que já existia e que a IA tornou ainda mais necessária, pois é o contexto que o agente precisa para construir com eficiência.

## Conceitos principais

### PRD é sobre produto, não sobre tecnologia
PRD não define framework, linguagem ou stack — isso é TRD (próxima aula). PRD define **o que** e **por que**, em termos de comportamento e regra de negócio.

### Cinco princípios de um bom PRD
1. **Contexto suficiente** — porquê, domínio, componentes de negócio, restrições; nada subentendido ou intrínseco (a IA não deduz).
2. **Critérios verificáveis** — comportamento que define "está funcionando corretamente".
3. **Decomposição em fases** — quebrar features complexas em milestones/marcos de entrega, reduzindo escopo por ciclo (princípio ágil).
4. **Limites explícitos** — o que está dentro e fora do escopo, para a IA não "alucinar" criando o que não foi pedido (ela gera texto por probabilidade estatística, então tende a preencher lacunas).
5. **Documento vivo** — deve ser atualizado conforme o comportamento muda.

### Notação Gherkin (Given/When/Then)
Linguagem de domínio específico para descrever comportamento em três frases simples:
```text
Dado que o banco está fora (Given)
Quando eu chamar /ready (When)
Então a resposta deve ser status 503 (Then)
```
Usada tanto para **definir** o comportamento no PRD quanto para **testar** depois — vira o "contrato" firmado com a IA.

### Seções mínimas de um PRD
| Seção | Conteúdo |
|---|---|
| Contexto | Porquê, domínio, motivação |
| Atores | Quem interage com o recurso |
| Predicados | Comportamentos verificáveis (Given/When/Then) |
| Invariantes | O que sempre deve valer — premissas que nunca quebram |
| Restrições | Limites; o que está dentro/fora do escopo |
| Critérios de aceite | Também em Given/When/Then |
| Fases | Blocos de entrega / milestones |

## Pegadinhas
- Confundir PRD com documento técnico é erro comum — tecnologia/framework pertence ao TRD, não ao PRD.
- "Óbvio para você" não é óbvio para a IA — todo limite precisa estar escrito, senão ela preenche a lacuna sozinha.

## Dúvidas para revisar
- Escrever um PRD em Gherkin para um endpoint ou feature real do meu trabalho, como exercício.
