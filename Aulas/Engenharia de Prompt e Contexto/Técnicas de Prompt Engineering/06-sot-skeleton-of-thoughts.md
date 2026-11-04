# Skeleton of Thoughts (SoT)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas de Prompt Engineering |
| **Aula** | 06 — SoT (15:15) |
| **Assunto** | Pedir primeiro o esqueleto de tópicos e depois expandir cada um — para respostas longas/estruturadas |
| **Data** | 03/11/2026 23:50 |
| **Tags** | skeleton-of-thoughts, sot, esqueleto, duas-fases, documentacao, runbook, post-mortem |

> Prompts transcritos da narração da aula; a formatação exata do material pode variar.

## Resumo da aula

Nas técnicas anteriores você entregava os bullet points da cadeia de raciocínio. No **Skeleton of Thoughts** você pede que o **modelo** crie primeiro um **esqueleto** (os tópicos de organização) e **depois expanda** cada seção. São sempre **duas fases**: (1) gerar o esqueleto, (2) detalhar cada ponto.

Você pode deixar o modelo criar o esqueleto do zero, ou dar um esqueleto inicial e pedir para ele quebrar em subtópicos.

## Conceitos principais

### Diferença para o CoT implícito

A diferença é sutil mas importante: aqui você pede **explicitamente** para o modelo **refletir primeiro sobre os tópicos** (o esqueleto) antes de raciocinar. Esse esqueleto entra no contexto e guia a expansão → resultado mais assertivo que um CoT implícito.

### Duas formas de usar

1. **Esqueleto do zero**: o modelo propõe os tópicos (o instrutor prefere esta na maioria dos casos).
2. **Esqueleto dado**: você fornece os tópicos principais e pede para ele quebrar em subtópicos e expandir.

### Quando usar

Documentação técnica, guias, runbook/playbook operacional, análise de incidente e post-mortem, plano de migração e estratégia de implementação — respostas **longas e estruturadas**.

### Quando NÃO usar

Diagnóstico direto, classificação/triagem de alerta, resposta curta de regra geral — casos em que você já tem a cadeia de pensamento pronta (use CoT).

## Prompts da aula

<details>
<summary>Prompts Skeleton of Thoughts (transcritos da aula)</summary>

```markdown
# Prompt 1 — Guia de mudança de carreira (esqueleto do zero)
Crie um guia completo para quem quer mudar de carreira e entrar na área de TI como DevOps / Cloud Engineering.

Primeiro, liste o esqueleto do guia — os principais tópicos que serão cobertos, sem detalhar ainda.
Depois, expanda cada tópico com conteúdo detalhado, exemplos práticos e recursos.
Retorne em Markdown.
```

```markdown
# Prompt 2 — Análise de incidente (esqueleto do zero)
Analise os logs de incidente abaixo e produza uma análise estruturada do ocorrido.

Primeiro, crie o esqueleto da análise, sem detalhar nada ainda.
Depois, expanda cada seção com base nos logs.
Retorne em um documento Markdown.

[use os mesmos logs do payment-service da aula de CoT]
```

```markdown
# Prompt 3 — Post-mortem (esqueleto fornecido)
Com base na análise de incidente gerada acima, crie um documento formal de post-mortem seguindo este esqueleto:
- Título
- Metadados
- Resumo
- (demais seções)

Expanda cada seção sem implementar ainda; depois expanda os tópicos e subtópicos, gerando o documento pronto para compartilhar com a equipe de engenharia.
```

</details>

## Pegadinhas

- O esqueleto **não é 100% determinístico** — rodando várias vezes, os tópicos variam um pouco. O ganho é fazer o modelo raciocinar sobre a estrutura antes de preencher.
- Mesma desvantagem das cadeias de raciocínio: **output grande, mais tokens**.
- Você **não controla** totalmente os tópicos quando deixa o modelo criar o esqueleto — se precisa de controle total, forneça o esqueleto (ou use CoT).

## Dúvidas para revisar

- Para os documentos recorrentes do time (runbook, post-mortem), vale travar o esqueleto ou deixar o modelo propor?
- Em que casos o SoT supera um CoT com tópicos fixos?
