# GenIA - Cotidiano técnico — Fundamentos de IA

Anotações do capítulo **GenIA - Cotidiano técnico** do módulo **Fundamentos de IA** (curso Pós AIOps e IA na Engenharia de Cloud).

Casos práticos de uso da IA generativa no dia a dia de Cloud/DevOps/SRE — de forma simples, como ponto de partida (sem técnicas de prompt ainda).

| # | Aula | Duração | Tema |
|---|---|---|---|
| 01 | [Introdução](01-introducao.md) | 03:30 | Panorama; IA como copiloto |
| 02 | [Análise de Logs e Troubleshooting](02-analise-de-logs-e-troubleshooting.md) | 13:28 | Correlacionar logs, achar causa raiz |
| 03 | [Sugestão de Comandos e Scripts](03-sugestao-de-comandos-e-scripts.md) | 09:05 | Gerar CLI/scripts + validação |
| 04 | [Explicação de Configurações e Arquiteturas](04-explicacao-de-configuracoes-e-arquiteturas.md) | 09:44 | IAM, K8s, menor privilégio |
| 05 | [Documentação Técnica Assistida](05-documentacao-tecnica-assistida.md) | 09:46 | Post-mortem, runbook, README |
| 06 | [Mãos à Obra](06-maos-a-obra.md) | 02:41 | Exercício: caderno de experimentos |

## Resumo rápido

- IA é **copiloto**: sempre **valide** os outputs (risco de alucinação).
- **Troubleshoot**: correlaciona logs e dá causa raiz em segundos — mascare dados sensíveis antes.
- **Scripts/comandos**: seja específico (ferramenta/versão) e teste em ambiente seguro antes de produção.
- **Configs/arquitetura**: analisa e refina (IAM por menor privilégio, manifestos K8s).
- **Documentação**: transforma dados brutos em post-mortem/runbook/README (peça Markdown).
- **Exercício final**: crie um caderno de experimentos versionado (prompt + resposta + nota) como baseline.
