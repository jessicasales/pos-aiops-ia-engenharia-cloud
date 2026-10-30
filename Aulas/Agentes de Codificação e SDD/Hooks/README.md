# Hooks

Anotações do capítulo "Hooks" do módulo **Agentes de Codificação e SDD**, do curso *Pós AIOps e IA na Engenharia de Cloud*.

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Hooks e Eventos: Introdução](01-hooks-e-eventos-introducao.md) | 14:22 | Conceito de hook como interceptador determinístico de evento, principais eventos e tipos de handler |
| 02 | [UserPromptSubmit: Bloqueio de Connection Strings no Prompt](02-userpromptsubmit-bloqueio-de-connection-strings.md) | 15:29 | Hook que bloqueia segredos enviados no prompt, antes do modelo processar |
| 03 | [PreToolUse: Bloqueio de Operações Destrutivas](03-pretooluse-bloqueio-de-operacoes-destrutivas.md) | 13:01 | Hook que restringe `kubectl delete` a um namespace, via Bash e MCP |
| 04 | [PostToolUse: Validação de Kubernetes e Dockerfile](04-posttooluse-validacao-de-kubernetes-e-dockerfile.md) | 13:02 | Hooks que validam manifestos e Dockerfile após edição, com correção automática |
| 05 | [Stop: Definition of Done Executável](05-stop-definition-of-done-executavel.md) | 10:31 | Validação final da infraestrutura ao encerrar a interação, com proteção contra loop |
