# PRD Health — brainstorm e criação do primeiro PRD na prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 05 — PRD Health (24:41) |
| **Assunto** | Brainstorm estruturado + geração do primeiro PRD (endpoints health/ready) do zero, com Claude Code |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `prd` `brainstorm` `health` `ready` `predicados` `draft-first` `premissas` |

## Resumo da aula

Primeira prática de SDD: usar o mesmo projeto EncontroStack, mas agora documentando com especificação **antes** de codificar (ao invés do "Vibe Code" das aulas anteriores). O escopo aqui: endpoints de **health/ready**, script de seed, Dockerfile/Compose e cluster Kubernetes — tudo isso vira PRD (infraestrutura como código/Terraform fica para outra etapa).

## Conceitos principais

### Fluxo em duas etapas: brainstorm → PRD
1. **Brainstorm** (prompt reutilizável) — a IA não cria nada, só investiga o projeto existente, questiona premissas (máx. 3 perguntas por vez, as mais importantes primeiro), não concorda por padrão, entrega trade-offs em tabela e riscos em lista.
2. **Geração do PRD** — a partir da conversa de brainstorm, formaliza em predicados verificáveis (Dado/Quando/Então), marcando premissas inline.

### Por que o brainstorm importa
A IA tende a já "sair codificando" (comparada a um profissional júnior animado) — o modo brainstorm trava isso explicitamente, forçando reflexão antes de produzir qualquer artefato. No exemplo da aula, o brainstorm levantou pontos que passariam despercebidos num prompt direto: se o liveness deve checar o banco (não deve — só o processo), se o readiness deve (deve), inconsistência no bootstrap de migration, timeout de conexão no readiness, nível de detalhe do corpo de erro.

**Recomendação:** use sempre o **melhor modelo disponível** (maior reasoning) para brainstorm e documentação — na aula, Opus.

### Regras do prompt de geração do PRD
- **Regra central**: PRD descreve **comportamento e regra de negócio**, nunca implementação (isso é ADR/TRD).
- **Draft-first**: gerar o documento completo de uma vez; o que não foi definido no brainstorm é inferido e marcado inline como `*(premissa — confirme ou corrija)*`.
- Estrutura: Contexto → Atores → Predicados verificáveis (Dado/Quando/Então) → Invariantes → Restrições → Fora do escopo (obrigatório, com o porquê) → Critérios de aceite.
- Critério vago ("deve funcionar bem") não é aceitável — reformular até virar predicado verificável.

### Fechando premissas em aberto
Depois de gerado o PRD, o professor resolveu as 3 premissas pendentes diretamente no chat (timeout de 2s na verificação de prontidão; sem autenticação nas probes; `Content-Type: application/json`) e pediu para **remover as marcações de premissa já fechadas** do documento — "é ruído, nada mais do que ruído".

### Resultado salvo
`docs/0001-prd-health-check-endpoint.md` — primeiro PRD numerado do projeto.

## Prompts da aula

<details>
<summary>Prompt — Parceiro de brainstorm (reutilizável)</summary>

```text
Você é meu parceiro de brainstorm para amadurecer uma ideia ANTES de especificá-la. Siga estas regras:

MODO: você não cria arquivos, não escreve código e não gera nenhum documento. Só pesquisa, questiona e amadurece a ideia comigo, até eu pedir explicitamente o próximo passo.

ENTENDIMENTO: antes de opinar, investigue o que já existe (código e contexto do projeto) e aponte as lacunas. Faça no máximo 3 perguntas por vez — as mais importantes primeiro.

ANÁLISE CRÍTICA: não concorde por padrão. Questione minhas premissas, levante complexidades ocultas e riscos não óbvios. Quando fizer sentido, entregue: trade-offs (em tabela), riscos (em lista) e uma direção sugerida com justificativa — mesmo que ela divirja do que eu propus.

ITERAÇÃO: a cada resposta minha, incorpore os ajustes sem repetir o que já discutimos. Se eu corrigir uma premissa, propague a correção por toda a análise.

FECHAMENTO: quando o entendimento estiver maduro, feche com um resumo — problema resolvido, decisões em tabela (Decisão | Escolha | Justificativa) e pontos em aberto. Aguarde eu validar; não avance sozinho.
```
</details>

```text
Ideia para amadurecer:
O recurso de health/ready do encontros-tech. Quero entender o comportamento: o que significa a app estar "viva" vs estar "pronta", o que o /ready precisa checar para se dizer pronto, e o que deve acontecer quando o banco de dados fica indisponível.
```

<details>
<summary>Prompt — Geração do PRD (em cadeia, mesma sessão)</summary>

```text
Agora, a partir de TUDO que amadurecemos no brainstorm acima, escreva o PRD desta feature. Use nossa conversa como fonte — não recomece do zero nem me re-entreviste.

REGRA CENTRAL: o PRD descreve COMPORTAMENTO e REGRA DE NEGÓCIO (o "o quê" e o "porquê"), nunca a implementação. Isso é decisão de ADR/TRD.

DRAFT-FIRST: gere o documento completo de uma vez. O que não ficou definido no brainstorm, infira e marque inline com *(premissa — confirme ou corrija)*.

ESTRUTURA (PRD agêntico):
1. Contexto — produto, estado atual, problema de negócio
2. Atores — quem/o que interage (ex.: Kubernetes, o processo da app, o banco)
3. Predicados verificáveis — no formato Dado/Quando/Então, cada um objetivamente testável e sem ambiguidade
4. Invariantes — o que precisa ser sempre verdade (ex.: app não-pronta nunca recebe tráfego)
5. Restrições — limites de negócio/comportamento (não técnicos)
6. Fora do escopo — explícito, com o porquê (obrigatório)
7. Critérios de aceite — como saber que está "pronto", em termos observáveis

QUALIDADE: critério vago ("deve funcionar bem", "boa performance") não é aceitável — reformule até virar predicado verificável. Não escreva código nem escolha tecnologia.

Ao terminar, me mostre o PRD para revisão.
```
</details>

## Pegadinhas
- O brainstorm é melhor conduzido por voz/ditado + transcrição (Superflow na aula) — mas digitar funciona igual.
- Fechar premissas em aberto diretamente no chat, pedindo depois a remoção da marcação, mantém o documento limpo sem perder o rastro da decisão durante a conversa.

## Dúvidas para revisar
- Aplicar esse fluxo (brainstorm → PRD com premissas) na documentação de uma feature real do meu trabalho.
