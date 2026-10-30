# Hooks e Eventos: Introdução

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Hooks |
| **Aula** | 01 — Hooks e Eventos: Introdução (14:22) |
| **Assunto** | Conceito de hook como interceptador de evento no ciclo de execução do agente, principais eventos (UserPromptSubmit, PreToolUse, PostToolUse, SubagentStart/Stop, Stop) e tipos de handler |
| **Data** | 29/10/2026 22:20 |
| **Tags** | hooks, eventos, handler, pretooluse, posttooluse, stop, userpromptsubmit, llm-as-a-judge, agent-as-a-judge |

## Resumo da aula

Aula de abertura do capítulo "Hooks". Define o conceito central: um **hook** é um interceptador de um **evento** dentro do ciclo de execução do agente de codificação. Diferente de uma skill (que pode ou não ser seguida, dependendo da janela de contexto/modelo), o hook é **determinístico** — sempre executa quando o evento associado ocorre. A aula mapeia os principais eventos disponíveis (variam por ferramenta) e os tipos de handler que podem ser atrelados a cada um (comando/script, chamada HTTP, ferramenta MCP, prompt — LLM-as-a-Judge — ou agente — Agent-as-a-Judge).

## Conceitos principais

### O que é um hook

O ciclo de execução de um agente não é um bloco único — tem diversos marcos/momentos: início de sessão, inserção de prompt pelo usuário, chamada de ferramenta, encerramento da execução. Cada um desses momentos representa um **evento**. Um **hook** intercepta esse evento e dispara um ou mais **handlers** (manipuladores) — uma tarefa/ação determinística associada àquele ponto do fluxo.

### Hook vs. Skill — por que não basta o critério de aceite da skill

Uma skill pode definir critérios de aceite, mas sua execução depende do agente efetivamente segui-la — ele pode ignorar uma regra dependendo da janela de contexto ou do comportamento do modelo. O **hook é execução determinística**: toda vez que o evento ocorre, ele dispara, sem depender da "vontade" do modelo. Hook não substitui as validações de skill — **complementa**, trazendo uma camada de garantia que a skill por si só não oferece.

### Principais eventos (nomes variam por ferramenta — usando Claude Code como referência)

- **Início de sessão**: disparado ao iniciar ou retomar uma sessão. Uso sugerido: carregar ambiente, gerenciamento de configuração/contexto.
- **UserPromptSubmit** (entrada do usuário): disparado quando o usuário envia um prompt, **antes** de ser processado pelo modelo. Uso sugerido: detectar e remover segredos/credenciais inseridos acidentalmente no prompt.
- **PreToolUse**: disparado **antes** da execução de uma ferramenta. Permite permitir, negar ou modificar a chamada — ex.: bloquear um `kubectl delete` ou qualquer comando destrutivo.
- **PostToolUse**: disparado **depois** da execução da ferramenta. Permite verificar se o resultado está correto, manipular/melhorar o output.
- **PostToolUse (falha)**: disparado quando há falha na execução da ferramenta. Permite registrar log, verificar contexto do erro, tentar recuperação.
- **SubagentStart**: disparado na criação de um sub-agente. Permite interceptar/enriquecer/validar o contexto enviado para ele.
- **SubagentStop**: disparado no término da execução de um sub-agente.
- **Stop**: disparado quando o agente termina de gerar uma resposta. Permite rodar validação final — lint, checagem de boas práticas — usando script determinístico.

O instrutor reforça: não é importante memorizar os nomes exatos de cada evento por ferramenta (variam entre Claude Code, Codex, Cursor) — o que importa é entender o conceito de atrelar uma validação/ação a um evento do ciclo.

### Funções comuns de um hook no harness

- Filtrar/enviar dados de observabilidade (ex.: métricas de execução enviadas para uma ferramenta como Langsmith — mencionada como exemplo a ser usado em aula futura).
- Atuar como sensor (linter, execução de teste, validação de esquema).
- Aplicar guardrails (bloquear resposta/input do usuário).
- Implementar mecanismos de aprovação.

### Tipos de handler

1. **Comando/script**: o uso mais comum — execução determinística de um script/ferramenta de linha de comando. Disponível em praticamente todas as ferramentas do mercado.
2. **Chamada HTTP**.
3. **Ferramenta MCP**.
4. **Prompt**: sai da validação puramente determinística — o próprio modelo avalia via inferência, reconectando com o conceito de **LLM-as-a-Judge** (já visto em Prompt Evaluation).
5. **Agente**: usa um sub-agente completo como handler, reconectando com o conceito de **Agent-as-a-Judge** (visto no capítulo anterior).

Importante: handlers de comando/script são suportados por praticamente qualquer ferramenta; handlers de prompt e de agente **não** são suportados por todas as ferramentas ainda — é necessário checar a documentação antes de planejar portabilidade do harness.

### Conexão entre os conceitos do módulo

A aula amarra explicitamente: LLM-as-a-Judge (Prompt Evaluation) → Agent-as-a-Judge (capítulo Sub Agentes) → Hooks com handler de prompt/agente. Todos esses mecanismos convergem para o mesmo objetivo: garantir qualidade na execução do harness através de validações, sejam elas determinísticas (script) ou probabilísticas/interpretativas (prompt/agente).

## Comandos e configurações

Não há comandos ou configurações específicas nesta aula introdutória — a implementação prática dos hooks (scripts de validação para eventos específicos no Claude Code) é tema das próximas aulas do capítulo.

## Pegadinhas

- Hook não substitui skill — ele complementa, trazendo determinismo onde a skill depende da aderência do modelo.
- Nem toda ferramenta de codificação suporta handlers de prompt/agente nos hooks — handler de comando/script é a única garantia de portabilidade entre ferramentas.
- Os nomes e o conjunto exato de eventos disponíveis variam significativamente entre Claude Code, Codex e Cursor — sempre checar a documentação da ferramenta em uso.

## Dúvidas para revisar

- Quais eventos específicos do Claude Code (PreToolUse, PostToolUse, Stop, etc.) serão implementados na prática nas próximas aulas do capítulo?
- Como ficaria um hook de UserPromptSubmit real detectando e removendo uma connection string de banco de dados colada no prompt (tema da próxima aula)?
- Vale a pena, no projeto Encontros Tech, já formalizar um hook de Stop que rode lint/testes automaticamente ao final de cada execução do agente?
