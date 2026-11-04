# Memória de Longo Prazo

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 03 — Memória de Longo Prazo (17:34) |
| **Assunto** | Memória consultável entre sessões; o que persistir, escopos e tipos (semântica, episódica, procedural) |
| **Data** | 04/11/2026 00:12 |
| **Tags** | memoria-longo-prazo, persistencia, escopo, semantica, episodica, procedural, preferencias, claude-md |

## Resumo da aula

Analogia de hardware: janela de contexto = **RAM** (rápida, volátil); memória de longo prazo = **disco** (persistente). A memória de longo prazo é **consultável por todas as sessões** (arquivo, banco, serviço externo — o conceito importa mais que a implementação).

## Conceitos principais

### O que persistir

Pergunta-filtro: *"amanhã, em outra tarefa, eu preciso dessa informação?"* Se sim, é **fato durável** → persiste. Exemplos: preferências do usuário (idioma, tom), fatos (linguagem favorita, estilo de arquitetura), configs de ambiente, parâmetros de identidade. Tenha **critério** — não persista a janela inteira.

### Escopo

Como em sistemas: **global**, **por usuário**, **por projeto**. Evite **multi-tenant** na mesma base (risco alto de vazar dados entre clientes; exige segurança rígida).

### Tipos de memória (literatura)

| Tipo | O que é | Exemplo |
|---|---|---|
| **Semântica** | O que o agente sabe (fatos/conhecimento) | "usa Argo CD", "banco PostgreSQL" |
| **Episódica** | Algo que aconteceu e deu certo | estrutura de runbook/post-mortem aprovada, padrão de commit |
| **Procedural** | Como o agente deve agir | como fazer deploy, como rodar testes |

## Prompts da aula

<details>
<summary>Artefatos da demo (chat auxiliar + memória de projeto do Claude Code)</summary>

```text
# Fato gravado na memória de longo prazo (chat auxiliar)
Meu nome é Fabrício Veronês e sou fundador da Pós AIOps
```

```text
# Pergunta de verificação (antes de salvar: não sabe; depois + limpar chat: sabe)
Qual é o meu nome?
```

```text
# Comando ao Claude Code — gravar preferência como fato durável
Quero que você sempre responda as perguntas em inglês, adicione nas preferências
```

```text
# Conteúdo que o Claude Code gravou no diretório de memória do projeto
Always reply in English. Override the Portuguese default.
```

</details>

## Pegadinhas

- Sem critério, você lota a janela futura com dados inúteis.
- Multi-tenant na mesma memória é risco de vazamento — isole por cliente.
- O Claude Code já grava preferências no diretório de memória do projeto automaticamente.

## Dúvidas para revisar

- Quais fatos do meu projeto são semânticos, episódicos e procedurais?
- Qual escopo (usuário/projeto) para cada tipo de memória?
