# Criação e versionamento — Engenharia de Prompt e Contexto

Anotações do capítulo **Criação e versionamento** do módulo **Engenharia de Prompt e Contexto** (curso Pós AIOps e IA na Engenharia de Cloud).

A virada do capítulo: sair de **escritor de prompts** (que escreve tudo à mão) para **diretor** que usa a IA para criar, refinar e transformar prompts — e trata o prompt como **artefato versionado**, igual ao código.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 06:54 | De escritor a diretor; prompt como ativo vivo |
| 02 | [Meta prompt](02-meta-prompt.md) | 07:43 | Craft, orquestração, otimização; modelo caro na criação |
| 03 | [Geração direta](03-geracao-direta.md) | 24:42 | Gerar prompt do zero; tags XML e variáveis |
| 04 | [Refinamento de prompt](04-refinamento-de-prompt.md) | 09:00 | Aprimorar um prompt existente por critérios |
| 05 | [Transformação de prompt](05-transformacao-de-prompt.md) | 09:48 | Gerar variantes por técnica e comparar |
| 06 | [Versionamento e organização](06-versionamento-e-organizacao.md) | 22:06 | Formato, metadados, organização, Git |
| 07 | [Versionamento e organização - prática](07-versionamento-e-organizacao-pratica.md) | 16:44 | Repositório prompt-registry + catalogação com IA |

## Resumo rápido

### Meta prompt — 3 operações
1. **Gerar** (geração direta) — do zero, a partir de uma descrição.
2. **Refinar** — aprimorar um prompt existente por critérios (custo, feature).
3. **Transformar** — gerar variantes aplicando técnicas (CoT, ToT) e comparar.

### Meta prompt — 3 significados
- **Craft** (foco): IA cria o prompt, humano no controle.
- **Orquestração**: LLM maestro gera prompts para multiagentes.
- **Otimização automática**: IA gera o prompt de ponta a ponta.

### Versionamento
- Formato: **Markdown** (80%), YAML (sistemas/agentes), JSON (API — evitar).
- Metadados via **front matter** (Markdown) ou campos (YAML).
- Organização por **domínio**, nunca por técnica.
- **Git** (branch, PR, changelog) + links simbólicos para fonte única.

> Dica transversal: modelo caro e com reasoning para **criar/refinar**; modelo barato para **executar**.
