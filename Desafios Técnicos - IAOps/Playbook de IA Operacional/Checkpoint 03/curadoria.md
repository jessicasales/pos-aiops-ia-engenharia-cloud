# Checkpoint 03 — Causa-raiz da degradação no Cerebro

## Curadoria

> **Modelo usado:** Claude Sonnet 4.6 (`claude-sonnet-4-6 medium`)

Usei o CoT. Ao começar a fazer o prompt informei o papel da IA: um devops sênior
Depois, passei o Contexto, informei os artefatos escritos e depois informei qual era o objetivo:
- Receber os artefatos como parâmetros pra análise
- Correlacione os dados recebidos
- Chegar a causa raiz

Como retorno, pedi em formato markdown com o nome output.md, na pasta do checkpoint.

Minha ideia era primeiro ter o retorno do prompt enviado e somente depois continuar com CoT falando que queria o prompt parametrizável. Pensei que iria somente fazer o que eu disse. Só que ele foi além, certamente leu no readme do checkpoint e sem me perguntar já foi criando o output.md com o prompt parametrizável junto. Por isso deixei o arquivo output1.md da forma que ele inseriu e depois, quando vi que o prompt que ele criou junto no arquivo do output ainda faltavam parâmetros necessários, passei um novo prompt CoT em cima da conversa já feita informando:

```markdown
Com base na análise da causa raiz acima, gere um prompt parametrizável que:
- Receba artefatos com dados
- Correlacione os dados recebidos
- Informe a causa raiz e o que provocou, não somente os sintomas
- Sugira ações preventivas
```

Após isso ele inseriu o prompt.md com as alterações que pedi.
