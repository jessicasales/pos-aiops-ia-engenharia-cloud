# ReAct (Reasoning + Acting)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Engenharia de Prompt e Contexto |
| **Capítulo** | Técnicas avançadas de Prompt Engineering |
| **Aula** | 06 — ReAct (19:52) |
| **Assunto** | Loop raciocínio → ação → observação; a base dos agentes de IA |
| **Data** | 03/11/2026 23:58 |
| **Tags** | react, reasoning-acting, think-action-observation, ferramentas, agentes, cve, dados-reais |

## Resumo da aula

As técnicas anteriores operam sobre algo que o modelo **já gerou**, usando só conhecimento interno. O **ReAct** (Reasoning + Acting) faz o modelo **raciocinar** sobre o que precisa e **executar uma ação concreta** (pesquisa, consulta a API, comando, leitura de arquivo), **observar** o resultado e usar esse dado real para decidir o próximo passo. É a diferença entre planejar no escuro e planejar com dados reais. Formalizado num paper do **ICLR 2022**.

## Conceitos principais

### O loop Think → Action → Observation

1. **Thought**: raciocina sobre o que sabe e o que precisa descobrir.
2. **Action**: executa uma ação concreta (busca, API, comando, ler arquivo/banco).
3. **Observation**: recebe o resultado e alimenta o próximo pensamento.

Depois da observação, volta ao Thought: *"preciso de mais dados ou já tenho o suficiente?"*. O raciocínio é **explícito** → processo transparente e auditável.

### ReAct vs. as outras técnicas

| | Outra técnica | ReAct |
|---|---|---|
| CoT | Raciocínio interno (conhecimento do modelo) | Raciocínio **alimentado por dados reais** |
| Prompt Chain | Você orquestra a sequência manualmente | O modelo **se orquestra sozinho** |
| Self-Refine | Melhora um output já gerado | Decide e **age antes** de gerar o output |
| Chain of Verification | Verifica se o que gerou está correto | **Busca a informação correta antes** de gerar |

São complementares (ex.: ReAct coleta dados → Self-Refine melhora o resultado).

### Pré-requisito: ferramentas

ReAct depende de **ferramentas disponíveis** (busca web, API, terminal, arquivos, banco). Modelo sem ferramenta só pensa; com ferramenta, pensa **e age**. É aqui a fronteira entre **chatbot** (responde) e **agente** (decide, usa ferramenta, repete até resolver). Claude Code, GitHub Copilot, Amazon Q, Kiro operam nesse ciclo; LangChain e CrewAI implementam ReAct como arquitetura base.

### Quando usar / não usar

- **Usar**: troubleshooting de infra (kubectl, docs, versão em execução), análise de incidentes (API Prometheus, logs), investigação de segurança (CVEs), planejamento de migração (compatibilidade de versão), qualquer cenário onde **alucinação é inaceitável** e precisa de dados em tempo real.
- **Não usar**: problemas puramente lógicos/matemáticos (CoT é mais rápido), geração criativa/brainstorm, perguntas simples, e quando o custo de múltiplas chamadas de ferramenta não compensa.

### Limitações práticas

- Pode entrar em **loop repetitivo** → defina um máximo de iterações.
- Depende da **qualidade das ferramentas** (busca ruim = raciocínio sobre lixo).
- **Muitas ferramentas** confundem o modelo sobre qual usar.

## Prompts da aula

> Ambos exigem **busca web habilitada** no serviço usado. A instrução-chave é *"não invente nada, pesquise tudo"* — sem ela, o modelo alucina em vez de buscar.

<details>
<summary>Prompts ReAct (viagem e CVEs)</summary>

```markdown
# Cotidiano — Planejamento de viagem (força Action → Observation via fontes)
Preciso planejar uma viagem de 5 dias para Natal/RN.
Tenho três opções de período: janeiro, junho ou setembro.

Preciso que você:
1. Pesquise e compare clima, preços, lotação e eventos em cada um dos três meses
2. Recomende o melhor mês com base nos dados encontrados
3. Monte um roteiro de 5 dias com atrações reais

Importante: não invente nenhuma informação. Pesquise tudo antes de responder.
Para cada dado, me diga de onde veio.
```

```markdown
# Técnico — Análise de impacto de CVEs (SRE/Segurança)
Nosso scanner de segurança (Trivy) detectou 3 CVEs na imagem base de um
container em produção. Investigue cada uma e monte uma análise de impacto consolidada.

CVEs detectadas:
1. CVE-2024-21626 — componente: runc (container runtime), versão instalada: 1.1.10
2. CVE-2024-32002 — componente: git, versão instalada: 2.43.0
3. CVE-2024-3094 — componente: xz-utils/liblzma, versão instalada: 5.4.5

Para cada CVE, investigue: o que explora e severidade (CVSS); versões afetadas;
se a versão que usamos está vulnerável; qual patch disponível.

Ao final, monte uma análise consolidada com priorização de remediação, considerando:
- containers em Kubernetes com Pod Security Standards no modo restricted
- imagem usada em pipelines CI/CD que fazem git clone
- imagem baseada em Debian stable

Pesquise tudo. Não invente nenhuma informação de severidade, versão ou patch.
Retorne os dados em markdown.
```

</details>

## Pegadinhas

- Sem ferramenta de busca, o ReAct degenera para CoT (o modelo "pesquisa" na própria memória).
- Cada Action consome tempo e tokens — não use para resposta de baixo custo.
- A verificação humana final continua necessária (checar as fontes citadas).

## Dúvidas para revisar

- Quais ferramentas (MCP/tools) eu preciso expor para o ReAct resolver meus troubleshootings?
- Como limitar iterações para evitar loop em investigações longas?
