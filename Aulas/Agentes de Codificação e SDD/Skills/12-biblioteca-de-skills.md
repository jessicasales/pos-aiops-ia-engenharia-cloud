# Biblioteca de Skills — escala e governança

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 12 — Biblioteca de Skills (28:29) |
| **Assunto** | Centralizar e distribuir skills com marketplace, plugins, vitrine estática e links simbólicos |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `marketplace` `plugins` `harness library` `marketplace.json` `plugin.json` `Astro` `GitHub Pages` `symlink` `distribuição` `governança` |

## Resumo da aula

Para usar IA de forma estratégica, não basta criar skills: é preciso **padronizar e distribuir** para equipe, projetos e empresa, a partir de um meio centralizado. A Anthropic definiu o padrão de **marketplace**: um repositório Git com `.claude-plugin/marketplace.json` + skills organizadas em **plugins** por área/domínio, consumido como plugin no Claude Code (e também instalável via `npx skills add`).

O professor usa o template **boilerplate-harness-library**, que soma ao marketplace uma **vitrine estática em Astro** (busca, categorias, documentação, comando de instalação), hospedável no GitHub Pages, S3 ou Nginx. Na aula, as skills espalhadas pelos projetos (brainstorm, criar-design-docs, dockerizar-aplicacao, terraform-guidelines) são organizadas pela IA em três plugins, documentadas, e depois as cópias nos projetos são trocadas por **links simbólicos** para a biblioteca.

## Conceitos principais

### Repositórios
| Repositório | O que é |
|---|---|
| https://github.com/anthropics/skills | Padrão de marketplace da Anthropic — `.claude-plugin/marketplace.json` + `skills/` |
| https://github.com/fabricioveronez/boilerplate-harness-library | Template da aula: marketplace + vitrine em Astro |

### Estrutura da harness library
```text
harness-library/
├── .claude-plugin/
│   └── marketplace.json        # lista os plugins (name, source, description, owner)
├── plugins/
│   ├── uso-geral/
│   │   ├── .claude-plugin/plugin.json   # nome, versão, descrição, autor
│   │   ├── skills/brainstorm/
│   │   └── docs/brainstorm.md            # doc com o mesmo nome da skill
│   ├── desenvolvimento/   # criar-design-docs
│   └── devops/            # dockerizar-aplicacao, terraform-guidelines
└── site/                  # vitrine Astro
```
- Organize por **área de atuação/domínio** (DevOps, desenvolvimento, marketing, conteúdo...).
- **Toda skill ganha documentação** em `docs/<skill>.md`: para que serve, fases, modos, gatilhos, dependências e referências. "Assim como o código, você mesmo esquece com o tempo."

### Link simbólico × cópia
| Forma | Uso |
|---|---|
| `npx skills add <repo>` | Faz **cópia** — bom para consumir |
| `ln -s` para a biblioteca clonada | Alterou a skill no projeto, alterou na biblioteca — **sem drift** entre cópia e repositório central |

## Comandos e prompts

```bash
# Faça fork do boilerplate e clone da sua conta
git clone https://github.com/<seu-usuario>/boilerplate-harness-library

# Subir a vitrine local
cd site
npm install
npm run build
npm run preview   # (npm run dev para modo desenvolvimento)

# Symlink manual
ln -s ~/harness-library/plugins/<plugin>/skills/<skill> .claude/skills/<skill>
```

```text
# Em Plan Mode (Shift+Tab) — tarefa longa, veja o plano antes
Encontre nos projetos as skills de brainstorm, design docs, docker e terraform. Organize as skills em três plugins dentro do repositório <caminho do repositório>: desenvolvimento, uso geral e devops. Identifique os melhores locais para cada skill e adicione a sua documentação.
```

| Pergunta do agente | Resposta |
|---|---|
| Existem duas versões da brainstorm, qual levar? | A do projeto |
| O que fazer com os plugins de exemplo do boilerplate? | Limpar tudo |
| Copiar ou mover as skills dos projetos de origem? | Copiar |

```text
Agora, quero remover os arquivos dos projetos originais e substituir por links simbólicos apontando para o repositório harness library.
```

## Pegadinhas
- Faça **fork** do boilerplate em vez de clonar direto.
- Ajuste `owner`, nome e e-mail no `marketplace.json` (vêm com os dados do professor).
- Confira a integridade das skills copiadas pela IA.
- Dá para colocar um **pipeline** que regenera e publica a vitrine a cada commit.
- O symlink exige a biblioteca clonada localmente.

## Dúvidas para revisar
- Montar minha própria harness library com plugins por domínio e publicar a vitrine no GitHub Pages.
