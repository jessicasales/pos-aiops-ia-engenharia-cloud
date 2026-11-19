# Versionamento e organização

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Criação e versionamento |
| **Aula** | 06 — Versionamento e organização (22:06) |
| **Assunto** | Prompt como código: formato, metadados, organização por domínio e versionamento no Git |
| **Data** | 04/11/2026 00:05 |
| **Tags** | versionamento, prompt-como-codigo, markdown, yaml, json, front-matter, metadados, git, link-simbolico |

## Resumo da aula

Um prompt não é criado uma vez e esquecido — ele é **ativo vivo**. Um prompt campeão pode parar de funcionar por mudança de **modelo** (depreciação, modelos novos o tempo todo) ou de **contexto/input**. Por isso, versione os prompts como você versiona código: **rastreabilidade** (qual versão/modelo gerou aquele output), **rollback** e **colaboração** (branches, aprovação, teste).

## Conceitos principais

### Formato (80% dos casos: Markdown)

| Formato | Quando usar |
|---|---|
| **Markdown** | Padrão (texto puro, economia de tokens, legível). Default se estiver na dúvida |
| **YAML** | Dado estruturado; agentes que consomem prompts (LangChain lê YAML); desacopla prompt do código |
| **JSON** | Integração/API/MCP que servem prompts. Menos legível e mais tokens — menos recomendado |

### Metadados

O prompt precisa carregar: nome, objetivo, quando usar, versão, modelo, data, tags, descrição, proprietário, inputs esperados. Em **Markdown** use **front matter** (bloco YAML entre `---` no topo) — mas cuidado: algumas ferramentas interpretam o front matter como parte do prompt. Em YAML, os metadados são campos + um campo `prompt`.

> Regra prática: se leva mais tempo organizar o metadado do que criar o prompt, virou burocracia.

### Organização do repositório

- **Erro comum**: organizar por **técnica** (chain-of-thoughts/, few-shot/) — errado, como organizar código por linguagem.
- **Certo**: organizar por **domínio/área/funcionalidade** (code-review/, sre/, infra/, financeiro/, uso-pessoal/).

### Reuso entre projetos: link simbólico

Não copie e cole prompts entre projetos (fragmenta o versionamento). Use **links simbólicos** apontando para o repositório único de prompts — alterou em um lugar, reflete em todos.

### Versionamento no Git

Aplique as práticas de código: branch principal, feature branch para novo/alterado prompt, teste/avaliação (até pipeline de avaliação automatizada e teste A/B), pull request, merge e **changelog**. Comece simples com Git; ferramentas de mercado (PromptLayer, LangFuse, LangSmith, Promptfoo, HumanLoop) vêm depois (muitas pagas/acopladas).

## Comandos e configurações

Aula conceitual; a prática está na aula 07.

## Pegadinhas

- Front matter em Markdown pode "vazar" para o prompt em algumas ferramentas.
- JSON consome mais tokens e é menos legível — evite salvo integração/API.
- Copiar/colar prompt entre projetos destrói o versionamento central.

## Dúvidas para revisar

- Markdown + front matter ou YAML para o meu repositório de prompts?
- Como montar um fluxo Git (branch + PR + changelog) para prompts no time?
