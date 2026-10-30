# Framework R-T-F (Role, Task, Format)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Fundamentos |
| **Aula** | 03 — Framework R-T-F (Role, Task, Format) (13:05) |
| **Assunto** | Framework mais simples (Role, Task, Format) para tarefas diretas de uso comum sem necessidade de contexto |
| **Data** | 29/10/2026 22:35 |
| **Tags** | rtf, role, task, format, framework, dockerfile, backup, documentacao |

## Resumo da aula

Primeiro framework da série. O **R-T-F (Role, Task, Format)** é o mais simples — três componentes, sem contexto. É basicamente a estrutura base de 4 componentes **sem o contexto**. Serve para tarefas diretas de "uso comum", cujo conhecimento o modelo já tem amplamente treinado (gerar Dockerfile, script de backup PostgreSQL, documentação de API Gateway, policies IAM). Demonstrado com um e-mail profissional e exemplos técnicos.

## Conceitos principais

### Os 3 componentes

| Componente | Função |
|---|---|
| **Role** | Quem o modelo é / área de atuação |
| **Task** | O que deve ser feito (tarefa específica) |
| **Format** | Como entregar a resposta |

### Quando usar

- Tarefa direta e output previsível.
- Conhecimento de **uso comum**, padrão aberto, amplamente alimentado no modelo (Dockerfile Node.js, policies IAM, backup PostgreSQL, documentação de serviço AWS público).
- Sem necessidade de informação específica do negócio.

### Quando NÃO usar

- Quando precisa de **contexto do negócio**, etapas ou raciocínio.
- Migração on-premises → cloud (tem dependências, fases, características da aplicação).
- Comparação entre ferramentas/projetos (precisa de raciocínio e contexto extra).
- Análise de logs (precisa de etapas de raciocínio).

## Prompts da aula

<details>
<summary>Prompts R-T-F</summary>

```markdown
# E-mail profissional com R-T-F
# Role
Você é um gerente de projetos experiente que sabe comunicar decisões de forma objetiva e persuasiva.
# Task
Escreva um e-mail para o diretor de TI solicitando aumento de 30% no orçamento do projeto de migração cloud, justificando com base em escopo ampliado e riscos de atraso.
# Format
E-mail profissional com: linha de assunto, saudação, 3 parágrafos (contexto, justificativa com dados, próximos passos) e encerramento. Máximo 200 palavras.
```

```markdown
# Script de backup PostgreSQL com R-T-F
# Role
Você é um DBA senior especializado em PostgreSQL e automação de rotinas operacionais.
# Task
Crie um script Bash de backup automático para um banco PostgreSQL, incluindo compactação com gzip, rotação de backups antigos (manter últimos 7 dias) e log de execução.
# Format
Script Bash comentado, com cabeçalho explicando uso e variáveis configuráveis no topo do arquivo.
```

```markdown
# Documentação técnica com R-T-F
# Role
Você é um technical writer especializado em documentação de infraestrutura cloud.
# Task
Crie a documentação de um serviço de API Gateway na AWS, cobrindo: visão geral, arquitetura, endpoints, autenticação e troubleshooting básico.
# Format
Documento Markdown com as seções: Visão Geral, Arquitetura (com descrição textual), Endpoints (tabela com Método | Path | Descrição), Autenticação, Troubleshooting (lista numerada de problemas comuns e soluções).
```

</details>

## Pegadinhas

- R-T-F **não** serve só para "dados gerais" — serve para qualquer tarefa técnica de uso comum. Mas, assim que houver particularidade da empresa, troque de framework.
- O Gemini gera imagens/diagramas na documentação; Claude provavelmente não (comportamento varia por modelo).

## Dúvidas para revisar

- Qual framework usar quando a tarefa de documentação envolve particularidades da empresa (não é de uso comum)?
- R-T-F sem contexto é suficiente para gerar código de infraestrutura real em produção, ou é melhor subir para C-A-R-E/R-I-S-E?
