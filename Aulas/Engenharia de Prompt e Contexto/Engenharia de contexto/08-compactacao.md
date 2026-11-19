# Compactação e descarte

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 08 — Compactação (10:35) |
| **Assunto** | Reduzir a janela de contexto por sumarização, trim ou slice (com perdas) |
| **Data** | 04/11/2026 00:12 |
| **Tags** | compactacao, sumarizacao, trim, slice, janela-de-contexto, claude-code-compact, degradacao |

## Resumo da aula

Quando a janela chega a ~70-80%, há degradação. O ideal é **limpar e abrir nova sessão**, mas às vezes você precisa manter o contexto. Aí entra a **compactação** — reduzir a janela, com algum nível de **perda**.

## Conceitos principais

### Três técnicas

| Técnica | Como funciona | Risco |
|---|---|---|
| **Sumarização** | O LLM relê tudo e cria um **resumo** curto | Perde detalhes (preferida pelo instrutor, com cautela) |
| **Trim** | Corta pedaços escolhidos da janela | Perde o que foi cortado |
| **Slice** | Remove as mensagens **mais antigas** conforme chegam novas | Perde o início (role, tarefa, contexto inicial) — mais arriscado |

### Demo (Claude Code)

`/context` mostra a ocupação; `/compact` sumariza a janela (ex.: de 32% foi a ~0%). O Claude Code faz isso **automaticamente** ao estourar a janela (pausa, compacta, continua). Por isso, em tarefas longas, combine com **Scratchpad** e **State** (que ficam fora da janela e não se perdem na compactação).

## Comandos e configurações

<details>
<summary>Comandos do Claude Code</summary>

```text
/context    # mostra a ocupação da janela de contexto
/compact    # sumariza a janela (aceita instruções de compactação opcionais)
```

</details>

## Pegadinhas

- Nenhuma técnica é 100% precisa — sempre há perda. Prefira limpar a janela quando puder.
- `slice` costuma apagar o início (role/tarefa) — o instrutor evita.
- Compactação não substitui Scratchpad/State para tarefas longas.

## Dúvidas para revisar

- Quando compactar vs. quando limpar e reiniciar a sessão?
- Como garantir que o plano (Scratchpad) e o progresso (State) sobrevivam à compactação?
