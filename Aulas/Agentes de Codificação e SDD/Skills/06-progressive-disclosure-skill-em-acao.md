# Progressive Disclosure — a Skill em Ação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 06 — Progressive Disclosure - Skill em Ação (39:31) |
| **Assunto** | Anatomia das skills geradas (brainstorm e criar-design-docs) e o carregamento em camadas |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `progressive disclosure` `references` `assets` `scripts` `janela de contexto` `500 linhas` `inferência` `lost in the middle` `escopo` |

## Resumo da aula

Análise do que a IA gerou nas skills da aula anterior, para entender o funcionamento por baixo dos panos — "não adianta simplesmente colocar a skill-creator e já era".

A skill `criar-design-docs` trata três documentos (PRD, TRD, ADR) com um `SKILL.md` de **visão global** (fluxo comum) e uma pasta `references/` com um arquivo por tipo. O agente só carrega a referência do documento que vai trabalhar. Esse carregamento em camadas é o **Progressive Disclosure**.

Depois a skill é testada no projeto Encontros Tech: brainstorm de uma feature (upload de imagem de capa do evento, armazenada no S3) e criação do PRD — e só `references/prd.md` foi carregado.

## Conceitos principais

### As três camadas de carregamento
```text
1. Inicialização   → só o frontmatter (name + description) — catálogo de habilidades
2. Gatilho acionado → corpo do SKILL.md (visão geral / fluxo principal)
3. Sob demanda      → references/assets/scripts necessários para aquele caso
```
Colocar tudo num "skillzão" carregaria PRD + TRD + ADR mesmo trabalhando só com um → polui o contexto e mistura workflows. Fere o princípio de engenharia de contexto: **dado certo, na hora certa, no volume certo**.

### Estrutura de pastas de uma skill (spec)
| Pasta | Conteúdo |
|---|---|
| `SKILL.md` | Instruções e visão geral (obrigatório) |
| `references/` | Extensões/especializações de um fluxo (ex.: `prd.md`, `trd.md`, `adr.md`) |
| `assets/` | Templates, logos, imagens, resources |
| `scripts/` | Código executável (ex.: validação determinística) |

### Regras práticas
- **`SKILL.md` com no máximo ~500 linhas.** Passou disso → separar em referências.
- Template pequeno usado só num fluxo pode ficar dentro do `references/` (ex.: 127 linhas). Template grande ou usado em vários lugares → `assets/`. "A regra não é escrita em pedra."
- Arquivos de referência **não têm frontmatter**.

### Boas práticas vistas nas skills geradas
- Sempre contrastar **o que fazer × o que não fazer**.
- Cada etapa com **justificativa (porquê)** → o modelo consegue "improvisar" bem quando algo não está descrito.
- "Não concorde por padrão" — mata o viés de bajulação.
- **Fechamento consolidado no fim** por causa do *Lost in the Middle*: o modelo lê melhor o início e o fim do contexto. Gasta mais token, mas vale.
- **Separar o que o usuário afirmou do que a IA inferiu** — a IA não adivinha o que está implícito; forçar o levantamento de inferências enriquece o contexto.
- Matriz de documentos: o que é cada doc, o que escanear, o que atualizar e consolidar.

### Escopo e precedência
- Mesmo nome em **projeto** e **usuário** → a de **projeto sobrescreve** a de usuário.
- Skills como brainstorm/design docs costumam ficar no escopo de **usuário** (usadas em vários projetos).

### Como o professor organiza as próprias skills
- Três repositórios: **empresa**, **pessoal** e **público** (boa prática).
- Separou em `escrever-prd` e `escrever-trd` (que inclui ADR, porque o TRD referencia ADRs).
- Brainstorm de produção usa **Scratchpad** (bloco de anotações para consolidar), **Skeleton of Thoughts** (cria o esqueleto do documento e depois popula) e uma referência de **áreas especializadas** detectadas automaticamente.
- Skill precisa de **revisão contínua**: novas ferramentas e modelos surgem — isso faz parte da engenharia de Harness.

## Comandos e prompts da demo

```text
Entrar em modo brainstorm e me ajude a definir uma feature para a aplicação para suportar o upload de imagens
→ "A imagem vai ser a capa do evento e pretendo armazenar em um S3 na AWS"

/criar-design-docs Crie um novo PRD para essa feature
Salve o documento   → docs/prds/...
```

## Pegadinhas
- Chamar a skill como comando carrega o `SKILL.md` direto; o progressive disclosure acontece nas references.
- Juntar ou separar documentos numa skill? **Depende do seu modo de trabalhar** — com progressive disclosure, juntar não é ruim.
- Material da aula (`.zip`): `skills-da-aula/` (como foram construídas) e `skills-de-producao/` (brainstorm com áreas especializadas, escrever-prd, escrever-trd). "Não copie e cole: leia, entenda e adapte."

## Dúvidas para revisar
- Montar meus três repositórios de skills (trabalho, pessoal, público)?
- Aplicar Skeleton of Thoughts + Scratchpad na minha skill de brainstorm.
