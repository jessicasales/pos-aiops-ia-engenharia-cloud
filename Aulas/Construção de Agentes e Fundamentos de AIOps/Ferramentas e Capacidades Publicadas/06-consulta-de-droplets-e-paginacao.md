# Consulta de Droplets e Paginação

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Construção de Agentes e Fundamentos de AIOps |
| **Capítulo** | Ferramentas e Capacidades Publicadas |
| **Aula** | 06 — Consulta de Droplets e Paginação (20:37) |
| **Assunto** | Implementação do PRD 001 (ver [aula 05](05-construcao-de-mcp-server-com-agent-skills.md)) com a skill `build-mcp-server` + OpenSpec — análise, perguntas de esclarecimento, ajuste do plano e `/opsx:apply` |
| **Data** | 30/10/2026 01:15 |
| **Tags** | build-mcp-server, openspec, opsx-apply, pydo, async, fastmcp-tool, teste-end-to-end |

## Resumo da aula

Primeira implementação real do fluxo montado na aula anterior: o PRD 001 (consulta de Droplets por região e estado, detalhado na nota da aula 05) é entregue à skill **`build-mcp-server`** para análise e especificação — não desenvolvimento ainda. A skill identifica lacunas na especificação, faz perguntas de esclarecimento, gera automaticamente a *change* do OpenSpec (design, specs, tasks), recebe ajustes manuais (suporte a STDIO+HTTP, etapa de testes) e só então é aplicada com `/opsx:apply`, que implementa o código, cria credenciais de teste reais na DigitalOcean, roda testes de ponta a ponta e limpa os recursos criados.

## Conceitos principais

### Entrando pela skill de MCP, não pelo fluxo genérico de SDD

Em vez de começar direto pelo `/opsx:propose` do OpenSpec, o fluxo passa primeiro pela skill `build-mcp-server`, que tem conhecimento especializado em construção de MCP Servers (inclusive uma fase explícita de "interrogar o caso de uso"). O prompt usado:

```text
/build-mcp-server @docs/prds/001-consulta-de-droplets.md analise e especifique, não desenvolva nada ainda
```

A instrução explícita "não desenvolva nada ainda" mantém o controle do fluxo em etapas — análise e especificação primeiro, código depois.

### Primeira rodada de perguntas: lacunas que o PRD não resolvia

A skill identificou pontos que o PRD não fechava e perguntou antes de seguir:
- Nome do estado "arquivado": seguir o valor literal da API da DigitalOcean (`archive`), e não uma variação como "archived".
- Droplets de GPU: decisão de não considerá-los nesta feature (poderia ser incluído, mas o escopo ficou mais estreito).
- Cliente HTTP para chamar a API da DigitalOcean: a skill recomendava `httpx` (chamada HTTP genérica), mas a decisão foi usar o **PyDO** (SDK oficial da DigitalOcean) — consistente com a escolha já feita no projeto LangChain de Droplets (aula 02 deste capítulo). Regra prática aplicada: se existe um SDK oficial, usar o SDK oficial em vez de uma chamada HTTP genérica.

Depois dessas respostas, a skill registrou as decisões e **seguiu automaticamente** para o `propose` do OpenSpec, sem precisar de um comando separado — porque o front matter da skill já indica que ela pode encadear diretamente com o proposal quando tem informação suficiente. O instrutor comenta esse comportamento como exemplo de como as skills "se complementam" conforme o harness é montado: menos atrito, menos idas e vindas com o humano.

### Segunda rodada de perguntas: lacunas técnicas do FastMCP

Já na criação da *change* (design/specs/tasks), a skill levantou dois pontos que não conseguiu confirmar só pela documentação:
1. **Síncrono vs. assíncrono**: o PyDO é síncrono e bloqueia esperando resposta da API — rodar a tool assim dentro do event loop do FastMCP travaria outras operações. A decisão foi usar `async def` (tool assíncrona).
2. **Conteúdo da mensagem de erro de estado inválido**: o critério de aceite AC06 do PRD exige que o erro informe os valores válidos — a skill perguntou se deveria listar os quatro valores (`new`, `active`, `off`, `archive`) explicitamente na mensagem. Decisão: sim, listar.

### Ajustes manuais antes do `apply`

Revisando o design/specs/tasks gerados, duas lacunas foram identificadas e corrigidas manualmente, com um prompt direto:

```text
O MCP deve funcionar tanto utilizando STDIO quanto HTTP, verifique se tem o suporte. Nas tasks
deve ter a etapa de teste do MCP. Solicite no início a chave de API para efetuar os testes e
garanta que tudo que foi criado na DigitalOcean para teste seja excluído na conclusão.
```

O agente atualizou spec, design e tasks com quatro novos requisitos: suporte simultâneo a STDIO e HTTP (com comportamento idêntico nos dois transportes), teste do MCP em **três camadas**, pedido do token de API no início do processo, e exclusão garantida de qualquer recurso criado para teste ao final.

### `/opsx:apply` — implementação, com pedido explícito do token por arquivo

```text
/opsx:apply
```

Ponto de segurança relevante: ao chegar na tarefa que precisa de credenciais reais da DigitalOcean para rodar os testes de integração, o agente **parou** e pediu que as credenciais fossem colocadas em um arquivo `.env` na raiz do projeto, em vez de coladas diretamente no chat — evitando que o token fique registrado no histórico da conversa. Duas variáveis foram solicitadas: o token da DigitalOcean e uma segunda chave usada pelo transporte HTTP. O token usado na demo teve **acesso total** (não só leitura), porque os testes de integração precisam criar e apagar Droplets reais.

Esse padrão de segurança — pedir segredo via arquivo, nunca via chat — é reforçado como prática recomendada mesmo em contexto de demonstração/aula; o instrutor comenta que, idealmente, se usaria uma conta de teste/desenvolvimento separada da conta de produção, para não haver risco de impacto.

### Resultado da implementação

Depois do `.env` preenchido, o agente:
1. Codificou a implementação completa (tool de listagem de Droplets com filtros, usando PyDO de forma assíncrona).
2. Executou os testes end-to-end em segundo plano, avisando quando terminassem (sem precisar de monitoramento manual contínuo).
3. Limpou os recursos criados na conta DigitalOcean ao final — confirmado visualmente no painel (apenas o Droplet de uso pessoal do instrutor permaneceu, nenhum resíduo de teste).

### Estrutura de código gerada

Ao final, o código ficou organizado em `src/`:
- `server.py` — inicialização padrão do MCP server (igual ao boilerplate).
- `tools/droplets.py` (ou equivalente) — contém a tool real `listar_droplets`, usando **Pydantic** para o esquema de entrada/saída (reforçando, como na aula 02, que Pydantic é a escolha recorrente para contratos de dados estruturados), uma função auxiliar de filtragem (`filtrar_droplets`), e a função que efetivamente chama a API da DigitalOcean via PyDO (`make_client` ou equivalente), registrada no MCP via `@mcp.tool` dentro da função `register()`.
- Testes correspondentes, cobrindo os cenários definidos no PRD.

### Ciclo de desenvolvimento como padrão a ser repetido

O instrutor fecha a aula sem entrar em mais detalhe de código (deixando a exploração para o aluno), e deixa claro que esse mesmo ciclo — PRD → skill `build-mcp-server` (análise e especificação) → ajustes manuais → `/opsx:apply` (implementação + testes + limpeza) — vai se repetir para o PRD 002 (controle de energia, próxima aula) e PRD 003 (Kubernetes/bancos de dados).

## Comandos e configurações

```text
# Análise e especificação (sem desenvolver ainda)
/build-mcp-server @docs/prds/001-consulta-de-droplets.md analise e especifique, não desenvolva nada ainda
```

```text
# Respostas à primeira rodada de perguntas da skill
Estado archived ou archive: seguir o valor da API da DigitalOcean.
Droplets de GPU: não considerar nesta feature.
Cliente da API: usar o PyDO, SDK oficial da DigitalOcean (a skill recomendava httpx).
```

```text
# Respostas à segunda rodada de perguntas (durante o propose do OpenSpec)
Usar async.
Listar.   # (listar os 4 valores aceitos na mensagem de erro de estado inválido)
```

```text
# Ajuste manual antes do apply
O MCP deve funcionar tanto utilizando STDIO quanto HTTP, verifique se tem o suporte. Nas tasks
deve ter a etapa de teste do MCP. Solicite no início a chave de API para efetuar os testes e
garanta que tudo que foi criado na DigitalOcean para teste seja excluído na conclusão.
```

```text
# Aplicação da change
/opsx:apply
```

```bash
# .env criado pelo próprio usuário, nunca colado no chat
DIGITALOCEAN_TOKEN=seu-token-de-teste-com-acesso-total
# (segunda variável para transporte HTTP, nome definido pelo agente no projeto)
```

## Pegadinhas

- Mesmo com um PRD detalhado, a skill de construção de MCP encontrou lacunas reais de especificação (nome exato de um enum, inclusão ou não de GPU, SDK vs. chamada HTTP genérica) — um PRD bem escrito não elimina a necessidade de uma rodada de esclarecimento técnico antes de codificar.
- O PyDO (como outros SDKs de cloud) é **síncrono** por padrão — usá-lo dentro de uma tool que roda no event loop assíncrono do FastMCP sem cuidado pode travar o servidor; a solução adotada foi declarar a tool como `async def`.
- Pedir credenciais de teste via arquivo `.env`, nunca coladas diretamente na conversa com o agente, é uma prática de segurança que vale manter mesmo em ambiente de demonstração/aula — evita que o segredo fique persistido no histórico de chat.
- Testes de integração que criam e destroem recursos reais exigem um token com permissão de escrita (acesso total, nesse caso) — diferente do token usado pela própria tool em produção, que deveria ter escopo restrito a leitura (prática já reforçada na aula 02 deste capítulo).
- Quando a skill já tem informação suficiente para avançar (ex.: da análise para o proposal do OpenSpec), ela pode encadear automaticamente sem esperar um novo comando — é importante revisar o resultado de cada etapa mesmo quando ela avança "sozinha".

## Dúvidas para revisar

- Como ficaria o teste de paginação (AC02 do PRD 001) na prática — reduzindo artificialmente o tamanho de página numa chamada de teste contra a API real, como sugerido no PRD?
- Vale a pena, num projeto real (não didático), usar sempre uma conta DigitalOcean de teste/sandbox separada da conta de produção para rodar esse tipo de teste de integração com token de acesso total?
- Como ficaria a implementação da tool se o PyDO não tivesse suporte nativo — valeria migrar para `httpx` assíncrono diretamente, como a skill havia sugerido inicialmente?
