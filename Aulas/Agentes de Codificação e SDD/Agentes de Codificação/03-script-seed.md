# Script Seed — população de dados com Codex

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Agentes de Codificação |
| **Aula** | 03 — Script Seed (13:10) |
| **Assunto** | Script Python idempotente de seed via API, criado com Codex |
| **Data** | 29/10/2026 19:19 |
| **Tags** | `codex` `seed` `idempotência` `api` `http` `python` `testes` |

## Resumo da aula

Segunda etapa: criar um script de **população de dados (seed)** que hoje é feito manualmente via arquivo `.http` (extensão de IDE). Objetivo: automatizar com um comando simples, **via chamadas HTTP à API** (nunca acesso direto ao banco), usando o **Codex** desta vez, para mostrar que o mesmo fluxo funciona em ferramentas diferentes no mesmo projeto.

## Conceitos principais

### Requisitos do script (no prompt)
- URL base parametrizável via `--base-url` (default `http://localhost:8000`).
- **Idempotente**: rodar duas vezes não duplica eventos — checa um campo único (ex. título) via API antes de criar.
- Tratamento de erro de conexão com mensagem clara.
- Relatório final: quantos eventos criados × quantos já existiam.
- Analisar o arquivo `api-requests.http` como **contrato das chamadas** antes de escrever o script.

### Observações sobre o Codex nesta tarefa
- As chamadas de ferramenta são **diferentes do Claude Code** (ex. ausência de `rg`, caiu para `find`) — cada ferramenta tem seu próprio conjunto de tools.
- Depois de criar, o Codex rodou a suíte de testes existente por conta própria para garantir que não quebrou nada, e ainda sugeriu e aplicou uma pequena melhoria.
- Resultado da execução real: **10 eventos criados, 0 já existentes** na primeira rodada; rodando de novo após resetar o banco, idempotência confirmada.

## Prompts da aula

```text
# Criar o script de seed
Crie um script Python em scripts/seed.py que popula a aplicação com eventos
de exemplo FAZENDO CHAMADAS HTTP à API — não acesse o banco diretamente.
Antes de escrever o script, analise os endpoints do serviço de eventos
(rotas, payloads e respostas), usando o arquivo api-requests.http como
contrato das chamadas. Requisitos:
- a URL base da aplicação (host e porta) deve ser parametrizável via
argumento --base-url, com default http://localhost:8000
- idempotente: rodar duas vezes NÃO pode duplicar eventos (consulte os
eventos existentes pela API e verifique por um campo único, ex. título,
antes de criar)
- tratamento de erro de conexão com a API, com mensagem clara
- ao final, imprima quantos eventos foram criados e quantos já existiam
```

```text
# Rodar o script apontando para a URL
A aplicação está em execução em http://localhost:8000. Rode o script de
seed apontando para essa URL e me mostre a saída.
```

## Pegadinhas
- Subir a aplicação ainda foi feito manualmente (`docker-compose up -d --build`) — o agente ainda não sabe fazer isso sozinho porque o harness não está calibrado (tema de capítulos futuros).
- Codex tinha camada gratuita no momento da gravação — pode mudar; usar Claude Code ou outra ferramenta é alternativa válida.

## Dúvidas para revisar
- Adaptar este padrão de script idempotente de seed para outras APIs internas que administro.
