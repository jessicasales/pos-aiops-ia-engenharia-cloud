# Refinamento de prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Criação e versionamento |
| **Aula** | 04 — Refinamento de prompt (09:00) |
| **Assunto** | Usar a IA para aprimorar um prompt existente com critérios (custo de tokens, nova feature) |
| **Data** | 04/11/2026 00:05 |
| **Tags** | refinamento, meta-prompt, custo-tokens, criterios-de-melhoria, dockerfile |

## Resumo da aula

O primeiro prompt nunca é o melhor. Aqui você usa a IA para **refinar um prompt existente** com critérios específicos. No exemplo, o prompt de auditoria de Dockerfile é refinado para: **reduzir o consumo de tokens** (input/output) e **passar a retornar um Dockerfile corrigido** (antes só listava problemas, "um flanelinha de boas práticas").

## Conceitos principais

- O refinamento também é um **meta-prompt**: uma persona de "engenheiro de prompt" recebe o prompt + instruções de melhoria e devolve a versão refinada.
- Critérios precisam ser **detalhados e assertivos** (ex.: "reduzir de ~2.000 tokens de input"; "retornar Dockerfile seguindo boas práticas").
- Resultado da demo: input caiu quase à metade e o output caiu >50%, mantendo o valor — além de agora sugerir o Dockerfile corrigido.

## Prompts da aula

<details>
<summary>Meta-Prompt refinador</summary>

```markdown
Você deve atuar como um engenheiro de prompt responsável por aprimorar
prompts já construídos.

Receba o prompt, faça uma análise do conteúdo desse prompt e analise
o que o usuário quer que seja alterado.

Depois dessa reflexão, eu quero que você retorne um prompt atendendo
às expectativas do usuário em um formato de arquivo Markdown.

Prompt:
[prompt original a ser refinado]

Melhorias:
- Eu quero que o consumo de tokens seja reduzido. Hoje consome
  aproximadamente 2 mil tokens de input e 8 mil tokens de output.
- Além da análise, deve retornar um Dockerfile seguindo as boas práticas.

Output:
Retorne apenas o prompt alterado em um arquivo Markdown.
```

</details>

## Pegadinhas

- Use o **melhor modelo** (Opus) para refinar — a demo mostra o Haiku gerando um resultado inferior, descartado.
- Ao mudar só o prompt (mantendo o mesmo input na ferramenta), você compara custo/qualidade de forma justa.

## Dúvidas para revisar

- Quais critérios de melhoria padrão eu aplico (custo, formato de saída, nova feature)?
- Como medir se o refinamento manteve o valor da resposta? (ver capítulo Avaliação de prompts)
