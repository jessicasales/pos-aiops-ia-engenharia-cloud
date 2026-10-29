# Brainstorm e Design Docs com Meta-Skill

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 05 — Brainstorm Design Docs (34:40) |
| **Assunto** | Criar skills com a skill-creator: skill de brainstorm e skill de design docs (PRD, TRD, ADR) |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `skill-creator` `meta-skill` `skills.sh` `brainstorm` `plan mode` `design docs` `PRD` `TRD` `ADR` `references` |

## Resumo da aula

Apresenta o **skills.sh** (agregador de skills mantido pela Vercel) e a skill **skill-creator** da Anthropic — "uma skill que cria skills" (técnica de **meta-skill**). Depois de instalar a skill-creator em escopo global, a aula cria duas skills:

1. **brainstorm** — convertendo o prompt de brainstorm (usado em aulas anteriores) em skill, usando **Plan Mode + skill-creator**.
2. **criar-design-docs** — usando a própria skill de brainstorm para amadurecer a ideia a partir dos prompts de PRD, TRD e ADR, e depois a skill-creator para gerar a skill com base na **janela de contexto**.

A skill de design docs já saiu com uma pasta `references/` (um arquivo por tipo de doc) — o porquê disso é o tema da próxima aula (Progressive Disclosure).

## Conceitos principais

### Instalar a skill-creator
- Requer **Node.js**. Comando: `npx skills add ...` (copiar do skills.sh).
- Cria a estrutura universal `.agents/skills/` e faz symlink para as ferramentas escolhidas (Claude Code, Codex, OpenCode, Cursor, Devin...).
- Escopo recomendado para a skill-creator: **global (usuário)**, pois será usada em todos os projetos. Método: **symlink**.

### Formas de criar uma skill com meta-skill
| Forma | Como | Quando |
|---|---|---|
| **Por especificação (spec)** | Você define estrutura, tarefa, triggers, passo a passo. Use **brainstorm** ou **Plan Mode** para planejar. | Quando você já sabe o que quer. Tratar skill **como código**. |
| **Por janela de contexto** | Você trabalha o processo interagindo com a IA; no fim pede: "a partir desta janela de contexto, identifique as etapas e crie a skill". | Processo novo, que você ainda está descobrindo. **A forma que o professor mais usa.** "O contexto é ouro." |
| **Por documentação** (variação de spec) | Transformar documentação técnica/guideline em skill. | Quando já existe doc. |

- Use o **melhor modelo** para criar a skill (ex.: Opus) — mesmo princípio do Spec Driven Development. Depois ela roda em outros modelos.
- Dica: mesmo em Plan Mode, dá para carregar a skill-creator chamando `/skill-creator` no início do pedido.

### Skill de brainstorm gerada
- Frontmatter com description deixando claro: **não cria arquivo, não escreve código, não gera documento**; triggers como "fazer um brainstorm", "amadurecer/destrinchar uma ideia", "pensar junto antes de implementar".
- Fluxo em 4 etapas: **entender antes de opinar → análise crítica → iterar sem repetir → fechar quando amadurecer** (problema, decisões em tabela, pontos em aberto).
- Racional: produzir artefato cedo demais trava decisões; o valor é reduzir incerteza enquanto ainda é barato mudar de ideia.
- A skill-creator sugeriu evals, mas foram adiados (aula 13 trata de avaliação).

### Skill de design docs — decisões tomadas no brainstorm
- **Uma skill, três modos** (PRD, TRD, ADR): criar, atualizar e consolidar.
- Pipeline **independente** do brainstorm.
- **ADR imutável**: nunca editar um ADR aceito, só mudar o status; decisão nova = ADR novo.
- **Consolidar separado por tipo** de doc.
- Intake: analisar o que for passado e perguntar só o necessário, agindo como assistente (sugerir melhorias, apontar trade-offs, marcar inferências).

## Comandos e prompts

```text
Shift+Tab  → até entrar em Plan Mode
/skill-creator Nesse momento, eu quero criar uma skill de brainstorming. A ideia é que ela me auxilie a destrinchar e evoluir as minhas ideias para depois criar uma especificação formal. Eu já tenho aqui um prompt que eu utilizava para acionar esse modo de brainstorming e agora eu quero converter ele para uma skill. Segue o prompt: <prompt de brainstorm>
```

```text
Quero fazer o brainstorming para a criação de uma skill para criar e gerenciar design docs. Tenho alguns prompts iniciais de referência. Todos devem ter um template definido. <prompts PRD, TRD e ADR>

/skill-creator Agora que eu tenho todas as informações consolidadas na minha janela de contexto, crie a skill a nível de projeto com o nome criar-design-docs.
```

<details>
<summary>Prompt de brainstorm (base da skill)</summary>

```text
Você é meu parceiro de brainstorm para amadurecer uma ideia ANTES de especificá-la. Siga estas regras:

MODO: você não cria arquivos, não escreve código e não gera nenhum documento. Só pesquisa, questiona e amadurece a ideia comigo, até eu pedir explicitamente o próximo passo.

ENTENDIMENTO: antes de opinar, investigue o que já existe (código e contexto do projeto) e aponte as lacunas. Faça no máximo 3 perguntas por vez — as mais importantes primeiro.

ANÁLISE CRÍTICA: não concorde por padrão. Questione minhas premissas, levante complexidades ocultas e riscos não óbvios. Quando fizer sentido, entregue: trade-offs (em tabela), riscos (em lista) e uma direção sugerida com justificativa — mesmo que ela divirja do que eu propus.

ITERAÇÃO: a cada resposta minha, incorpore os ajustes sem repetir o que já discutimos. Se eu corrigir uma premissa, propague a correção por toda a análise.

FECHAMENTO: quando o entendimento estiver maduro, feche com um resumo — problema resolvido, decisões em tabela (Decisão | Escolha | Justificativa) e pontos em aberto. Aguarde eu validar; não avance sozinho.
```
</details>

<details>
<summary>Pontos-chave dos prompts de PRD, TRD e ADR</summary>

**PRD** — descreve **comportamento e regra de negócio** (o quê e porquê), nunca implementação. *Draft-first*: o que não foi definido vira `*(premissa — confirme ou corrija)*`. Estrutura: Contexto · Atores · Predicados verificáveis (Dado/Quando/Então) · Invariantes · Restrições · Fora do escopo (obrigatório, com porquê) · Critérios de aceite. Critério vago não é aceito.

**TRD** — documenta o **baseline técnico** do projeto como ele É hoje, lendo o repositório inteiro. Sem recomendações. **Anti-alucinação**: toda afirmação confirmada num arquivo real; sem arquivo que sustente → não escreve; valor ausente → "Não definido". Template fixo: Stack · Arquitetura (padrão, pastas, módulos, rotas, modelo de dados) · Requisitos não-funcionais (Performance, Disponibilidade/SLA, Escalabilidade, Segurança, Observabilidade) · Dependências externas · Padrões (testes, estilo, error handling, logging, auth) · Índice de ADRs. Mostrar seção por seção antes de gravar em `docs/trd.md`.

**ADR** — formaliza **uma decisão já tomada** por você (não decide nem reabre). Status inicial `aceito`, imutável. Sem parâmetros de implementação (isso é TRD). Inferências marcadas como premissa. Frontmatter: `adr_number`, `status`, `created`, `supersedes`, `superseded_by`. Seções: Contexto · Alternativas consideradas · Decisão · Consequências (positivas, negativas, neutras). Gravar em `docs/adrs/<NNN-slug>.md`.
</details>

## Pegadinhas
- A skill-creator pode usar o que sabe sobre você (no exemplo, sugeriu escopo de "conteúdo") — revise as perguntas do plano.
- Se já existir uma skill com o mesmo nome (ex.: brainstorm no escopo de usuário), confira qual está sendo carregada.
- O material da aula traz um `.zip` com a skill de brainstorm de produção do professor para comparar.

## Dúvidas para revisar
- Comparar minha skill de brainstorm com a do professor (zip da aula).
- Testar a criação de skill "por janela de contexto" em um processo real do trabalho.
