# Agentes built-in

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 02 — Agentes built-in (15:52) |
| **Assunto** | Uso dos sub-agentes nativos do Claude Code (explore, plan, general-purpose) encadeados em pipeline, reimplementando os endpoints de health/ready |
| **Data** | 29/10/2026 18:45 |
| **Tags** | agentes-built-in, explore, plan, general-purpose, janela-de-contexto, claude-code |

## Resumo da aula

Primeira aula prática do capítulo. Antes de ensinar como criar sub-agentes próprios, o instrutor mostra que as próprias ferramentas de codificação (Claude Code, e outras) já vêm com sub-agentes nativos (built-in) — tipicamente de exploração, planejamento e uso geral. A aula demonstra, reimplementando os endpoints de health/readiness (deletados de propósito para a demo), como encadear três agentes built-in do Claude Code — **Explore**, **Plan** e **general-purpose** — em um pipeline, comparando o consumo de janela de contexto do agente principal em cada etapa.

## Conceitos principais

### Agentes built-in fazem parte do Harness da ferramenta

Já visto em Harness Engineering: existe o harness nativo da ferramenta e o harness customizado. Os sub-agentes built-in (de exploração, consulta, pesquisa web, etc.) fazem parte do harness nativo — nem sempre é necessário criar um sub-agente próprio; vale primeiro testar o que a ferramenta já oferece e consultar a documentação (o conjunto varia por ferramenta e muda com frequência). Só quando o sub-agente nativo não atende é que se cria um customizado (tema das próximas aulas).

### Agente Explore — mapeamento sem poluir o contexto principal

Prompt usado para mapear a arquitetura da aplicação Flask (inicialização, registro de rotas, acesso a banco, logging, métricas Prometheus, onde adicionar novos endpoints) delegando ao agente `Explore` do Claude Code. Resultado observado: o agente principal despachou a tarefa, o sub-agente fez toda a varredura de arquivos (processo que normalmente lotaria a janela de contexto), e devolveu apenas um relatório com os caminhos de arquivo relevantes e a relação entre eles. A janela de contexto do agente principal ficou em torno de **10%** de uso — muito menor do que se a exploração fosse feita diretamente na sessão principal.

### Agente Plan — planejamento sem repetir a exploração

Com a janela de contexto limpa de propósito (para não carregar o relatório anterior), o instrutor usa o agente `Plan`, passando a especificação de comportamento desejada para os endpoints `/health` (confirma que o processo responde) e `/ready` (verifica conexão com banco; 200 se disponível, 503 se indisponível; respostas em JSON; implementação deve incluir testes). O agente `Plan` internamente repete a exploração (via seu próprio sub-processo) e devolve um plano de ação completo — arquivos a criar/alterar, responsabilidade de cada endpoint, forma de verificar o banco, testes necessários — consumindo apenas **7%** da janela de contexto principal, mesmo após ~6 minutos de execução em segundo plano.

### Agente general-purpose — implementação sem poluir o contexto

Sem limpar a janela de contexto (propositalmente, para que o agente principal ainda tivesse o plano gerado pelo `Plan` disponível), o instrutor delega a implementação a um agente de uso geral (`general-purpose`), com um prompt que repete a especificação dos endpoints e pede explicitamente para: implementar, executar os testes, manter as novas rotas separadas das rotas de negócio existentes, e retornar um resumo dos arquivos alterados e das validações realizadas. O resultado: o `health_router` foi recriado com os endpoints de health/ready, e a janela de contexto do agente principal ficou em apenas **10%** de uso — independentemente de quanto contexto o sub-agente consumiu internamente (irrelevante, por conta da fronteira/caixa preta já explicada na aula anterior).

### Observação lateral: cuidado com dados pessoais no CLAUDE.md

O instrutor nota, durante a demo, que o agente general-purpose leu automaticamente o `CLAUDE.md` do projeto — incluindo dados pessoais de exemplo inseridos em aulas anteriores (nome, filme que não gosta) — reforçando a recomendação de não deixar esse tipo de informação em arquivos de regras reais.

### Encadeamento observado (pipeline)

1. **Explore** → mapeia a arquitetura (somente leitura).
2. **Plan** → usa o mapeamento (re-explorando internamente) para gerar um plano de implementação e testes.
3. **general-purpose** → usa o plano (mantido na janela de contexto do agente principal) para implementar, testar e reportar.

Cada etapa consumiu uma fração pequena da janela de contexto principal (10%, 7%, 10%), em contraste com o que ocorreria se tudo fosse executado diretamente na sessão principal.

## Comandos e configurações

```text
# Agente Explore — mapeamento da arquitetura
Use o agente Explore para analisar este projeto.

Mapeie:
- Como a aplicação Flask é inicializada.
- Onde as rotas são registradas.
- Como a aplicação acessa o banco de dados.
- Onde o logging é configurado.
- Como as métricas do Prometheus são expostas.
- Onde novos endpoints operacionais poderiam ser adicionados.

Retorne os caminhos dos arquivos e explique como essas partes estão relacionadas.
```

```text
# Agente Plan — planejamento dos endpoints de health/ready
Use o agente Plan para preparar a implementação de endpoints de liveness e readiness nesta aplicação.

Considere o seguinte comportamento:
- GET /health deve confirmar que o processo da aplicação está respondendo.
- GET /ready deve verificar a conexão com o banco de dados.
- Quando o banco estiver disponível, o readiness deve responder com status HTTP 200.
- Quando o banco estiver indisponível, o readiness deve responder com status HTTP 503.
- As respostas devem usar JSON.
- A implementação deve incluir testes.

Retorne:
- Os arquivos que precisam ser criados ou alterados.
- A responsabilidade de cada endpoint.
- A forma de verificar o banco de dados.
- Os testes necessários.
```

```text
# Agente general-purpose — implementação
Use o agente general-purpose para implementar endpoints de liveness e readiness nesta aplicação.

Implemente:
- GET /health para confirmar que o processo da aplicação está respondendo.
- GET /ready para verificar a conexão com o banco de dados.
- Resposta HTTP 200 quando a aplicação estiver pronta.
- Resposta HTTP 503 quando o banco estiver indisponível.
- Respostas em JSON.
- Testes para os cenários de sucesso e falha.

Mantenha as novas rotas separadas das rotas de negócio já existentes.

Implemente a mudança, execute os testes e retorne um resumo dos arquivos alterados e das validações realizadas.
```

## Pegadinhas

- Os nomes e comportamentos dos agentes built-in variam por ferramenta (Claude Code, OpenCode, Codex) e mudam com frequência — sempre checar a documentação da ferramenta em uso em vez de assumir paridade de recursos.
- Limpar (ou não) a janela de contexto entre etapas do pipeline é uma decisão deliberada: no caso do Plan → general-purpose, o instrutor manteve o contexto de propósito para que o plano gerado estivesse disponível ao delegar a implementação.
- Dados sensíveis/pessoais deixados em arquivos como `CLAUDE.md` são lidos automaticamente por qualquer sub-agente que carregue o contexto do projeto — não é um comportamento exclusivo do agente principal.
- O consumo de contexto "interno" de um sub-agente não importa para a sessão principal — só o resultado final atravessa a fronteira.

## Dúvidas para revisar

- Em quais cenários valeria a pena formalizar esse pipeline Explore → Plan → general-purpose como um workflow via SDD/OpenSpec, em vez de disparar manualmente um prompt por etapa?
- Que tipo de sub-agente customizado (ex.: um "agente de codificação" com regras próprias) faria sentido criar para substituir o `general-purpose` nesse fluxo — tema abordado a partir da próxima aula?
- Como o comportamento desses agentes built-in se compara entre Claude Code, Codex e OpenCode na prática?
