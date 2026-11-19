# Transformação de prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Criação e versionamento |
| **Aula** | 05 — Transformação de prompt (09:48) |
| **Assunto** | Transformar um prompt em variantes com técnicas diferentes (CoT, ToT) para comparar performance |
| **Data** | 04/11/2026 00:05 |
| **Tags** | transformacao, meta-prompt, chain-of-thoughts, tree-of-thoughts, comparacao-de-tecnicas, tokens |

## Resumo da aula

Terceira etapa do meta-prompt: **transformar** um prompt em novas versões aplicando **técnicas diferentes** (Chain of Thoughts, Tree of Thoughts) para **comparar performance**. A IA recebe o prompt base e gera uma variante por técnica, mantendo contexto e objetivo.

## Conceitos principais

- A persona "especialista em engenharia de prompt" recebe o prompt + a lista de técnicas e gera **um arquivo por técnica**.
- Serve para **comparar na prática** qual técnica entrega melhor (e a que custo de tokens).

### Resultado contraintuitivo da demo

Em teoria, CoT (linear) consome menos output que ToT (árvore de raciocínio). Na demo, o **ToT teve output menor que o CoT** — prova de que **é preciso testar e comparar**, não confiar só na teoria. (Os tokens sobem com qualquer técnica de raciocínio vs. o prompt quase zero-shot original — esperado.)

## Prompts da aula

<details>
<summary>Meta-Prompt transformador</summary>

```markdown
Você é um especialista em engenharia de prompt e o seu papel é receber determinado
prompt inserido pelo usuário e fazer a transformação desse prompt utilizando técnicas
que o usuário vai solicitar. Você deve sempre manter o contexto e o objetivo do prompt,
usando-o como base para criar as variantes com as técnicas definidas, para gerar uma
base de comparação e analisar qual tem melhor performance.

Prompt:
[prompt base]

Técnicas:
- Chain of Thoughts
- Tree of Thoughts

Output:
Crie um arquivo Markdown para cada técnica solicitada.
```

</details>

## Pegadinhas

- Técnicas de raciocínio aumentam tokens de input e output — esperado; refinar ajuda, mas não volta ao patamar do zero-shot.
- A teoria (CoT < ToT em output) nem sempre se confirma — **meça sempre**.

## Dúvidas para revisar

- Quais pares de técnicas vale comparar para os meus prompts críticos?
- Como padronizar essa comparação (mesmo input, mesmo modelo) para decidir a variante campeã?
