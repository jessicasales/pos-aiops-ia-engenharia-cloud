# Monorepo: Regras por Área

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Rules |
| **Aula** | 05 — Monorepo: Regras por Área (21:58) |
| **Assunto** | Estrutura hierárquica de `CLAUDE.md`/`AGENTS.md` em monorepos: raiz com visão macro + um arquivo autossuficiente por área/camada |
| **Data** | 29/10/2026 18:15 |
| **Tags** | monorepo, agents.md, claude.md, hierarquia, autossuficiente, progressive-disclosure, fake-shop |

## Resumo da aula

Última aula do capítulo "Rules", aplicando o conceito de hierarquia de `CLAUDE.md`/`AGENTS.md` (visto na aula "Primeiros Passos e Hierarquia") a um cenário de **monorepo**: um único repositório com múltiplas camadas/microserviços (ex.: back-end e front-end em diretórios separados). A demo usa um projeto de exemplo chamado **Fake Shop**, com duas camadas: `apps/api` (back-end em Python) e `apps/web` (front-end em React). A sacada central: colocar no `CLAUDE.md` da raiz apenas uma visão macro (apontando para cada subprojeto, sem detalhar), e criar um `CLAUDE.md` próprio e **autossuficiente** em cada subdiretório de camada/microserviço.

## Conceitos principais

### O problema: um único AGENTS.md ficando gigante

Em um monorepo, se todas as informações (inicialização do front-end, do back-end, estrutura de cada subdiretório) forem colocadas em um único `CLAUDE.md` na raiz, o arquivo rapidamente ultrapassa o teto recomendado de 200 linhas e mistura contextos que não são sempre necessários simultaneamente.

### A solução: hierarquia por diretório

Já visto em aula anterior (Primeiros Passos e Hierarquia): um `CLAUDE.md` em subdiretório só é carregado quando o agente efetivamente trabalha ali. Isso permite:
- `CLAUDE.md` da **raiz**: visão macro do monorepo, com uma estrutura de diretórios apontando para cada subprojeto (ex.: "`apps/api` é o diretório do projeto back-end", "`apps/web` é o diretório do projeto front-end"), sem entrar em detalhes de cada um.
- `CLAUDE.md` de **cada camada/subprojeto**: documento especializado, tratando aquele diretório como **autossuficiente** — sem repetir as informações já cobertas na raiz.

Isso é comparado explicitamente ao **progressive disclosure** já estudado com Skills: o agente só carrega na janela de contexto o que é necessário no momento, por demanda, em vez de carregar tudo de uma vez.

### Demonstração prática — gerando os 3 níveis

Usa-se o mesmo prompt-base da aula "Como Escrever o seu AGENTS.md" (6 blocos, teto de 200 linhas), aplicado em 3 alvos diferentes:

1. **Raiz do monorepo**: ao rodar o prompt sem ajustes, o agente identificou sozinho (sem ser informado) que o projeto tem duas camadas (SPA + API REST) mantidas como monorepo, e que foi reescrito a partir de um monolito Flask original — mas gerou os comandos de build/teste e a estrutura de projeto tratando tudo de forma unificada (ex.: `docker compose run`), o que não escalaria em um monorepo mais complexo. Ajuste manual necessário: simplificar a seção "Estrutura do projeto" para apenas apontar para os diretórios (`apps/api` = back-end, `apps/web` = front-end), sem detalhar.
2. **`apps/api` (back-end)**: prompt ajustado com a instrução adicional "Trate esse diretório como autossuficiente, explicando apenas o que existe nessa hierarquia. Os dados gerais existem no CLAUDE.md raiz do projeto." O resultado documentou a API de forma totalmente independente (API REST da loja: catálogo, carrinho, checkout, consulta de pedido, imagens de produto, métricas), incluindo um ajuste manual para que os comandos de build/teste tratassem a API **sozinha**, sem depender do Docker Compose da raiz (execução direta com pip install/Python).
3. **`apps/web` (front-end)**: mesma lógica, com a instrução adicional "Os comandos de build e de teste devem ser tratados considerando apenas a aplicação independente, sem considerar a raiz e a stack completa." O resultado documentou a SPA (React 19, TypeScript 5.7), incluindo detalhes específicos como persistência do carrinho via `localStorage` (sem autenticação) — e o próprio agente reportou que deixou o teste end-to-end explicitamente fora de escopo nesse arquivo.

### Benefício de gerenciamento de contexto

Com essa estrutura, a janela de contexto é gerenciada **por demanda**: ao iniciar o projeto, só o `CLAUDE.md` da raiz é carregado; se o agente precisa trabalhar no back-end, carrega as informações de `apps/api`; se precisa trabalhar no front-end, carrega as de `apps/web` — nunca tudo de uma vez.

### Recomendação de alinhamento de equipe

Em monorepos, é comum haver permissões diferenciadas por equipe/usuário (comum no GitHub, por exemplo). O instrutor recomenda alinhar com as equipes não só a navegabilidade via `AGENTS.md`/`CLAUDE.md`, mas também quais informações são de escopo de cada camada/microserviço — para que a estrutura hierárquica reflita a divisão real de responsabilidades do time.

### Regra geral de fechamento do capítulo

- `CLAUDE.md`/`AGENTS.md` da **raiz**: estrutura geral, visão macro, especificações em alto nível, apontamento de diretórios sem detalhar.
- `CLAUDE.md`/`AGENTS.md` de **cada projeto/camada**: documento especializado e autossuficiente, seguindo o mesmo princípio de progressive disclosure já visto em Skills.

## Comandos e configurações

```text
# prompt-base (mesmo da aula "Como Escrever o seu AGENTS.md"), aplicado por nível

# Nível 1 — raiz do monorepo
Reescreva o CLAUDE.md na raiz deste repositório, do zero.
(... segue o prompt-base de 6 blocos com teto de 200 linhas ...)

# Nível 2 — apps/api (back-end, autossuficiente)
Reescreva o CLAUDE.md do diretório apps/api deste repositório, do zero.
(... prompt-base ...)
Trate esse diretório como autossuficiente, explicando apenas o que existe nessa
hierarquia. Os dados gerais existem no CLAUDE.md raiz do projeto.

# Nível 3 — apps/web (front-end, build/teste independentes)
Reescreva o CLAUDE.md do diretório apps/web deste repositório, do zero.
(... prompt-base ...)
Os comandos de build e de teste devem ser tratados considerando apenas a aplicação
independente, sem considerar a raiz e a stack completa.
```

## Pegadinhas

- Rodar o prompt-base sem ajustes na raiz de um monorepo pode gerar uma estrutura de projeto detalhada demais, misturando comandos de build de todas as camadas — exige edição manual para simplificar e apontar apenas para os subdiretórios.
- Um `CLAUDE.md` de subprojeto gerado automaticamente pode herdar o comando "global" (ex.: `docker compose run`) em vez do comando isolado daquela camada — é preciso instruir explicitamente a tratar o diretório como autossuficiente/independente.
- Decidir se cada camada deve ou não ter seu próprio Docker Compose (em vez de depender do Compose raiz) é uma decisão de gerenciamento de monorepo que impacta diretamente a redação dos comandos de build/teste em cada `CLAUDE.md`.

## Dúvidas para revisar

- Como ficaria a hierarquia de `CLAUDE.md`s em um monorepo com mais de duas camadas (ex.: api + web + worker + infra como código)?
- Vale criar uma skill dedicada (como sugerido na aula) para automatizar a geração/manutenção desses múltiplos `CLAUDE.md`s hierárquicos?
- Como alinhar, na prática, as permissões de time no GitHub com a estrutura de diretórios e `CLAUDE.md`s de um monorepo?
