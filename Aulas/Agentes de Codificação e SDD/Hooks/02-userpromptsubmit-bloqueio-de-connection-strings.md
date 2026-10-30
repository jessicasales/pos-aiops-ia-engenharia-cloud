# UserPromptSubmit: Bloqueio de Connection Strings no Prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Hooks |
| **Aula** | 02 — UserPromptSubmit: Bloqueio de Connection Strings no Prompt (15:29) |
| **Assunto** | Implementação prática de um hook `UserPromptSubmit` no Claude Code: script Python que bloqueia connection strings enviadas no prompt, antes de chegar ao modelo |
| **Data** | 29/10/2026 22:30 |
| **Tags** | userpromptsubmit, hook, handler, settings.json, regex, connection-string, exit-code |

## Resumo da aula

Primeira implementação prática do capítulo. O instrutor demonstra, com o mesmo prompt enviado duas vezes (antes e depois de criar o hook), como um hook `UserPromptSubmit` no Claude Code intercepta e bloqueia um prompt contendo uma connection string de banco de dados **antes** que ele chegue ao modelo. A implementação tem duas partes: o **handler** (script Python com regex para detectar padrões de connection string) e o **registro do evento** no `.claude/settings.json`.

## Conceitos principais

### UserPromptSubmit

Evento disparado no Claude Code sempre que o usuário envia um prompt — **antes** de ser interpretado pelo modelo. Permite validar o conteúdo do prompt: detectar prompt injection, credenciais, API keys, connection strings, etc.

### Demonstração do problema (sem hook)

Prompt enviado contendo uma connection string PostgreSQL fictícia (para migração a um RDS) e pedindo um diff de configuração, sem hook nenhum registrado: o agente processa normalmente, recebendo e usando a informação sensível — reforçando que, sem controle, nada impede o envio acidental de credenciais/segredos no prompt.

### O handler — `.claude/hooks/block-connection-strings.py`

Script Python que:
1. Lê o payload JSON do evento via `stdin`.
2. Extrai o campo `prompt`.
3. Compara contra expressões regulares que detectam padrões de connection string: URI (`postgres://`, `mysql://`, `mongodb://`, `redis://`, `mssql://`, `oracle://`, `amqp://`, etc.), JDBC (`jdbc:...`), e os formatos ADO.NET/ODBC e Libpq (baseados em pares `chave=valor` como `server=`, `database=`, `user id=`, `password=`).
4. Se encontrar correspondência, imprime uma mensagem **genérica** no `stderr` (nunca o valor encontrado, para não vazar o próprio segredo no log) e sai com código **2** — o que **interrompe** o fluxo do agente.
5. Se não encontrar nada, sai com código **0** — o fluxo segue normalmente.

Regra-chave sobre o código de saída: `exit 2` interrompe a execução (sinaliza erro); `exit 0` deixa o fluxo continuar. Essa é a convenção central para qualquer handler de hook que precise decidir entre bloquear ou permitir.

### Permissão de execução

Passo obrigatório após criar o script: `chmod +x .claude/hooks/block-connection-strings.py` — sem isso, a ferramenta agêntica não consegue executá-lo.

### Registro do evento — `.claude/settings.json`

A configuração que liga o evento ao handler vai no `settings.json` de **escopo de projeto** (versionado no repositório), não no `settings.local.json` (restrito à máquina local). Justificativa: o comportamento do hook faz parte do harness do projeto e deve ser replicado para toda a equipe — por isso vai versionado. Existe também um escopo de usuário/global, para hooks que devem valer em todos os projetos daquela pessoa.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-connection-strings.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

A variável `$CLAUDE_PROJECT_DIR` resolve o diretório do projeto atual, concatenado com o caminho do script — tornando a configuração portável entre máquinas/clones do repositório.

### Resultado do teste

Reenviando exatamente o mesmo prompt (com hook já registrado): a execução é interrompida **antes mesmo de chegar ao modelo** — "não deu nem tempo de processar" — retornando a mensagem "Connection strings não podem ser enviadas diretamente no prompt. Informe somente o mecanismo seguro que fornecerá a configuração."

### Generalização

O mesmo padrão (regex + exit code 2/0) pode ser aplicado para qualquer tipo de segredo: chaves de API, tokens, chaves da AWS, credenciais de terceiros — e também para detecção de prompt injection tentando extrair informação da plataforma.

## Comandos e configurações

```python
#!/usr/bin/env python3

import json
import re
import sys

CONNECTION_STRING_PATTERNS = (
    re.compile(
        r"\b(?:"
        r"postgres(?:ql)?|mysql|mariadb|"
        r"mongodb(?:\+srv)?|redis|rediss|"
        r"mssql|sqlserver|oracle|cockroachdb|"
        r"cassandra|neo4j|bolt|sqlite|amqp|amqps"
        r")://[^\s'\"<>]+",
        re.IGNORECASE,
    ),
    re.compile(
        r"\bjdbc:[a-z][a-z0-9+.-]*:[^\s'\"<>]+",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?=[^\r\n]*(?:server|data\s+source|host)\s*=)"
        r"(?=[^\r\n]*(?:database|initial\s+catalog|"
        r"user\s+id|uid|password|pwd)\s*=)"
        r"[^\r\n]+",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?=[^\r\n]*\bhost\s*=)"
        r"(?=[^\r\n]*\b(?:dbname|database)\s*=)"
        r"(?=[^\r\n]*\b(?:user|password)\s*=)"
        r"[^\r\n]+",
        re.IGNORECASE,
    ),
)

def reject(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(2)

try:
    payload = json.load(sys.stdin)
    prompt = payload["prompt"]
    if not isinstance(prompt, str):
        raise TypeError
except (json.JSONDecodeError, KeyError, TypeError):
    reject("Não foi possível validar o prompt: payload inválido.")

if any(pattern.search(prompt) for pattern in CONNECTION_STRING_PATTERNS):
    reject(
        "Connection strings não podem ser enviadas diretamente no prompt. "
        "Informe somente o mecanismo seguro que fornecerá a configuração."
    )

raise SystemExit(0)
```

```bash
chmod +x .claude/hooks/block-connection-strings.py
```

```text
# prompt de teste (usado nas duas execuções, com e sem hook)
Estamos migrando o banco PostgreSQL do encontros-tech, que hoje roda dentro do cluster, para um RDS.

A nova connection string é:

postgresql://app_runtime:fixture-only@encontros-tech-demo.cluster-example.us-east-1.rds.amazonaws.com:5432/encontros_tech

Sem alterar arquivos, consulte a estrutura atual do projeto e apresente o diff que seria necessário para:

- atualizar a configuração consumida pela aplicação;
- preservar DATABASE_URL como contrato;
- remover o PostgreSQL executado dentro do cluster;
- manter a connection string em um Secret;
- validar a conectividade e o endpoint /ready;
- definir uma estratégia de rollback.
```

## Pegadinhas

- Esquecer o `chmod +x` no script do handler faz o hook falhar silenciosamente na hora de executar.
- Registrar o hook em `settings.local.json` em vez de `settings.json` faz a proteção valer só na máquina local — não é replicada para o resto da equipe, já que esse arquivo não é versionado.
- O código de saída é a convenção central do handler: `2` interrompe o fluxo (bloqueio), `0` permite continuar — inverter isso silenciosamente quebra toda a lógica de proteção.
- O handler nunca deve imprimir o valor sensível encontrado (mesmo em caso de bloqueio) — a mensagem de rejeição deve ser genérica, para não vazar o próprio segredo no log de erro.

## Dúvidas para revisar

- Vale estender esse mesmo handler para detectar outros tipos de segredo (chaves AWS, tokens de API) no mesmo script, ou é melhor um handler dedicado por tipo de segredo?
- Como esse hook se comportaria em outras ferramentas (Codex, Cursor) — a sintaxe de registro muda, mas o conceito de interceptar o prompt antes do modelo está disponível em todas?
- Faz sentido adicionar um hook global (escopo de usuário) com essa mesma proteção, para cobrir todos os projetos da pessoa, além do hook de projeto já versionado?
