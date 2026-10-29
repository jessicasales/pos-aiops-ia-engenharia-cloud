# Skill com Script — gerar e validar Docker

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 07 — Skill com Script (37:02) |
| **Assunto** | Criar uma skill a partir da janela de contexto, com script de validação determinística |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `scripts` `janela de contexto` `docker` `docker-compose` `hadolint` `validação determinística` `brainstorm` `skill-creator` `dockerizar-aplicacao` |

## Resumo da aula

Demonstra a criação de skill **pela janela de contexto**: primeiro o professor faz um "vibe DevOps" no projeto **kube-news** (Node.js + Express + Sequelize + PostgreSQL, porta 8080) pedindo Dockerfile, `.dockerignore` e docker-compose; depois pede um plano de validação (IA + análise estática com **hadolint** + execução real com compose); ajusta o entregável para ser a **correção** dos arquivos, e executa.

Com o fluxo validado na janela de contexto, chama `/skill-creator` + **modo brainstorm** para destilar a sessão numa skill reaproveitável para várias stacks: **`dockerizar-aplicacao`**, com `references/` por linguagem e `scripts/validar.sh`. Na execução da skill o script teve um bug (comportamento diferente no Mac), corrigido com `/skill-creator Corrija o script da skill`.

## Conceitos principais

### Criar skill pela janela de contexto
- Ideal quando o fluxo **ainda não está definido**: você trabalha com o agente, corrige, e no final destila.
- Técnica usada por agentes como o **Hermes**.
- Carregar a **skill-creator** junto com o **brainstorm** dá ao agente as boas práticas e a estrutura de uma skill (sem isso, ele só tem o que o modelo sabe).

### Combinar validação probabilística + determinística
| Camada | Ferramenta |
|---|---|
| Revisão por IA (boas práticas de Dockerfile/compose) | Modelo |
| Análise estática (lint de Dockerfile) | **hadolint** |
| Teste real de execução | `docker compose up`, logs, smoke test |

### Estrutura da skill gerada
```text
.claude/skills/dockerizar-aplicacao/
├── SKILL.md            # preflight → detectar stack → gerar/corrigir → validar → corrigir até verde → reportar
├── references/         # detecção, serviços de apoio, boas práticas, node, python, java, dotnet, go, rust
└── scripts/
    └── validar.sh      # roda hadolint (via Docker) e a validação
```
- Dois modos: **gerar do zero** e **auditar/corrigir** um Dockerfile existente (sugestão da IA no brainstorm).
- Hardening por padrão em modo simples: não-root, secrets, banco interno, healthcheck.
- **Preflight**: verificar se o Docker daemon está rodando (aprendizado que veio da própria sessão).
- Um arquivo de referência **por linguagem** (progressive disclosure).

### Scripts em skills
- Mais usados: **Shell Script** e **Python**; Node só para casos específicos.
- Evitar binários (versionamento complicado).

## Prompts da aula

<details>
<summary>Prompt 1 — criar os artefatos de Docker</summary>

```text
Faça uma análise do projeto atual e, baseado nas características desse projeto — tecnologia de desenvolvimento, stack, bibliotecas, dependências para a execução dele — crie tudo o que é necessário para executar em containers Docker, criando o Dockerfile, o .dockerignore e também o docker-compose. Todas as dependências para executar esse projeto devem estar no docker-compose, para que ele seja utilizado para subir toda a stack com uma linha de comando. O Dockerfile deve ficar dentro da pasta do projeto.
```
</details>

<details>
<summary>Prompt 2 — plano de validação</summary>

```text
Agora, eu quero que seja feito um processo de validação, onde vão ser verificadas boas práticas de execução e de criação do Docker, verificando a qualidade do Dockerfile referente a esse projeto e do docker-compose, tudo isso sendo feito pela inteligência artificial. Mas eu quero também fazer uma validação utilizando análise estática, utilizando o projeto abaixo: https://github.com/hadolint/hadolint
Esse processo de validação também deve incluir a execução da aplicação utilizando o docker-compose. E, com base no projeto, faça uma análise de como deve ser testado com o docker-compose para garantir que a aplicação está funcionando. Não implemente nada no momento, só retorne o plano de ação.
```
</details>

<details>
<summary>Prompt 3 — trocar o entregável</summary>

```text
Eu quero alterar esse planejamento. O resultado final não deve ser o relatório. O resultado final deve ser a correção do Dockerfile e também do docker-compose. Analise e retorne o novo plano, sem implementar nada ainda.
```
</details>

<details>
<summary>Prompt 4 — destilar a janela de contexto na skill</summary>

```text
/skill-creator Eu quero que você entre em modo brainstorm. O objetivo é analisar a janela de contexto e capturar todo o fluxo executado nela para criar o Dockerfile, docker-compose e .dockerignore para a aplicação, e tornar a aplicação executável em ambientes Docker. O objetivo é fazer uma skill que seja reaproveitável em diversas tecnologias, não somente focando na stack do projeto atual.
```
Freios antes de executar:
```text
A skill deve ser criada a nível de projeto. Ignore o harness library. Revise o plano de ação e não execute ainda.
Remova o caso de teste da skill. Apenas crie e eu mesmo vou testar.
```
</details>

```text
/skill-creator Corrija o script da skill.   # prompt 5
docker compose up --build                   # validação manual → http://localhost:8080
```

Links: projeto [kube-news](https://github.com/KubeDev/kube-news) · linter [hadolint](https://github.com/hadolint/hadolint)

## Pegadinhas
- Sempre peça o **plano antes de executar** ("não implemente nada ainda"), senão o agente sai fazendo.
- O agente às vezes "teima" (ex.: incluiu Rust sem pedir) — seja mais assertivo nas diretrizes.
- Modelo pode usar versões antigas de imagem (Node 18 na sessão; a skill passou a usar Node 20). Considere mandar pesquisar a versão atual.
- Scripts podem se comportar diferente entre plataformas (Mac × Linux) — teste em mais de uma.
- Skill quase nunca acerta de primeira: **use, observe e refine continuamente**.

## Dúvidas para revisar
- Montar uma skill parecida para os padrões de Docker que uso no trabalho, com hadolint no script.
