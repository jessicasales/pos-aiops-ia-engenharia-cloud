# Ensinar o Agente a Operar a Aplicação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Rules |
| **Aula** | 04 — Ensinar o Agente a Operar a Aplicação (33:52) |
| **Assunto** | DevContainers + scripts auxiliares (`up`, `start`, `down`, `test`, `exec`) como abstração determinística sobre o ambiente, referenciada pelo `CLAUDE.md` |
| **Data** | 29/10/2026 18:00 |
| **Tags** | devcontainers, scripts, up, start, down, test, exec, abstracao, idempotencia, monitoramento-de-logs |

## Resumo da aula

Aula prática que resolve um problema real identificado na aula anterior: comandos de build/teste simples (pip install, pytest, docker compose) funcionam bem em cenários locais básicos, mas não escalam quando a aplicação depende de serviços externos (RabbitMQ, outros microserviços) — instruir isso diretamente no `CLAUDE.md` infla o arquivo com cadeias de comandos complexas e determinísticas que não deveriam estar ali. A solução: criar um ambiente isolado com **DevContainers** e encapsular toda a operação (subir, iniciar, derrubar, testar, executar comandos) em **scripts auxiliares**, e então apontar o `CLAUDE.md` para esses scripts, criando uma abstração sobre a ferramenta e o ambiente.

## Conceitos principais

### O problema: comandos determinísticos complexos inflando o CLAUDE.md

Verificar se um serviço externo (ex.: RabbitMQ) está no ar, subir uma stack completa com múltiplas dependências — tudo isso é uma sequência de passos determinísticos (comandos shell/scripts), não algo que deveria virar instrução em linguagem natural espalhada pelo arquivo de regras. Colocar isso diretamente no `CLAUDE.md` torna o documento complexo e difícil de manter.

### A solução: DevContainers + scripts auxiliares

**DevContainers**: projeto open source (containers.dev) que permite criar um ambiente de desenvolvimento isolado usando containers Docker (funciona também com Podman). Ferramentas de suporte: extensão do VS Code, IntelliJ, e a CLI `devcontainers-cli` (comandos `up`, `build`, `exec`, etc.). O DevContainer cria uma camada de isolamento onde a aplicação roda dentro de containers, nunca diretamente na máquina host.

**Scripts auxiliares**: em vez de expor os comandos do DevContainer (ou de qualquer outra ferramenta de ambiente) diretamente no `CLAUDE.md`, cria-se uma pasta `scripts/` com scripts que encapsulam as operações do dia a dia:
- `up`: sobe o ambiente (idempotente — rodar com o ambiente já de pé não pode falhar).
- `start`: inicia a aplicação no ambiente já em execução.
- `down`: derruba o ambiente.
- `test`: roda a suíte de testes a partir do diretório correto (onde os imports do projeto resolvem).
- `exec`: recebe um comando arbitrário e executa dentro do ambiente.

### Fluxo demonstrado na prática

1. **Plan Mode**: pedir para criar um ambiente com DevContainers "de forma local e isolada", com Dockerfile e Docker Compose exclusivos para desenvolvimento. O agente pergunta detalhes (como tratar a execução da aplicação — manual via script; quais serviços de apoio subir — PostgreSQL + pgAdmin).
2. **Restringir o escopo do plano**: "Crie apenas os arquivos referentes ao DevContainers. Não altere mais nada." — evita que o agente já comece a alterar o `CLAUDE.md` ou outros arquivos antes da hora.
3. **Aplicar o plano**: gera `devcontainer.json`, `Dockerfile.dev` e `docker-compose.dev` dentro de uma pasta `devcontainers/`.
4. **Criar os scripts** com um prompt que declara **requisitos**, sem entregar o comando pronto — deixando o agente derivar a forma correta lendo a configuração do repositório (ver prompt completo abaixo). Importante: nenhum script pode ser interativo, falhas devem ter mensagem de erro acionável, e a saída deve ser enxuta (sem despejar log de build completo).
5. **Apontar o `CLAUDE.md` para os scripts**: pedir explicitamente para reescrever a seção de comandos de build/teste para usar **apenas** os scripts (`scripts/up`, `scripts/start`, etc.) como interface única de operação do projeto — proibindo explicitamente rodar Python/PyTest/pip direto no host, ou chamar Docker/DevContainers diretamente.
6. **Teste assistido com monitoramento de logs**: pedir ao agente para executar a aplicação e "ficar monitorando os logs" enquanto o instrutor navega manualmente pela interface (cadastrando um evento de teste) — e depois pedir para analisar os logs gerados por aquela ação específica, verificando se tudo funcionou (o agente reportou "cadastro deu certo, evento 12 log, fluxo completo, sem erro").

### Por que essa abstração importa

Dar ao agente um ambiente próprio para construir, testar e validar é essencial para desenvolvimento/entrega ágil com IA. A vantagem central dos scripts como camada de abstração: se a forma de executar a aplicação mudar no futuro (trocar DevContainers por outro mecanismo, por exemplo), só é preciso alterar o **script** — o `CLAUDE.md` continua intacto, apontando para a mesma interface (`scripts/up`, `scripts/start`, etc.). Isso vale independentemente de usar DevContainers ou o método tradicional de execução direta na máquina — a recomendação de criar scripts de operação é geral.

## Comandos e configurações

```
# Plan Mode — criação do DevContainer
Criar um ambiente utilizando DevContainers para o desenvolvimento dessa aplicação
de forma local e isolada. Crie um Dockerfile e um Docker Compose apenas para
desenvolvimento.

# Refinamento de escopo do plano
Crie apenas os arquivos referentes ao devcontainer. Não altere mais nada.
```

```
# prompt para gerar os scripts de operação
Crie cinco scripts em `scripts/` para operar este projeto: `up`, `start`, `down`, `test` e `exec`.

Requisitos:
- Todo comando da aplicação executa dentro do devcontainer deste repositório, nunca no
host. Descubra como fazer isso lendo a configuração que já está no repo.
- `up` sobe o ambiente e é idempotente: rodar com o ambiente já de pé não pode falhar.
- `start` inicia a aplicação no ambiente já em execução.
- `down` derruba o ambiente.
- `test` roda a suíte a partir do diretório em que os imports do projeto resolvem.
- `exec` recebe um comando arbitrário por argumento e executa dentro do ambiente.
- Nenhum script pode fazer pergunta interativa.
- Em caso de falha, a mensagem de erro deve dizer o que fazer para corrigir.
- Saída enxuta: não despejar log de build.
```

```
# apontando o CLAUDE.md para os scripts
Altere o CLAUDE.md para utilizar esses scripts, criando uma abstração sobre a
ferramenta e sobre o ambiente em containers.
```

```
# teste assistido
Execute a aplicação e verifique os outputs. Eu vou navegar pela aplicação e quero
que fique monitorando os logs para avaliar o comportamento.

Analise os logs feitos pelo cadastro de evento que fiz e verifique se deu tudo certo.
```

```bash
# CLI devcontainers (usada manualmente na demo, antes de criar os scripts)
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash -lc "<comando>"
```

## Pegadinhas

- Esquecer de abrir o Docker Desktop antes de rodar `devcontainer up` causa falha silenciosa/confusa — vale sempre verificar que o daemon está ativo.
- Comandos determinísticos complexos (verificação de serviços externos, sequências de setup) não devem morar no `CLAUDE.md` — isso é trabalho de script, não de instrução em linguagem natural.
- O resultado do `CLAUDE.md` alterado para usar os scripts deve proibir explicitamente o caminho antigo (rodar Python/PyTest/pip direto no host, chamar Docker/DevContainers diretamente) — senão o agente pode "esquecer" e voltar ao comportamento anterior.
- Scripts precisam ser não-interativos e ter mensagens de erro acionáveis — sem isso, o agente pode travar esperando input ou falhar sem conseguir se autocorrigir.

## Dúvidas para revisar

- Como esses scripts se comportariam em um pipeline de CI, fora do contexto de um agente de IA — fazem sentido como interface padrão também para humanos?
- Vale adicionar um sexto script (ex.: `logs`) dedicado a streaming de logs, já que a aula usa esse recurso manualmente via `exec`?
- Em um monorepo com múltiplos serviços, cada serviço teria seu próprio conjunto de scripts `up/start/down/test/exec`, ou haveria um orquestrador unificado na raiz?
