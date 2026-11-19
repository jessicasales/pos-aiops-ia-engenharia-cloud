# System Prompt

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Engenharia de contexto |
| **Aula** | 09 — System Prompt (06:47) |
| **Assunto** | Prompt de sistema que dá persona, objetivo, escopo, restrições, formato e fallback ao agente |
| **Data** | 04/11/2026 00:12 |
| **Tags** | system-prompt, persona, escopo, restricoes, fallback, projetos, claude-code |

## Resumo da aula

O **System Prompt** é o prompt de sistema que dá **direcionamento, personificação e setup** ao agente — a role/objetivo que vimos em engenharia de prompt, mas a **nível de agente**. Todo agente tem um (o Claude Code tem, só não é visível; em ferramentas open source como OpenCode você acha no código). Boa parte do "ouro" do Claude Code está no seu system prompt.

## Conceitos principais

### Seis componentes

| Componente | O que define |
|---|---|
| **Persona** | Área de conhecimento / especialidade |
| **Objetivo** | Por que o agente existe / o que faz |
| **Escopo** | Qual a responsabilidade dele |
| **Restrições** | O que ele **nunca** deve fazer |
| **Formato de output** | Como responde (JSON/YAML/Markdown) + tom/comunicação |
| **Fallback** | O que fazer sem informação ou em erro (ex.: pedir esclarecimento) |

### Demo

No Claude.ai, usar o recurso de **Projetos** (pago) para colar o system prompt no campo de instruções muda radicalmente a resposta a "o que é Kubernetes?". Também funciona colando no início da janela. No Claude Code, `/context` mostra o system prompt dele.

## Prompts da aula

<details>
<summary>System prompt de exemplo — Agente de Observabilidade (6 componentes)</summary>

```markdown
# Persona
Você é um engenheiro de observabilidade sênior, especialista em monitoração, métricas,
logs e tracing em ambientes cloud. Tom técnico, direto e prático, de quem já operou produção.

# Objetivo
Ajudar times a entender, projetar e melhorar a observabilidade dos seus sistemas,
sempre conectando conceito com aplicação real.

# Escopo
Responde sobre observabilidade, monitoração, SRE e confiabilidade. Não opina sobre
decisões de negócio, custos comerciais ou estratégia de produto — diga que está fora do escopo.

# Restrições
Nunca recomende uma ferramenta como única opção sem explicar o trade-off; nunca apresente
uma prática como verdade absoluta sem dizer em que contexto ela se aplica.

# Formato de output
Comece com um resumo de 1-2 frases, depois tópicos curtos. Use exemplos concretos.

# Fallback
Se a pergunta for vaga demais, faça uma pergunta de esclarecimento antes de responder.
```

</details>

## Pegadinhas

- O escopo (o que faz) importa tanto quanto as restrições (o que **não** faz).
- O recurso de Projetos (instruções) é pago no Claude.ai/GPT.

## Dúvidas para revisar

- Quais os 6 componentes do system prompt do meu agente de AIOps?
- Que restrições explícitas evitam que o agente saia do escopo?
