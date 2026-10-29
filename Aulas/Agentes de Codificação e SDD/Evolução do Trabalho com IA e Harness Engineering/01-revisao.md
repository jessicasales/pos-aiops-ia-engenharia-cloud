# Revisão

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Evolução do Trabalho com IA e Harness Engineering |
| **Aula** | 01 — Revisão (12:53) |
| **Assunto** | Recapitulação da jornada do módulo (prompt → contexto → agentes → SDD) e introdução formal aos conceitos de Harness Engineering e Loop Engineering |
| **Data** | 29/10/2026 16:25 |
| **Tags** | harness, loop-engineering, recapitulação, cursor-case, linkedin-case |

## Resumo da aula

Aula introdutória e mais curta do capítulo, que recapitula o caminho percorrido no curso: engenharia de prompt → engenharia de contexto → agentes de codificação → Spec Driven Development (SDD/OpenSpec). O instrutor expõe o problema remanescente mesmo após o SDD — a necessidade constante de "babá-se" a IA, ensinando critérios de validação repetidamente — e introduz formalmente os dois conceitos que o restante do capítulo vai detalhar: **Harness Engineering** e **Loop Engineering**.

## Conceitos principais

### Recapitulação da jornada

1. **Engenharia de prompt**: instruções para a IA (Chain of Thought, Zero Shot, ReAct).
2. **Engenharia de contexto**: fornecer as informações necessárias para a IA executar a tarefa, não só a instrução.
3. **Agentes de codificação** (Claude Code, Gemini, Cursor): vão além da codificação, executam operações de DevOps/Cloud, operando em um ciclo de execução parecido com o ReAct (análise → ação → observação → repetição).
4. **Spec Driven Development (OpenSpec)**: trouxe um workflow estruturado — usado no projeto Encontros Tech para criar Dockerfile, Compose, manifesto Kubernetes (testado com Kind), endpoints de health check e script de seed.

### O problema remanescente: "babar a IA"

Mesmo com todos esses avanços, o instrutor identificou que precisava constantemente:
- Instruir a IA sobre como validar cada etapa (ex.: usar Docker Compose para testar Docker, usar Kind para testar Kubernetes, como testar com Python).
- Corrigir a IA quando ela esquecia alguma etapa solicitada.

Isso funciona em um projeto pequeno como o Encontros Tech, mas não escala: em cenários reais há múltiplos projetos (billing, marketplace, SaaS) e múltiplas squads trabalhando simultaneamente — "ficar de babá da IA o tempo todo" não é eficiente.

### O erro comum: culpar o modelo

Diante de resultados inconsistentes, a reação comum é achar que o modelo é insuficiente ("vou trocar o Sonnet/Haiku por um modelo melhor"). O instrutor argumenta que esse é um dos maiores erros que frustram profissionais e projetos no uso de IA — além de inviabilizar economicamente, já que modelos melhores custam mais caro. É possível obter, mesmo com modelos mais baratos (Sonnet, Haiku), resultados equivalentes a modelos muito mais caros, desde que se trabalhe de forma controlada.

### Harness Engineering e Loop Engineering — definições formais

- **Harness**: entra "acima" do agente de codificação e do SDD, fornecendo o **ambiente de execução** do agente — recursos que dão mais controle sobre a execução e validação das tarefas. Está ligado a acelerar o uso da IA sem perder assertividade.
- **Loop Engineering** (engenharia de loop): está relacionado ao **controle dos ciclos de execução** que a IA realiza — dá controle de execução, complementando o ambiente fornecido pelo harness.

### Evidências de impacto (cases citados)

- **Cursor**: usando o mesmo modelo da Anthropic, apenas ajustando o harness, aumentaram a performance/acerto do agente de IA de **46% para 80%**.
- **LinkedIn**: apenas mudando o harness, subiram de **30º lugar para 5º lugar** no ranking de melhoria do agente de IA.

Conclusão do instrutor: a diferença real de resultado está muito mais no domínio de harness e loop do que em trocar para um modelo mais caro/poderoso — e esse é o diferencial que destaca um profissional.

## Comandos e configurações

Não há comandos ou prompts nesta aula — é conteúdo conceitual/introdutório.

## Pegadinhas

- A reação intuitiva de "trocar o modelo" quando os resultados são inconsistentes costuma ser o diagnóstico errado — o problema geralmente está no ambiente (harness) e no controle de execução (loop), não no modelo em si.
- O ganho de harness bem ajustado pode ser substancial mesmo com modelos mais baratos — o investimento em harness tem ROI potencialmente maior do que investir em modelos mais caros.

## Dúvidas para revisar

- Quais componentes específicos do harness serão detalhados na próxima aula (Harness Engineering)?
- Como o loop engineering se relaciona na prática com o ciclo ReAct dos agentes de codificação já estudado?
- Os cases do Cursor e do LinkedIn usaram quais tipos específicos de ajuste de harness (rules, hooks, sub agentes)?
