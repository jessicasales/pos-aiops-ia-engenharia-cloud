# Atualização TRD — propagando ADRs para o documento técnico

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 10 — Atualização TRD (07:23) |
| **Assunto** | Propagar as decisões dos dois ADRs de volta para o mesmo TRD (documento vivo, não paralelo) |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `trd` `adr` `documento-vivo` `propagação` `anti-invenção` |

## Resumo da aula

Com os dois ADRs criados (Docker e ambiente de produção), o TRD ficou desatualizado. Esta aula usa um prompt para **propagar** as decisões dos ADRs de volta ao mesmo TRD — sem criar documento paralelo nem seção "futuro".

## Conceitos principais

### Regra central do prompt de propagação
- Fonte de verdade: **TRD baseline + ADRs aceitos** — nunca reanalisar o repositório de novo ("o baseline já foi validado").
- É **um único TRD que evolui**, do estado atual para o estado-alvo.
- **Escopo travado**: mexer só no que os ADRs decidiram; o que o baseline já afirma e nenhum ADR toca, fica intacto.

### Como cada ADR é propagado
1. A **decisão** do ADR vira **requisito quantificado** na seção certa do TRD (ADR diz "o quê"; TRD diz os valores).
2. Vai além da tabela de índice: pega contexto, consequências, restrições e trade-offs de cada ADR e **espalha** nas seções do template a que pertencem (arquitetura, NFRs, contratos, riscos) — "a tabela só indexa; o corpo do TRD é onde o conteúdo dos ADRs vira documento".
3. Declara como **contrato** qualquer saída que outra parte do sistema vá consumir.
4. Conecta com PRDs já especificados, quando a decisão toca um comportamento já descrito.
5. Indexa os ADRs na tabela de decisões (#, título, data, status, link) — **referencia** o racional, não copia.
6. **Parâmetros de implementação** que ficaram de propósito fora dos ADRs entram aqui no TRD — "ADR = decisão; TRD = requisito".
7. **Draft-first anti-invenção**: valores inferidos além do que ADRs/baseline sustentam são marcados como premissa **na conversa**, não no arquivo.
8. Mantém exatamente o template do TRD baseline — sem headings/seções/colunas novas.

### O que mudou no TRD do projeto
- Runtime: desenvolvimento via Docker Compose com paridade de produção.
- Banco: Postgres via Docker Compose em dev; **Amazon RDS** multi-AZ (2 AZs) em produção.
- Imagem: build multistage, base slim, usuário non-root, cache em camadas.
- Dependências externas: adicionados Docker Hub e EKS.
- Pontos pendentes resolvidos na hora: sistema de tags (sem preview, definição manual), confirmação de 2 AZs (evitar custo adicional de mais zonas).

### A lição central
PRD, TRD e ADR são **documentos vivos** — toda vez que uma nova ADR é criada, é preciso rodar esse prompt de propagação para manter o TRD alinhado. "Esse prompt vai ser seu melhor amigo para atualizar a documentação técnica."

## Prompt da aula

<details>
<summary>Prompt — Propagação ADR → TRD (TRD vivo)</summary>

```text
Você é um engenheiro atualizando o TRD de um projeto a partir de decisões JÁ registradas em ADRs. Sua fonte de verdade são DOIS artefatos que vou te dar: o TRD baseline e os ADRs já aceitos. NÃO reanalise o repositório pra "redescobrir" o sistema — o baseline já foi validado; seu trabalho é só propagar as decisões.

TAREFA: propagar as decisões dos ADRs para o MESMO TRD, evoluindo-o do estado atual (baseline) para o estado-alvo. É UM único TRD que evolui — não crie um TRD paralelo nem uma seção "futuro".

ESCOPO (trava): mexa SÓ no que os ADRs decidiram. O que o baseline já afirma e nenhum ADR toca, deixe intacto. Não reabra decisões nem adicione melhorias que ninguém decidiu.

COMO PROPAGAR cada ADR:
- Traduza a DECISÃO do ADR em REQUISITO(S) quantificado(s), na seção certa do TRD — a decisão diz "o quê"; o TRD passa a dizer os valores.
- Vá ALÉM da tabela: pegue os PRINCIPAIS TÓPICOS de cada ADR (contexto, consequências, restrições, trade-offs) e use-os pra enriquecer o TRD como um todo — espalhe cada tópico na seção do template a que ele pertence (arquitetura, NFRs, contratos, riscos etc.), não num bloco solto. A tabela só INDEXA; o corpo do TRD é onde o conteúdo dos ADRs vira documento.
- Declare como CONTRATO qualquer saída que outra parte do sistema vá consumir.
- Onde a decisão se conecta a um comportamento já especificado num PRD, amarre os dois no TRD.
- Indexe os ADRs na tabela de decisões do TRD (#, título, data, status, link) — o TRD referencia o racional, não o copia.

Em tudo isso, RESPEITE a estrutura e o template base do TRD: não crie headings, seções ou colunas novas — o conteúdo dos ADRs entra DENTRO do molde existente.

PARÂMETROS: os parâmetros de implementação que ficaram DE FORA dos ADRs de propósito entram aqui — é o lugar deles. ADR = decisão; TRD = requisito.

DRAFT-FIRST (anti-invenção): preencha o que os ADRs e o baseline sustentam. Qualquer valor que você INFERIR além disso, marque com `*(premissa — confirme ou corrija)*` na conversa (não no arquivo) pra eu validar.

Mantenha EXATAMENTE o template do TRD baseline (mesmos headings, ordem e colunas). Ao terminar, me mostre as seções alteradas seção por seção ANTES de gravar — e liste à parte cada ADR e ONDE ele entrou no TRD, pra eu conferir a propagação.
```
</details>

## Pegadinhas
- Esquecer de rodar esse prompt depois de criar um novo ADR é a causa mais comum de TRD desatualizado.
- Premissas aqui são resolvidas **na conversa**, nunca marcadas dentro do arquivo final — diferente do PRD, onde ficavam inline até serem fechadas.

## Dúvidas para revisar
- Com PRD, TRD e ADRs prontos, a próxima etapa é finalmente **implementar** usando Spec Driven Development de fato (próximas aulas tratam de comandos e do framework OpenSpec).
