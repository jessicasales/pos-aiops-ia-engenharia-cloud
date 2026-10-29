# ADR Docker — formalizando a decisão de containerização

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 08 — ADR Docker (15:47) |
| **Assunto** | Brainstorm + geração do primeiro ADR (decisão de usar Docker), no formato MADR |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `adr` `madr` `docker` `brainstorm` `draft-first` `multistage-build` |

## Resumo da aula

Com o TRD inicial pronto, é hora de registrar as decisões arquiteturais **ainda não implementadas**: uso de Docker e, na aula seguinte, Kubernetes. Isso entra via **ADR**, não editando o TRD diretamente. Mesmo fluxo das aulas de PRD: brainstorm → formalização.

## Conceitos principais

### Brainstorm da decisão de containerização
Contexto dado: a aplicação hoje roda direto no host via **systemd**, sem containers. Quer-se Dockerfile com boas práticas + Docker Compose para desenvolvimento (por causa da dependência de banco externo).

O brainstorm investigou o projeto e **encontrou um Dockerfile removido num commit anterior** (removido de propósito pelo professor para a demo) — decisão: ignorar o antigo, criar do zero. Perguntas levantadas e respondidas:
- Ambiente de dev no Compose deve ter **paridade com produção** (sem bind mount), não hot reload.
- Escopo do ADR: só Dockerfile + Docker Compose + uso do Docker Hub como registry — **manifesto Kubernetes fica fora**.
- Nome da imagem, estratégia de tag (push manual), repositório público.

### Formato MADR (template usado)
```yaml
---
adr_number: "<NNN>"
status: aceito
created: <YYYY-MM-DD>
supersedes: ""
superseded_by: ""
---
```
Seguido de `# ADR <NNN>: [Título]`, `## Contexto`, `## Alternativas Consideradas`, `## Decisão`, `## Consequências` (positivas / negativas / neutras-trade-offs).

### Regras centrais do prompt de ADR
- O agente **não decide** — só formaliza o que já foi decidido no brainstorm.
- **Não relê o repositório** para "descobrir" a decisão — a fonte é a conversa.
- ADR registra **uma** decisão e é **imutável** depois de `aceito`.
- **Nunca** inclui parâmetros de implementação (portas, nomes de variável, valores de config) — isso é TRD, não ADR.
- **Draft-first anti-invenção**: tudo que for inferido além do que foi dito é marcado `*(premissa — confirme ou corrija)*`.

### Correções feitas depois do rascunho
- Imagem base: **Slim** (não Alpine) — decisão mutável, dependendo do contexto de cada um (vulnerabilidades, dependências).
- Remover referência a **health check apontando para `/health`**: o PRD de health ainda não foi implementado, então o ADR de Docker não deve pressupor esse endpoint.
- Configuração via **variáveis de ambiente**, nunca `.env` — cada ambiente é responsável por fornecer suas próprias variáveis.

### Decisões registradas no ADR final
- **Multistage build** (imagem final mais enxuta).
- Imagem: `fabricioveronez/encontros-tech-aula`.
- Consequências positivas: ambiente de dev reproduzível, paridade dev/produção. Negativas: sem hot reload, push de tag manual.

## Prompts da aula

<details>
<summary>Prompt — brainstorm da decisão (contexto fornecido)</summary>

```text
Atualmente, a aplicação ela não utiliza nenhuma tecnologia de containers para ser
executada, seja no ambiente de desenvolvimento quanto no ambiente de produção.
Ela é executada utilizando o Systemd. Para facilitar o processo de
desenvolvimento e futuramente de produção, eu quero definir uma ADR para a
criação de um ambiente baseado em containers Docker, onde eu preciso criar o
Dockerfile utilizando as principais boas práticas de criação de imagens para
as tecnologias em volta do projeto e também para facilitar o ambiente de
desenvolvimento, principalmente porque existe a dependência de serviços
externos como banco de dados, utilizar a criação de um Docker Compose para
poder ser utilizado em ambiente de desenvolvimento.
```
</details>

<details>
<summary>Prompt — geração do ADR (template MADR)</summary>

```text
Você é um engenheiro registrando UMA decisão arquitetural que EU já tomei. Sua fonte de verdade é a decisão e o racional que acabei de definir no nosso brainstorm — NÃO releia o repositório pra "descobrir" a decisão, ela é minha. Seu papel é FORMALIZAR e estruturar as consequências, não decidir.

TAREFA: gerar o ADR de UMA decisão arquitetural em `docs/adrs/<NNN-slug-da-decisao>.md`.

CONTEXTO DA DECISÃO (vem do brainstorm — preencha com o que saiu ao vivo):
- Decisão: <a escolha que eu fechei>.
- Drivers que pesaram: <os critérios que mais pesaram na escolha>.
- Alternativas debatidas: <as opções reais que colocamos na mesa>.

REGRA CENTRAL: um ADR registra UMA decisão e é imutável depois de `aceito`. Status inicial = `aceito` (eu já decidi). Não recomende, não reabra a decisão, não inche com alternativas que não debatemos. NÃO inclua parâmetros de implementação (portas, números, nomes de variável, valores de config) — isso é requisito do TRD, não decisão.

DRAFT-FIRST (anti-invenção): preencha o que se sustenta no que eu te dei. Para qualquer Contexto, Alternativa ou Consequência que você INFERIR além do que falei, marque a linha com `*(premissa — confirme ou corrija)*` pra eu validar — não apague a marca por conta própria.

O documento final deve seguir EXATAMENTE este template — mesmo frontmatter, mesmas seções, mesma ordem. Não numere nem coloque os títulos em caixa-alta.

---
adr_number: "<NNN>"
status: aceito
created: <YYYY-MM-DD>
supersedes: ""
superseded_by: ""
---

# ADR <NNN>: [Título da decisão em uma linha]

## Contexto
[Problema, restrições e forças em jogo que exigem a decisão. Por que decidir isso agora? O que está em tensão?]

## Alternativas Consideradas
- **[Alternativa A]** — [prós e contras]
- **[Alternativa B]** — [prós e contras]
- **[Alternativa C]** *(se debatida)* — [prós e contras]

## Decisão
[O que foi decidido e a razão que pesou mais. Uma escolha clara, não um leque.]

## Consequências
- **Positivas:** [o que melhora com esta decisão]
- **Negativas:** [o custo aceito, o que fica pior ou mais restrito]
- **Neutras / trade-offs aceitos:** [implicações que não são bônus nem ônus]

Ao terminar, me mostre o ADR seção por seção pra revisão ANTES de gravar — e liste à parte as linhas marcadas como premissa pra eu confirmar.
```
</details>

## Pegadinhas
- Um ADR não deve assumir dependências de features ainda não implementadas (ex.: health check apontando para endpoint que só existe no PRD, não no código).
- Manter escopo apertado: tudo que pertence a Kubernetes foi deliberadamente deixado para o próximo ADR.

## Dúvidas para revisar
- Comparar esse fluxo de ADR com os ADRs que eventualmente existem (ou deveriam existir) nos projetos que administro.
