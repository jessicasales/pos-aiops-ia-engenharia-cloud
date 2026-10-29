# Como Escrever o seu AGENTS.md

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Rules |
| **Aula** | 03 — Como Escrever o seu AGENTS.md (37:13) |
| **Assunto** | Estrutura recomendada de 6 blocos para o `AGENTS.md`/`CLAUDE.md`, regras de tamanho/escrita, progressive disclosure vs. import, e um prompt pronto para gerar o arquivo do zero |
| **Data** | 29/10/2026 17:45 |
| **Tags** | agents.md, claude.md, progressive-disclosure, import, estrutura, convencoes, politicas-e-limites |

## Resumo da aula

Aula prática que aprofunda a criação do `AGENTS.md`/`CLAUDE.md`, indo além do `/init` básico. O instrutor define uma estrutura fixa de 6 blocos, regras de tamanho e estilo de escrita, mostra as duas formas de referenciar documentação externa (import total vs. progressive disclosure), e entrega um prompt completo e reutilizável para gerar o arquivo do zero a partir da leitura real do repositório.

## Conceitos principais

### Por que não confiar só no `/init`

O `/init` (e equivalentes em outras ferramentas) é um bom ponto de partida, mas gera regras **detectadas pela IA**, não necessariamente as que o time realmente quer (ex.: convenção de commits, nomenclatura específica). O ideal é um mix: IA para gerar a base + edição humana para refinar.

### Regra de tamanho

- Teto de **200 linhas** (não é meta — quanto menos, melhor: 100-150 linhas é o ideal).
- Só incluir informações **realmente necessárias**: nada que o modelo já saiba resolver por conta própria, e nada que já esteja coberto por uma skill.

### Estrutura recomendada — 6 blocos

1. **Sobre o projeto**: o que é e qual o objetivo do projeto (dados de negócio). Ex.: "Encontros Tech é uma aplicação web de cadastro, busca e edição de eventos de tecnologia."
2. **Arquitetura e stack**: principais tecnologias (linguagens, frameworks), como o deploy acontece (VPS, Kubernetes, serverless), visão geral da arquitetura (cliente-servidor, 3 camadas, microserviços) e dependências externas (outros serviços, mensageria, banco de dados).
3. **Estrutura do projeto**: mapa de navegação dos principais diretórios — onde fica a aplicação, documentação, manifestos Kubernetes, Dockerfile, etc. **Não é inventário** — não detalhar arquivo a arquivo, apenas os diretórios/pastas relevantes para navegação.
4. **Comandos de build e teste**: como iniciar o projeto, como rodar os testes (unitários, integração, e2e), comandos exatos de inicialização — especialmente crítico quando há Docker/Kubernetes envolvidos. (Aula dedicada a isso vem a seguir no capítulo.)
5. **Convenções de código**: regras específicas do projeto que não cabem em uma skill genérica — padrão de commit, nomenclatura, onde/como criar documentação. Vale incluir exemplos do jeito certo e do jeito errado (mesma lógica de few-shot prompting).
6. **Políticas e limites**: o que não deve ser feito no projeto, exceções conhecidas e como tratá-las (especialmente relevante para o processo de deploy).

### Teste de decisão: "isso deve ir no AGENTS.md?"

Pergunta-chave sugerida pelo instrutor: *isso vale só no escopo deste projeto?* Sinal de que algo deve entrar no arquivo: aconteceu um erro onde a falta dessa informação fez a IA se comportar de forma inesperada (escrever no lugar errado, demorar demais para achar uma informação). Se o próprio código "já ensina" o padrão (a IA detecta convenções navegando pelo projeto), a informação pode ser removida do arquivo ao longo do tempo.

### AGENTS.md/CLAUDE.md é um documento vivo

Conforme o projeto evolui, a IA passa a detectar padrões sozinha, e partes do arquivo podem ser podadas. No início de um projeto novo, é normal que o arquivo seja maior (mais guidelines necessários); com o tempo, tende a enxugar.

### Referenciando documentação externa: import vs. progressive disclosure

Dois jeitos de trazer documentos existentes (TRD, ADRs) para dentro do contexto do agente:

1. **Import direto** (`@docs/trd.md`): o conteúdo é sempre carregado junto com o `CLAUDE.md`. Vantagem: garante que a informação sempre estará disponível. Desvantagem: infla a janela de contexto rapidamente se muitos documentos forem importados dessa forma (TRD + ADRs + PRDs + changes do OpenSpec, por exemplo).
2. **Progressive disclosure** (apenas referenciar o caminho, sem `@`): ex. "Leia `docs/trd.md` antes de mudanças estruturais" ou um link Markdown apontando para a pasta de ADRs. O agente só vai ler o documento **sob demanda**, quando a tarefa exigir. Vantagem: economia de contexto. Desvantagem: o carregamento não é garantido — a referência pode ficar na "zona cinzenta" do fenômeno *Lost in the Middle* e nunca ser efetivamente consultada, dependendo do tamanho da janela de contexto e das tarefas já executadas.

### O prompt para gerar o AGENTS.md/CLAUDE.md do zero

O instrutor fornece (como material da aula) um prompt completo que instrui o agente a: ler de fato o projeto (dependências, compose, devcontainer, configuração de testes, estrutura de `src/`) sem assumir nada por convenção; produzir os 6 blocos na ordem definida; respeitar o teto de 200 linhas; referenciar (não copiar) informações já existentes em outros arquivos; evitar título de boas-vindas, badges, emojis e seções de contribuição; usar frases curtas e imperativas; e listar separadamente, fora do arquivo, o que foi considerado mas não pôde ser confirmado pela leitura do repositório.

### Resultado da execução no projeto Encontros Tech

O agente gerou um `CLAUDE.md` de 140 linhas, com os 6 blocos, incluindo detalhes como: estrutura de diretórios bem resumida (muito mais legível que a gerada pelo `/init` anterior); convenções específicas (comentários/logs em português, nomenclatura PascalCase — ponto que o instrutor observa como exagero, já que snake_case é o padrão Python, mostrando que revisão humana continua necessária); políticas reais do projeto (não reabrir ADR aceito, mudança estrutural passa pelo TRD, não introduzir Alembic, não remover o `create_all` no startup, não quebrar os endpoints de Health/Ready); e exceções conhecidas (schema aceito mas desenvolvido em memória — não persiste; não há coluna "módulo"; não há autenticação real — edição autorizada só por posse de um Edit Token; Secret Key do Flask fixo no `main.py` como TODO de registro).

O próprio agente reportou, à parte, o que não pôde confirmar (ex.: não há devcontainer nem CI/CD/Makefile no repositório; não conseguiu executar e verificar o PyTest passando, provavelmente por depender do banco de dados via Docker Compose) — gancho direto para a próxima aula do capítulo, sobre como ensinar o agente a operar/inicializar a aplicação corretamente.

## Comandos e configurações

```markdown
<!-- import direto de documentação externa -->
Os dados técnicos se encontram em @docs/trd.md
```

```markdown
<!-- progressive disclosure (referência sem import) -->
Leia docs/trd.md antes de mudanças estruturais.

Documentos de decisões arquiteturais: [ADRs](docs/adrs/)
```

```text
Reescreva o CloudMD na raiz desse repositório, do zero.

Antes de escrever, leia o projeto: a configuração de dependências, o compose, o
devcontainer, os arquivos de exemplo de ambiente, a configuração de testes e a
estrutura de pastas sob src/. Todo fato do arquivo tem que sair da leitura — não
assuma nada por convenção da linguagem ou do framework.

O arquivo tem seis blocos, nesta ordem:

1. Sobre o projeto — o que é e qual o objetivo dele. Duas ou três linhas.
2. Arquitetura e stack — as tecnologias principais, como o deploy acontece e a
arquitetura em visão alta. Sem diagrama, sem descrever camada por camada.
3. Estrutura do projeto — as pastas principais e onde encontrar cada tipo de
recurso. Mapa de navegação, não inventário: não desça arquivo a arquivo.
4. Comandos de build e teste — como subir o projeto, como rodar os testes e como
executar comandos dentro dele. Comando exato, do jeito que funciona aqui.
5. Convenções de código — as que este repositório de fato segue, incluindo o
padrão de commit. Só o que você conseguir comprovar lendo o código existente.
6. Políticas e limites — o que não deve ser feito neste projeto e as exceções que
precisam de tratamento.

Regras de escrita:

- Máximo de 200 linhas no arquivo inteiro. É teto, não meta.
- Não explique conceito geral de tecnologia. Assuma que quem lê já sabe o que é
container, banco relacional ou teste automatizado.
- Quando a informação já existir em outro arquivo do repositório, aponte o
caminho dele em vez de copiar o conteúdo para dentro do AGENTS.md.
- Sem título de boas-vindas, sem badge, sem emoji, sem seção de contribuição.
- Frase curta e imperativa. Nada de parágrafo explicativo.

Ao terminar, liste separadamente — fora do arquivo — tudo que você considerou
incluir e deixou de fora por não conseguir confirmar no repositório.
```

## Pegadinhas

- Convenções "óbvias" da linguagem (ex.: snake_case em Python) podem ser incluídas indevidamente pela IA como se fossem regra do projeto — sempre revisar o que foi gerado.
- Usar import (`@arquivo`) para muitos documentos (TRD + ADRs + PRDs + changes) pode inflar rapidamente a janela de contexto — reservar import apenas para o que é realmente sempre necessário.
- Progressive disclosure economiza contexto, mas não garante que o documento referenciado será de fato lido quando necessário — há risco de "Lost in the Middle".
- O arquivo gerado automaticamente pode reportar lacunas reais do projeto (ex.: testes de integração que não rodam sem o ambiente Docker Compose ativo) — esse é um sinal real de que falta ensinar o agente a operar a aplicação corretamente (tema da próxima aula).

## Dúvidas para revisar

- Quais convenções específicas do projeto Encontros Tech (fora o que a IA já detectou) ainda precisam ser adicionadas manualmente ao `CLAUDE.md`?
- Em que ponto da evolução do projeto vale revisar e podar o `CLAUDE.md`, removendo guidelines que a IA já "aprendeu" pelo próprio código?
- Como equilibrar import vs. progressive disclosure quando o projeto tiver múltiplos documentos técnicos (TRD, vários ADRs, PRDs, specs do OpenSpec)?
