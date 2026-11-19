# Geração direta de prompts

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Criação e versionamento |
| **Aula** | 03 — Geração direta (24:42) |
| **Assunto** | Gerar um prompt do zero com a IA: Prompt Generator da Anthropic e meta-prompt portável; tags XML e variáveis |
| **Data** | 04/11/2026 00:05 |
| **Tags** | geracao-de-prompt, prompt-generator, anthropic-console, tags-xml, variaveis, meta-prompt-portavel |

## Resumo da aula

Como gerar um prompt completo a partir de uma descrição em linguagem natural — de duas formas: (1) o **Prompt Generator nativo** do Anthropic Console e (2) um **meta-prompt portável** (um "prompt gerador de prompt") que roda em qualquer LLM.

## Conceitos principais

### Especificidade na descrição

"Quero um prompt para analisar Dockerfile" gera algo genérico. Descreva objetivo, contexto, formato de saída e público — aí o prompt gerado é assertivo.

### Dois caminhos

1. **Anthropic Console → Generate a prompt**: ferramenta dedicada; mostra o reasoning e o consumo de tokens (input/output). Gera em inglês por padrão (peça tradução se quiser PT).
2. **Meta-prompt portável**: cole o "Prompt Gerador de Prompt" em Claude.ai, ChatGPT ou Gemini. Recebe a descrição em `## Objetivo do Prompt` e devolve o prompt final, escolhendo seções de um catálogo conforme o tipo de tarefa (adaptativo, não template fixo).

### Tags XML (padrão Anthropic)

Os prompts gerados pela Anthropic usam tags XML (`<dockerfile>`, `<scratchpad>`) para **demarcar blocos** do prompt. É recomendado pela Anthropic, funciona em outras ferramentas, mas é opcional (o instrutor usa em ~20% dos casos, quando há blocos referenciados mais de uma vez).

### Variáveis (reaproveitamento)

Declare variáveis `{{DOCKERFILE}}` para reaproveitar o prompt sem copiar/colar o conteúdo toda vez. Útil para parametrizar Dockerfile, Cloud Provider, serviços — e distribuir o prompt na equipe.

## Prompts da aula

<details>
<summary>Descrição em linguagem natural (input do gerador)</summary>

```markdown
Preciso de um prompt que analise um Dockerfile de aplicação Python,
identificando problemas de segurança e oportunidades de melhoria de
performance. O output deve ser uma lista priorizada das recomendações,
da mais crítica pra menos crítica, com justificativa técnica em cada
item. O público é desenvolvedor backend que vai aplicar as mudanças.
```

</details>

<details>
<summary>Dockerfile de exemplo (para testar o prompt gerado — contém antipatterns de propósito)</summary>

```dockerfile
FROM python
WORKDIR /app
COPY . /app
RUN apt-get update && apt-get install -y curl build-essential
RUN pip install -r requirements.txt
ENV DB_PASSWORD=admin123
ENV API_KEY=sk-production-key-9f2a3b4c5d6e
EXPOSE 5000
CMD python app.py
```

</details>

<details>
<summary>Prompt Gerador de Prompt (meta-prompt portável, PT)</summary>

```markdown
Você é um especialista em engenharia de prompts. Sua tarefa é receber a descrição
de uma tarefa/desejo do usuário e gerar UM PROMPT COMPLETO e pronto para uso, sem
fazer perguntas.

A estrutura do prompt gerado deve ser ADAPTATIVA — escolha apenas as seções que
fazem sentido para a tarefa específica. Não force um template fixo.

## Sua Missão
Pegue a descrição na seção "Objetivo do Prompt" e construa um prompt profissional,
estruturado e autocontido. Preencha inteligentemente as lacunas, inferindo decisões
razoáveis a partir do contexto.

## Processo Mental (interno, não exponha)
1. Classifique a tarefa (criativa, analítica, transformacional, extração, código, agêntica...)
2. Identifique a intenção central
3. Avalie a complexidade (simples / média / complexa)
4. Infira contexto e usuário
5. Decida quais seções do catálogo usar

## Catálogo de Seções (use só as que agregam)
Papel/Persona; Objetivo; Contexto e Premissas; Input Esperado; Processo de Raciocínio (CoT);
Formato de Saída; Regras e Restrições; Critérios de Qualidade; Edge Cases; Exemplos (Few-shot);
Critério de Parada; Tom/Estilo.

## Heurísticas de Adaptação
- Simples → 2-4 seções (Objetivo + Formato + 1-2 regras)
- Criativa → Persona, Tom/Estilo, Exemplos
- Analítica/extração → Input/Output rígidos, Regras, Edge Cases, few-shot
- Transformação → Input/Output, CoT, Critérios de Qualidade
- Agêntica → CoT detalhado, Critério de Parada, fallback
- Conversacional → Persona forte, Tom/Estilo
- Código → linguagem/framework, convenções, Formato exato, Edge Cases

## Regras
1. Mínimo necessário, máximo suficiente
2. Inferência inteligente (sem lacunas vagas)
3. Especificidade vence generalidade
4. Imperativo ativo ("Faça", "Liste", "Identifique")
5. Gere no idioma da descrição (ambíguo → PT-BR)
6. One-shot real: funciona sozinho, sem placeholders
7. Cabeçalhos claros que reflitam o conteúdo
8. Sem meta-comentários

## Formato da Resposta
Entregue APENAS o prompt gerado, dentro de um bloco de código markdown, pronto para
copiar e colar. Sem preâmbulo, sem justificar escolhas.

## Objetivo do Prompt
[colar aqui a descrição da tarefa]
```

</details>

## Pegadinhas

- O Prompt Generator da Anthropic responde em inglês por padrão — usar inglês sai mais barato (menos tokens), mas peça tradução se a equipe trabalha em PT.
- As tags XML podem ser interpretadas como parte do conteúdo em algumas ferramentas; use com intenção.
- Marque `thinking` ativado ao gerar prompts para modelos com reasoning.

## Dúvidas para revisar

- Vale manter uma variável padronizada (`{{CLOUD_PROVIDER}}`, `{{SERVICE}}`) nos meus prompts de infra?
- Meu meta-prompt gerador deve forçar seção de output em Markdown por padrão?
