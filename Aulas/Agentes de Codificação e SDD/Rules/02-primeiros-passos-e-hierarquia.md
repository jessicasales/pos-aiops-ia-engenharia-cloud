# Primeiros Passos e Hierarquia

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Rules |
| **Aula** | 02 — Primeiros Passos e Hierarquia (35:32) |
| **Assunto** | `CLAUDE.md`/`AGENTS.md` na prática: carregamento eager na raiz vs. carregamento sob demanda em subdiretórios, compatibilização via import/symlink, e o comando `/init` |
| **Data** | 29/10/2026 17:20 |
| **Tags** | claude.md, agents.md, hierarquia, import, symlink, init, monorepo, janela-de-contexto |

## Resumo da aula

Aula prática e extensa, demonstrando ao vivo (com erros reais, sem cortes) como o `CLAUDE.md`/`AGENTS.md` funciona no projeto Encontros Tech. O instrutor prova empiricamente dois comportamentos centrais: (1) o arquivo de regras na **raiz** do projeto é carregado *eager* — já está na janela de contexto desde a abertura da sessão, antes de qualquer tool ser executada; (2) um arquivo de regras em um **subdiretório** só é carregado *sob demanda*, quando o agente efetivamente lê/escreve naquele diretório — economia de contexto essencial em monorepos. A aula também cobre como compatibilizar `CLAUDE.md` com `AGENTS.md` (import ou symlink) e apresenta o comando `/init` para gerar uma primeira versão do arquivo de regras.

## Conceitos principais

### CLAUDE.md / AGENTS.md é o "README do agente"

Da mesma forma que um humano lendo um projeto novo começaria pelo `README.md` (objetivo, stacks, como rodar), o agente de IA precisa de um documento equivalente — é isso que o `CLAUDE.md`/`AGENTS.md` fornece. Sem ele, o agente é forçado a varrer todo o projeto (buscar arquivos, detectar linguagem, verificar se há Docker/Kubernetes etc.) para responder qualquer pergunta básica sobre o projeto — processo visivelmente mais lento, demonstrado na aula com o prompt "Quero saber as principais stacks desse projeto" antes de existir o arquivo de regras.

### AGENTS.md vs. CLAUDE.md — por que a diferença de nome

- **AGENTS.md**: padrão aberto, adotado pelas principais ferramentas de IA do mercado (agents.md é o "README para agentes de IA", em contraste com o README.md, que é para humanos).
- **CLAUDE.md**: nome específico usado pelo Claude Code (decisão da Anthropic de usar seu próprio padrão em vez de adotar o `AGENTS.md`).

Funcionalmente são equivalentes — o objetivo é o mesmo, apenas o arquivo lido difere por ferramenta (Claude Code lê `CLAUDE.md`; a maioria das outras ferramentas lê `AGENTS.md`).

### Conteúdo mínimo demonstrado

```markdown
# Objetivo

O objetivo do projeto é ser uma plataforma de cadastro de eventos.

# Stacks principais

- Python
- Docker
- Kubernetes
- PostgreSQL
```

Regra importante: **não** transformar o `CLAUDE.md`/`AGENTS.md` em um "testamento" com todas as informações detalhadas do projeto — isso ocupa a janela de contexto inicial desnecessariamente, aumentando o risco de estouro de contexto. Deve conter apenas o essencial.

### Carregamento eager (raiz) vs. sob demanda (subdiretório)

Demonstração prática com o comando `/context` (mostra o que está ocupando a janela de contexto):

1. **Antes de criar o `CLAUDE.md`**: pergunta sobre stacks do projeto exige uma varredura completa (bash, search) — mais lenta.
2. **Depois de criar o `CLAUDE.md` na raiz e reiniciar a sessão** (é necessário fechar e reabrir o Claude Code — o arquivo só é lido na inicialização): a mesma pergunta é respondida mais rápido e de forma mais direcionada, já sabendo, por exemplo, que o projeto é Python e indo direto a `requirements.txt`.
3. **Prova do carregamento eager**: pedindo explicitamente "sem executar nenhuma tool, responda qual é a stack do projeto e o objetivo dele" — o agente responde corretamente mesmo proibido de usar ferramentas, provando que o `CLAUDE.md` da raiz já estava carregado desde a abertura.
4. **Arquivo de regras em subdiretório**: criando um segundo `CLAUDE.md` dentro de `docs/` com uma informação diferente (ex.: sobrenome diferente do colocado na raiz) — esse arquivo **não aparece no `/context`** até que o agente seja instruído a trabalhar especificamente dentro de `docs/` (ex.: "escreva no diretório docs/ um arquivo com meus dados pessoais"). Só nesse momento o `CLAUDE.md` daquele subdiretório é lido e aplicado.

Essa é a "sacada" central da aula: arquivos de regras em subdiretórios só carregam quando o agente realmente vai operar naquele diretório — permitindo granularidade de regras por área, essencial em **monorepos** (front-end, back-end, Terraform, etc., todos no mesmo repositório), tema de uma aula futura do capítulo.

### Observações durante a demo (erros reais, mantidos de propósito)

- O agente às vezes recorre a outras fontes de dados (ex.: configuração do Git) mesmo sendo instruído a não usar ferramentas além de `write` — reforçando que é preciso refinar as instruções do arquivo de regras.
- Depois que o `CLAUDE.md`/`AGENTS.md` já está carregado na sessão, basta rodar `/clear` (sem precisar fechar e reabrir a ferramenta) para que as edições feitas no arquivo sejam recarregadas — mas a **primeira** carga do arquivo sempre exige reiniciar a sessão.

### Compatibilizando CLAUDE.md com AGENTS.md

Duas formas demonstradas para evitar duplicar conteúdo entre as duas convenções:

1. **Import** (recomendado/boa prática): o `CLAUDE.md` referencia o `AGENTS.md` com `@AGENTS.md`. O Claude Code entende isso como uma instrução de import e carrega o conteúdo do `AGENTS.md`. Funciona também em outras ferramentas (ex.: Codex, que lê `AGENTS.md` nativamente).
2. **Symlink**: `ln -s AGENTS.md CLAUDE.md` (ou o inverso), fazendo os dois arquivos apontarem para o mesmo conteúdo físico. Ressalva: ferramentas que leem ambos os arquivos (ex.: OpenCode, que aceita tanto `AGENTS.md` quanto `CLAUDE.md`) podem acabar carregando o conteúdo **em dobro** nesse cenário — por isso o import é a abordagem preferida.

### O comando `/init`

Praticamente todos os agentes de codificação (Claude Code e outros) oferecem um comando (`/init` no Claude Code) que lê todo o projeto e gera automaticamente uma primeira versão do `CLAUDE.md`/`AGENTS.md` — detectando stack, arquitetura, comandos de inicialização, pegadinhas conhecidas, fluxo de deploy, etc. É um bom ponto de partida, mas **não deve ser usado sem revisão**: o conteúdo gerado precisa ser revisado e ajustado manualmente (detalhado na próxima aula do capítulo).

## Comandos e configurações

```
/context       # mostra o que ocupa a janela de contexto (System Prompt, MCP Tools, Memory Files, Skills, CLAUDE.md, etc.)
/context all   # versão detalhada, mostrando inclusive os tokens ocupados por cada CLAUDE.md carregado
/clear         # limpa a sessão e recarrega CLAUDE.md/AGENTS.md já editados (sem precisar fechar/reabrir)
/init          # gera automaticamente uma primeira versão do CLAUDE.md/AGENTS.md a partir da análise do projeto
```

```markdown
<!-- CLAUDE.md de exemplo na raiz -->
# Objetivo
O objetivo do projeto é ser uma plataforma de cadastro de eventos.

# Stacks principais
- Python
- Docker
- Kubernetes
- PostgreSQL
```

```markdown
<!-- compatibilização via import -->
@AGENTS.md
```

```bash
# compatibilização via symlink (alternativa ao import)
ln -s AGENTS.md CLAUDE.md
```

## Pegadinhas

- Editar o `CLAUDE.md`/`AGENTS.md` com a sessão já aberta não tem efeito imediato — é preciso fechar e reabrir o agente (ou, uma vez já carregado antes, rodar `/clear`) para a mudança ser aplicada.
- O arquivo de regras da raiz é carregado **eager** (sempre, desde a abertura) e por isso consome a janela de contexto inicial permanentemente — evitar colocar informações excessivas ali.
- Um `CLAUDE.md` em subdiretório só é lido quando o agente **efetivamente opera** naquele diretório (escreve ou lê algo lá) — não basta ele existir.
- Usar symlink para compatibilizar `CLAUDE.md`/`AGENTS.md` pode causar carregamento duplicado em ferramentas que leem ambos os nomes (ex.: OpenCode) — prefira import (`@AGENTS.md`).
- O agente pode buscar dados em fontes alternativas (como configuração do Git) mesmo quando instruído a não usar ferramentas externas — vale testar e refinar o comportamento antes de confiar cegamente.
- O `/init` gera um ótimo ponto de partida, mas nunca deve ser usado "no estado em que está" — requer revisão e curadoria manual.

## Dúvidas para revisar

- Quais critérios usar para decidir o que fica no `CLAUDE.md` da raiz vs. o que deve ir em `CLAUDE.md`s específicos de subdiretórios?
- No projeto Encontros Tech, quais pastas (`docs/`, `src/`, `k8s/`, etc.) já teriam um `CLAUDE.md` próprio fazendo sentido?
- Como a hierarquia de `CLAUDE.md`s se comporta em um monorepo real com múltiplos serviços — cada serviço tem seu próprio arquivo, além de um na raiz do repositório?
