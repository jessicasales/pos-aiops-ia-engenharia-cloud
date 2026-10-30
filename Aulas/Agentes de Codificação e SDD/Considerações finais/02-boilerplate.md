# Boilerplate

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Considerações finais |
| **Aula** | 02 — Boilerplate (14:01) |
| **Assunto** | Greenfield vs. Brownfield, e por que manter boilerplates prontos (estrutura inicial + `AGENTS.md`/`CLAUDE.md` + scripts de operação) economiza tempo ao iniciar novos projetos com IA |
| **Data** | 29/10/2026 23:20 |
| **Tags** | boilerplate, greenfield, brownfield, estrutura-inicial, fastapi, uvicorn, idp |

## Resumo da aula

Dica prática para projetos **Greenfield** (do zero): manter sempre um **boilerplate** pronto — uma estrutura inicial de projeto já configurada, incluindo dependências, Docker Compose, scripts de operação e até o próprio `AGENTS.md`/`CLAUDE.md` — evita "gastar" uma rodada inteira de uso da IA só para montar o esqueleto do projeto, permitindo começar direto pela implementação de features reais.

## Conceitos principais

### Greenfield vs. Brownfield

- **Brownfield**: projeto já existente (em desenvolvimento ou legado em manutenção). Desafios: mapear componentes, estrutura de diretórios e arquitetura já existentes, definir padrões para dar contexto à IA. Projetos legados são particularmente desafiadores porque a IA tende a replicar padrões — e exceções/bypasses que fogem à regra (comuns em código legado) podem levar a alucinações, já que a IA tenta mapear um padrão que não existe de forma consistente.
- **Greenfield**: projeto do zero, "página em branco". É o foco desta aula.

### O problema do "marco zero"

Mesmo em um fluxo já maduro de SDD/harness (PRDs, TRDs, ADRs, specs, tasks), todo projeto novo tem uma etapa inicial repetitiva: criar a estrutura de diretórios, configurar dependências/bibliotecas, Docker Compose, Dockerfile, scripts de operação. Essa estrutura inicial tende a ser muito parecida entre projetos do mesmo tipo (ex.: toda aplicação web tem uma "cara" parecida) — repetir esse processo a cada novo projeto via IA desperdiça tempo que poderia ir direto para as features.

### Boilerplate — a solução

Um **boilerplate** é a estrutura inicial reutilizável de um tipo de projeto. O instrutor apresenta e disponibiliza (via GitHub) um boilerplate de referência para aplicação web em Python, contendo:
- Gerenciador de pacotes (Uvicorn) com dependências já definidas: **FastAPI** (web framework), **Jinja2** (templates), **SQLAlchemy** (ORM), **Uvicorn** (servidor).
- `Docker Compose` e `Dockerfile` já configurados (incluindo PostgreSQL).
- Arquivo de exemplo de variáveis de ambiente.
- Estrutura de pastas da aplicação (`app/`): `main` (inicialização), módulo web (registro de rotas, templates de página, arquivos estáticos CSS — já refletindo um layout/system design básico), modelo ORM, configuração de banco, módulo de API (OpenAPI).
- **Scripts de operação já prontos**: `up`, `start`, `test`, `exec`, `down` — o mesmo padrão ensinado no capítulo "Rules" (aula "Ensinar o Agente a Operar a Aplicação").
- **`AGENTS.md`/`CLAUDE.md` já estruturado**, com as rules iniciais do projeto — eliminando a necessidade de criar esse arquivo do zero a cada novo projeto.

### Demonstração

Clonando o boilerplate e abrindo o Claude Code com o prompt "inicie o projeto": o agente já sabe como executar a aplicação (usa os scripts prontos), sem precisar implementar nada disso — a aplicação sobe, o endpoint de documentação OpenAPI já lista os endpoints disponíveis (health, ready), tudo sem que isso tenha sido declarado como regra explícita — o próprio agente identifica a estrutura existente (OpenAPI) e a usa.

### Quantos boilerplates manter

Resposta do instrutor: "quantos forem necessários para você ter um melhor desempenho/velocidade". Pode haver um boilerplate por tipo de projeto (ex.: aplicação web, soluções agênticas com um diretório `agents/` dedicado) — depende da estrutura de projetos que a pessoa/empresa costuma trabalhar. Essa abordagem também pode ser incorporada a uma **IDP** (Internal Developer Platform) como estrutura inicial padrão já preparada para agentes de IA.

### Como criar um boilerplate

Não é necessário criar uma skill dedicada para isso (a menos que a empresa precise gerar boilerplates com muita frequência). De forma geral, basta usar o **Plan Mode** de qualquer ferramenta de codificação, passando bem os critérios (estrutura desejada, tipo de arquitetura), combinado com as skills de desenvolvimento já existentes no projeto — isso já é suficiente para gerar um excelente boilerplate.

## Comandos e configurações

Não há scripts/configs inéditos nesta aula — reaproveita os padrões já estabelecidos em capítulos anteriores (scripts `up`/`start`/`test`/`exec`/`down` do capítulo Rules, estrutura de `AGENTS.md`/`CLAUDE.md`). O diferencial é **empacotar tudo isso como ponto de partida reutilizável** em um repositório de boilerplate (o instrutor disponibiliza um boilerplate Python/FastAPI/SQLAlchemy/PostgreSQL como referência no material da aula).

```text
# prompt de teste após clonar o boilerplate
inicie o projeto
```

## Pegadinhas

- Projetos Brownfield (especialmente legados) não se beneficiam da mesma forma de um boilerplate — o desafio ali é mapear o padrão existente (com suas exceções), não criar um novo.
- Um boilerplate "genérico demais" pode não refletir a arquitetura real que a equipe usa — vale sempre otimizar/adaptar o boilerplate de referência ao próprio cenário (ex.: adicionar framework de interface, ajustar camadas).
- Não é necessário criar uma skill dedicada só para gerar boilerplates, a menos que isso seja uma necessidade recorrente e frequente da empresa.

## Dúvidas para revisar

- Vale criar um boilerplate específico para o padrão de projeto usado no curso (Flask + SQLAlchemy + Docker + Kubernetes + OpenSpec), incorporando tudo que foi construído até aqui (scripts, CLAUDE.md, hooks)?
- Como adaptar esse boilerplate de referência (FastAPI) para caso o padrão real de trabalho seja outro framework (ex.: Flask, como usado no projeto Encontros Tech)?
- Faz sentido ter um "boilerplate de boilerplates" — um meta-repositório que organiza diferentes templates por tipo de projeto, para uma equipe ou IDP?
