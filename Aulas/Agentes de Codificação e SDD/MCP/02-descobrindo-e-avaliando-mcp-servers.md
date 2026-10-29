# Descobrindo e Avaliando MCP Servers

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | MCP |
| **Aula** | 02 — Descobrindo e Avaliando MCP Servers (15:31) |
| **Assunto** | Onde buscar MCP servers e os critérios de segurança/permissão antes de usar um |
| **Data** | 29/10/2026 19:24 |
| **Tags** | `mcp` `curadoria` `segurança` `privilégio-mínimo` `supply-chain` `tool-poisoning` `registries` |

## Resumo da aula

Antes de instalar qualquer MCP: **não é "instalar e ver no que dá"** — exige curadoria e critérios de decisão.

## Conceitos principais

### Desafios/regras de uso
1. **Não reinvente a roda** — com 10 mil+ MCPs disponíveis, raramente faz sentido criar um do zero (só em casos de plataforma específica da empresa ou modelo de credencial não coberto por nenhum MCP existente).
2. **Segurança como em imagem Docker de terceiros** — MCP server é um processo executado; verifique origem, vulnerabilidades, código malicioso.
3. **Faça seu próprio build/release** a partir do código-fonte do projeto, em vez de pegar um pacote pronto de terceiro, quando possível.
4. **Não acumule MCPs** — a descoberta dinâmica ocupa a janela de contexto; contexto não utilizado "vira lixo e atrapalha mais do que ajuda".

### Onde buscar (registries e catálogos)
| Fonte | URL | Observação |
|---|---|---|
| MCP Registry oficial | https://registry.modelcontextprotocol.io | Busca por nome (ex. Kubernetes, Prometheus, GitHub) |
| mcp.so | https://mcp.so | Interface mais polida; lista também **clients** compatíveis (Cursor, Zed, Postman, VS Code...) |
| PulseMCP | https://www.pulsemcp.com | Outra opção de busca, com instruções de configuração |
| awesome-mcp-servers | https://github.com/punkpeye/awesome-mcp-servers | Lista curada por categoria (marketing, finanças...) |
| Docker MCP Catalog | https://hub.docker.com/mcp | Lista **menor**, mas com **curadoria da Docker** — mais segurança, menos opções |

Dica do professor: **comece sempre por opções oficiais** e, na comunidade, prefira projetos de **código aberto** que você consiga inspecionar.

### Critérios de avaliação antes de usar um MCP
1. **Não duplicar o que a ferramenta já tem nativo.** Ex.: não faz sentido um MCP de file system no Claude Code, que já lê/escreve arquivos nativamente — só vale se for um cenário onde o nativo não alcança (cluster Kubernetes, banco de dados, API externa, plataforma própria).
2. **Procedência e manutenção** — quem mantém, se é projeto vivo (data do último commit), o que ele expõe de dado.
3. **Impacto do uso no ambiente** — "pode fazer estrago"? "Botar a culpa na IA é sempre o caminho mais fácil" — a responsabilidade de gestão de acesso é de quem configura.
4. **Permissão / privilégio mínimo** — o agente/MCP é **um usuário do seu sistema** como qualquer outro. Nunca dar o mesmo acesso de um admin. Ex.: se o MCP é para consultar banco, não dê permissão de `delete` nem de criação de recurso.
5. **Confiança e supply chain** — usar publishers oficiais, imagem assinada, checar vulnerabilidades — para evitar **Tool Poisoning** (código malicioso executado via MCP).
6. **Janela de contexto** — definir escopo **global** (vários projetos) × **escopo de projeto** (só onde é necessário), para não poluir o contexto à toa (aprofundado em aula futura — "Escopo de Configuração de Credenciais").

## Pegadinhas
- "A IA deletou meu banco" geralmente é falha de **permissionamento**, não da IA em si.
- Catálogo oficial do GitHub existe — não crie um MCP próprio para GitHub.

## Dúvidas para revisar
- Levantar, antes de plugar qualquer MCP em produção, qual o nível mínimo de permissão que ele realmente precisa.
