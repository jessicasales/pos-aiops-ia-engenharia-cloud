# Versionamento e organização — prática

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Criação e versionamento |
| **Aula** | 07 — Versionamento e organização - prática (16:44) |
| **Assunto** | Montar um repositório de prompts (prompt-registry) e usar a IA para catalogar e documentar |
| **Data** | 04/11/2026 00:05 |
| **Tags** | pratica, prompt-registry, repositorio, readme-por-prompt, claude-code, catalogacao-automatica, git-commit |

## Resumo da aula

Como organizar prompts na prática, com um repositório `prompt-registry` de ponto de partida. Cada **domínio** é uma pasta; cada **prompt** é uma pasta com `prompt.md` (o prompt) + `README.md` (a documentação/metadados). Um comando de IA (Claude Code) classifica, documenta e cataloga o prompt automaticamente.

> Escopo: prompts de **uso individual** (Claude.ai, Claude Code). Para agentes de codificação/IA, a estrutura é diferente (módulos futuros).

## Conceitos principais

### Estrutura do repositório

```
prompt-registry/
├── README.md              # índice do catálogo
├── CLAUDE.md              # instruções para o agente de IA sobre o repo
├── .claude/commands/      # comandos (prompts) do Claude Code (ex.: catalogar)
├── devops/
│   └── auditar-dockerfile-python/
│       ├── prompt.md      # o prompt exato
│       └── README.md      # metadados + documentação do prompt
├── sre/
├── desenvolvimento/
└── ...                    # demais domínios
```

- Cada prompt = pasta com `prompt.md` + `README.md`.
- `README.md` do prompt traz metadados (nome, descrição, versão, ferramentas, tags, inputs) + objetivo, quando usar, pré-requisitos, limitações, exemplos.
- Organização por **domínio**, não por técnica.

### Catalogação assistida por IA

Um comando (prompt) lê o prompt a catalogar, **infere os metadados** (nome, descrição, tags, inputs), **classifica em uma categoria/domínio** e propõe o plano: slug, caminho final, front matter, preview do `prompt.md` (inalterado) e o `README.md`. Você **aprova** antes de criar. Ao criar, ele também atualiza o README do domínio e o README principal. Depois, `commit`.

> O instrutor reforça: valide o que a IA faz, não aceite cego. Use o repositório como **base** e adapte (ex.: adicionar suporte a documentar prompt chaining).

## Comandos e configurações

<details>
<summary>Fluxo da prática (Claude Code / outra ferramenta de codificação)</summary>

```bash
# 1. Clonar o repositório-base de prompts
git clone <url-do-prompt-registry>

# 2. No Claude Code, rodar o comando de catalogação passando o prompt a classificar
#    (ele infere metadados, classifica no domínio e propõe o plano para aprovação)

# 3. Aprovar o plano (ok) -> cria prompt.md + README.md, atualiza READMEs

# 4. Commitar
#    "faça o commit dos arquivos"  (o próprio agente gera o commit)
```

</details>

## Pegadinhas

- Este boilerplate é ponto de partida — adapte categorias, metadados e suporte (ex.: prompt chaining) ao seu fluxo.
- O comando de catalogação **não altera** o prompt, só cataloga — se quiser recomendações, ajuste o comando.
- `CLAUDE.md` é o "README para o agente" — detalhado nos módulos de agentes de codificação.

## Dúvidas para revisar

- Quais domínios iniciais fazem sentido para o meu catálogo (sre, infra, finops, pessoal)?
- Vale criar links simbólicos do registry para os projetos onde uso os prompts?
