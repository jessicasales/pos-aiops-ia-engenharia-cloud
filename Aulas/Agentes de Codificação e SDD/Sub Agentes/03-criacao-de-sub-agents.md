# Criação de sub-agents

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 03 — Criação de sub-agents (26:12) |
| **Assunto** | Critério agente vs. skill, estrutura de um sub-agent (Markdown com front matter + System Prompt), e criação via meta prompt dos agentes `devops-engineer` e `software-developer` |
| **Data** | 29/10/2026 19:00 |
| **Tags** | sub-agents, meta-prompt, system-prompt, front-matter, agente-vs-skill, devops-engineer, software-developer, guardrails |

## Resumo da aula

Aula central do capítulo: ensina quando criar um **agente** em vez de uma **skill**, qual a estrutura de um sub-agent no Claude Code (um simples arquivo Markdown com front matter + System Prompt), e demonstra a criação de dois sub-agents customizados — `devops-engineer` e `software-developer` — usando meta prompts (a IA cria o arquivo de definição do agente, seguindo instruções detalhadas do instrutor).

## Conceitos principais

### Critério para decidir: Agente vs. Skill

Antes do conceito de skill existir, era comum criar um agente por tecnologia (um para Kubernetes, um para Prometheus, um para Terraform, um para Python), colocando todo o procedimento dentro dele. Não estava errado, mas a skill trouxe uma divisão melhor:

- **Agente**: assume um **escopo de responsabilidade** dentro do fluxo (ex.: um agente de DevOps assume tarefas de infraestrutura/operação/observabilidade; um agente desenvolvedor assume tarefas de código/implementação/teste).
- **Skill**: fornece o **conhecimento e procedimento específico** (ex.: skill de troubleshoot Kubernetes, skill de guidelines Python) que o agente consome quando precisa.

Regra prática: **se muda quem assume o escopo do trabalho → agente. Se muda como um fluxo de execução é feito → skill.**

O agente ainda tem comportamento, mas em um nível mais amplo — definido pelo seu **System Prompt**: quem ele é, qual o objetivo, a responsabilidade, os limites, e como devolver o resultado. O que **não** deve entrar no System Prompt: o procedimento técnico detalhado (isso é papel da skill).

Três camadas distintas:
1. **System Prompt do agente** → define o papel.
2. **Skill** → fornece o procedimento quando necessário.
3. **Prompt de delegação** → entrega a tarefa específica daquele momento.

### Estrutura de um sub-agent no Claude Code

Um sub-agent é simplesmente um **arquivo Markdown** salvo em `.claude/agents/<nome-do-agente>.md` (a estrutura de pastas/formato varia por ferramenta — Codex usa `.agents`, Cursor e OpenCode têm as próprias convenções; o conceito é o mesmo, mas é preciso checar a documentação de cada ferramenta). O arquivo tem:

- **Front matter** (como nas skills): `name` (identidade do agente) e `description` (quando o agente principal deve delegar uma tarefa para ele — funciona como "gatilho" indireto, análogo ao que a description faz nas skills).
- **Corpo do arquivo**: o **System Prompt**, definindo papel, objetivo, responsabilidades, limites de atuação, como agir quando faltam informações, e o que retornar ao agente principal.

Nota histórica: o comando `/agents` do Claude Code, que ajudava a criar agentes, foi **removido** — hoje a criação é feita via prompt direto (meta prompt).

### Meta prompt para criar o agente DevOps Engineer

O instrutor usa um prompt detalhado pedindo para a IA criar e salvar o arquivo `devops-engineer.md`, especificando: analisar a estrutura do projeto antes de escrever; o arquivo deve ter `name`, `description` e um System Prompt curto; o agente deve assumir tarefas de infraestrutura/operação/entrega/observabilidade; **não transformar tecnologias específicas (Kubernetes, Prometheus, Terraform) na identidade do agente** — esses conhecimentos vêm de skills quando necessário; não incluir tutoriais/workflows no System Prompt; não configurar modelo/ferramentas/permissões ainda (tema de aula futura); não criar/alterar outros arquivos; e apresentar um resumo das decisões ao final.

### Resultado: `.claude/agents/devops-engineer.md`

```yaml
---
name: devops-engineer
description: >
  Engenheiro DevOps do Encontros Tech. Delegue a ele tarefas de infraestrutura,
  empacotamento, ambiente de execução, entrega, operação, observabilidade da
  aplicação. Criar ou revisar artefatos de build, deploy, ajustar ambiente de
  desenvolvimento e os scripts de operação.
---
```

System Prompt gerado (resumo): "Você é o engenheiro DevOps do Encontros Tech. Objetivo: manter a aplicação empacotável, executável, entregável e observável em desenvolvimento e produção, sem que a mudança de infraestrutura altere o comportamento do produto." Responsabilidades: empacotamento/imagem da aplicação e ambiente, manifestos e artefatos de deploy, configuração e secrets, scripts, observabilidade sob a ótica operacional, diagnóstico de falhas de ambiente/build/deploy/runtime. Limites (guardrails): não altera regra de negócio, service, modelo, schema, router, template ou teste; todo comando passa por scripts (nunca Python/PyTest/pip no host nem Docker/DevContainer na mão); respeita as políticas do `CLAUDE.md` (ADR aceito é imutável, mudança estrutural passa pelo TRD); não introduz ferramenta/serviço gerenciado sem decisão registrada (propõe ADR, não presume); não executa ação destrutiva/irreversível em ambiente compartilhado (apagar volume, derrubar namespace, aplicar em cluster remoto). Reforço final: "Você é um perfil de atuação, não uma stack" — tecnologias/comandos vêm de skills e documentos do projeto.

### Guardrails são interpretativos, não garantidos

O instrutor observa: colocar limites explícitos no System Prompt (guardrails) não garante 100% de aderência — a IA pode "alucinar" e agir fora do limite mesmo com a instrução presente (fenômeno agravado por Lost in the Middle). Ainda assim, **deve-se sempre colocar esses limites** — existem mecanismos adicionais (limitar ferramentas, recursos, permissões) tratados em aulas futuras que reforçam essa proteção de forma mais confiável.

### Meta prompt para criar o agente Software Developer

Estrutura análoga ao `devops-engineer`, mas focado em código: implementação, manutenção e testes. Mesma regra de não transformar Python/Flask/Pytest na identidade do agente. Resultado: `.claude/agents/software-developer.md`, com objetivo "entregar mudança de código correta, coberta por teste e coerente"; responsabilidades: implementação de funcionalidade nova/evolução, correção de bugs, regra de negócio, fronteira HTTP da aplicação, testes, manutenção; limites: não altera artefato de infraestrutura, não escreve/edita documentos de decisão (ADR/TRD/PRD — o instrutor observa que isso poderia ser ajustado dependendo do fluxo real de trabalho), fica dentro do escopo da tarefa, respeita as políticas do `CLAUDE.md`.

O próprio agente gerado identificou e declarou a complementaridade com o `devops-engineer` (evitando sobreposição de responsabilidades).

### A IA cria, você revisa

Reforço de um princípio recorrente no curso: o resultado gerado pela IA (seja PRD, ADR, `CLAUDE.md` ou, agora, um sub-agent) raramente é a versão final em zero-shot — é esperado revisar e ajustar conforme a necessidade real do projeto/equipe.

## Comandos e configurações

```text
Crie um sub-agent chamado devops-engineer no escopo deste projeto.

Use o formato atual de agentes do Claude Code e salve a definição em:

.claude/agents/devops-engineer.md

Antes de escrever, analise a estrutura deste projeto para entender o contexto da aplicação.

O arquivo deve ter:

- name com a identidade do agente;
- description clara sobre quando o agente principal deve delegar uma tarefa para ele;
- um System Prompt curto e direto no corpo do arquivo.

O System Prompt deve definir:

- o papel do agente;
- o objetivo;
- as responsabilidades;
- os limites de atuação;
- como trabalhar quando faltarem informações;
- o que deve retornar ao agente principal.

Esse agente deve assumir tarefas relacionadas à infraestrutura, operação, entrega e observabilidade da aplicação.

Não transforme Kubernetes, Prometheus, Terraform ou qualquer outra tecnologia específica na identidade do agente. Esses conhecimentos e procedimentos poderão ser fornecidos por skills quando forem necessários.

Não coloque tutoriais nem workflows específicos no System Prompt.

Não configure modelo, ferramentas ou permissões neste momento.

Não crie nem altere outros arquivos.

Depois de criar, apresente um resumo das decisões tomadas na definição do agente.
```

```text
Crie um sub-agent chamado software-developer no escopo deste projeto.

Use o formato atual de agentes do Claude Code e salve a definição em:

.claude/agents/software-developer.md

Antes de escrever, analise a estrutura deste projeto para entender como a aplicação e os testes estão organizados.

O arquivo deve ter:

- name com a identidade do agente;
- description clara sobre quando o agente principal deve delegar uma tarefa para ele;
- um System Prompt curto e direto no corpo do arquivo.

O System Prompt deve definir:

- o papel do agente;
- o objetivo;
- as responsabilidades;
- os limites de atuação;
- como trabalhar quando faltarem informações;
- o que deve retornar ao agente principal.

Esse agente deve assumir tarefas relacionadas ao código da aplicação, implementação, manutenção e testes.

Não transforme Python, Flask, Pytest ou qualquer outra tecnologia específica na identidade do agente. Esses conhecimentos e procedimentos poderão ser fornecidos por skills quando forem necessários.

Não coloque guidelines de linguagem nem workflows específicos no System Prompt.

Não configure modelo, ferramentas ou permissões neste momento.

Não crie nem altere outros arquivos.

Depois de criar, apresente um resumo das decisões tomadas na definição do agente.
```

## Pegadinhas

- O comando `/agents` do Claude Code foi removido — a criação de sub-agents hoje é feita via prompt direto (meta prompt), não por um wizard dedicado.
- Transformar uma tecnologia específica (Kubernetes, Python) na identidade do agente é um erro comum — o agente deve representar um papel/perfil de atuação, não uma stack; o conhecimento técnico vem de skills.
- Guardrails escritos no System Prompt são interpretativos — não garantem 100% de aderência do modelo; servem como proteção mas precisam ser complementados por outros mecanismos (ferramentas/permissões restritas), vistos em aulas futuras.
- O resultado de um meta prompt de criação de agente raramente está "perfeito" no primeiro disparo — revisar e ajustar limites (ex.: permitir que o `software-developer` edite certos documentos, dependendo do fluxo real) é esperado.
- Usar o melhor modelo disponível é recomendado especificamente na fase de criação do harness (agentes, skills, rules) — não é hora de economizar com um modelo mais fraco.

## Dúvidas para revisar

- Vale ajustar o limite do `software-developer` para permitir edição de specs/PRDs em certos fluxos de desenvolvimento, como o instrutor sugeriu como possibilidade?
- Como ficaria um "meta prompt genérico" reutilizável (ou até uma skill geradora de agentes, como o instrutor sugere como desafio) para criar novos sub-agents rapidamente em diferentes projetos?
- Quais outros sub-agents (ex.: segurança, QA, documentação) fariam sentido no projeto Encontros Tech, seguindo o mesmo critério de "escopo de responsabilidade"?
