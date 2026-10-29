# Avaliar o Comportamento de uma Skill (Skill Evaluation)

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 13 — Avaliar o Comportamento de uma Skill (56:02) |
| **Assunto** | Medir uplift, custo, preferência e estabilidade de uma skill com evals, subagentes e teste A/B |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `eval` `evals.json` `skill` `assertions` `uplift` `benchmark` `subagentes` `teste A/B` `skill-creator` `terraform` `multicloud` |

## Resumo da aula

Skills são execuções **probabilísticas**, então precisam de avaliação como os prompts (prompt evaluation). Avaliar "no olho" tem armadilhas. A aula usa a **skill-creator** para avaliar a skill de Terraform (`padroes-terraform` / `terraform-guidelines`), que nasceu focada em AWS:

1. **Demo 01** — monta `evals/evals.json` com 6 casos (geração e revisão × AWS, Azure, GCP) e as assertions.
2. **Demo 02** — roda 6 casos × 2 configurações (com/sem skill) × 2 repetições = **24 execuções** em subagentes, gradua com subagentes separados, agrega em benchmark e abre o **viewer web**.
3. **Resultado v1**: AWS com skill 100% × sem skill ~81%; **Azure e GCP com skill 0%** (sem skill ~85%) — a skill atrapalhava fora da AWS.
4. **Demo 04** — plano de melhoria multicloud baseado nos feedbacks e notas da avaliação.
5. **Demo 05** — **teste A/B** skill antiga × skill nova (9 evals × 2 configs × 2 repetições = 36 execuções). Azure/GCP foram de 0% para **100%** sem quebrar AWS.

## Conceitos principais

### O que medir numa skill
| Dimensão | Pergunta |
|---|---|
| **Uplift** | Com a skill fica melhor do que sem? (assertividade, qualidade, velocidade) |
| **Custo** | Tokens, tempo, tamanho de contexto |
| **Preferência** | O resultado atende o que eu espero? |
| **Estabilidade** | Executando de novo, o resultado se mantém ou foi sorte? |

### `evals.json` (padrão agentskills.io)
- Fica em `evals/` **dentro da pasta da skill** — não é carregado no uso, porque o progressive disclosure só segue as referências do `SKILL.md`.
- Cada caso tem **exatamente**: `id`, `prompt`, `expected_output`, `files`, `expectations`.
- Casos de revisão recebem arquivos de entrada (`evals/files/aws-nao-conforme/` etc.), com código que viola as regras de propósito.

### Duas famílias de assertions
| Prefixo | Mede |
|---|---|
| `casa_*` | **Obediência** à convenção da casa — o que a skill manda (layout de módulo, nomes, description em variables/outputs, formato `{name}_{type}_{attribute}`, pin `~>`, nada de Registry, relatório separando bloqueante de recomendação) |
| `provider_*` | **Correção** no ecossistema do provider — o que a skill não manda (3 por caso: recurso principal certo, nenhum recurso de outro provider, nenhum argumento inexistente) |

"Uma régua só de `casa_*` provaria obediência sem provar ganho." Se as famílias divergem, aí está a história.

Regras das assertions: verificáveis **na saída**, com nome que se lê sozinho numa tabela, PASS só com evidência citável. **Não transformar julgamento em assertion** ("está idiomático" fica de fora — avaliação humana).

### Protocolo de execução (anti-viés)
```text
Agente main
├── subagente executor (eval1, com skill, run1)   ← recebe SÓ prompt + files
├── subagente executor (eval1, com skill, run2)      nunca expected_output/assertions
├── subagente executor (eval1, sem skill, run1)
└── ...
depois:
├── subagente grader (por execução)               ← recebe SÓ saída + assertions
```
- **Contexto limpo** por execução, sem vazamento entre execuções nem da conversa.
- Executor não vê a régua → senão a baseline ganha as regras de graça e o uplift não significa nada.
- **Quem executa não julga** → evita a tendência de aprovação.
- Bônus: paralelização.
- Custo: **alto consumo de tokens**. Comece com poucos casos/repetições, principalmente em conta Pro ou API.

### Saídas e viewer
- Workspace `iteration-1/`, `iteration-2/`... com uma pasta por execução: outputs, métricas (tempo, tokens), `benchmark.json`, `benchmark.md`, `feedback`.
- Viewer local (na demo, localhost:3117): aba **Benchmark** (pass rate, tempo, tokens com e sem skill) e aba **Outputs** (prompt, saída, campo de feedback por execução).
- Pode ser **versionado** no Git (se não tiver dado sensível) → histórico de avaliação da skill.
- Feedback no viewer deve ser **específico**, não "ficou ruim".

### Pontos de análise pedidos (sobre a régua, não sobre a skill)
- Assertion que passou nas duas configurações em tudo → **não discrimina**.
- Assertion que falhou nas duas em tudo → quebrada ou fora do alcance.
- Caso que oscilou entre repetição 1 e 2.
- Assertion que passaria com saída inventada → mede presença, não correção.

### Teste A/B
Depois de responder "a skill ajuda?" (com × sem), a pergunta passa a ser: **"a mudança melhorou Azure/GCP sem quebrar AWS?"** → comparar **versão antiga × versão nova**, sem configuração sem skill.

## Prompts da aula (resumo)

<details>
<summary>Demo 01 — montar a suíte de eval (pontos principais)</summary>

- "Avalia a skill padroes-terraform com a skill-creator. Monta a suíte de eval com 6 casos: as MESMAS duas tarefas repetidas em três providers."
- **Tarefa A (geração):** "cria um módulo de storage com um bucket S3 / storage account / bucket no Cloud Storage pro artefato de build". Esperado: `modules/storage/` com `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`; recursos acessórios separados; nome sem repetir tipo; description em tudo; provider com `~>`; nada do Registry.
- **Tarefa B (revisão):** "revisa esse módulo antes de eu abrir o PR" com `evals/files/<provider>-nao-conforme/`. Esperado: relatório que aponta cada divergência com regra, correção, arquivo e linha; prioriza regras da casa; separa bloqueante de recomendação.
- Escrever as assertions nas famílias `casa_*` e `provider_*`; não inventar campos; gravar em `evals/evals.json`.
- **"PARE DEPOIS DE CRIAR"** — não rodar eval nem benchmark (são 24 execuções; revisar antes). "Não me faça perguntas."
</details>

<details>
<summary>Demo 02 — rodar, graduar e agregar (pontos principais)</summary>

- 6 casos × (COM skill / SEM skill = baseline) × 2 repetições = 24 execuções, cada uma num subagente com contexto limpo.
- Executor recebe só prompt + files. Nome descritivo por caso (campo `eval_name`, não "eval-0").
- Gravar saída completa, `total_tokens`, `duration_ms`, tool calls, erros; copiar `eval_metadata.json` para cada pasta de execução; gravar `outputs/resultado.md` com a árvore e o conteúdo (o viewer só lê o primeiro nível de `outputs/`).
- Graduar com agente **separado**, assertion por assertion, evidência citada; texto da assertion gravado **exatamente igual** (chave para cruzar configurações). `expectations` (evals.json) = `assertions` (metadado).
- Agregar **com o script**, não na mão. Corrigir: `runs_per_configuration` (2, não 3), nome do modelo executor, não inventar coluna zerada.
- Tabela extra: pass rate por **família × configuração × provider**, repetições lado a lado.
- Viewer oficial da skill-creator (Python 3.10+). Na conversa, só o agregado (pass rate, tempo, tokens com média, desvio e delta).
</details>

```text
# Demo 04 — Plan Mode + /skill-creator
A skill de Terraform foi executada em uma bateria de interação; foram feitos testes com ela para ver o desempenho em ambiente multi-cloud. Está muito claro que essa skill está projetada para o ambiente AWS. Então eu quero que, baseado nos feedbacks que eu fiz nessa primeira interação de assertion e nas próprias notas adicionadas no processo de avaliação, seja feito um plano de melhoria dessa skill para atender ambientes com múltiplos cloud providers, dando suporte a ambiente Azure e também a ambiente GCP.
```

```text
# Demo 05 — A/B cego
Adiciona ao plano de execução uma segunda interação de teste. Só que dessa vez, em vez de utilizar "sem skill" e "com skill", quero que seja feita a comparação entre a skill atual — a skill antes da execução deste plano de alteração — e a skill nova que vai ser criada. Quero que todos os testes utilizem subagentes para fazer a execução das evaluations, e que depois também seja usado subagente para aplicar os critérios de avaliação, para que eu tenha sempre uma janela de contexto limpa para cada execução e não haja a tendência de aprovação por estar usando a mesma janela de contexto.
```

```text
Houve erro no load do WebView. Os dados de benchmark não aparecem.
```

## Pegadinhas
- Use o **melhor modelo disponível** para montar e conduzir a avaliação (raciocínio forte).
- Sem skill às vezes é **mais rápido** — rápido sem resultado não adianta (AWS: sem skill mais rápido, mas 81% × 100%).
- A skill pode **piorar** fora do domínio dela (Azure/GCP 0% com skill × 85% sem). Só aparece medindo.
- Execuções podem quebrar e ser re-executadas; o viewer às vezes mostra benchmark zerado — peça para corrigir o formato.
- Faça commit dos resultados entre iterações para ver o diff da skill depois.
- A avaliação de execução não testa o **gatilho** — isso é a próxima aula (eval de description).

## Dúvidas para revisar
- Montar uma suíte mínima (2–3 casos, 1 repetição) para uma skill minha antes de distribuir.
- Relacionar com as anotações de prompt evaluation (arquivo de rubrica).
