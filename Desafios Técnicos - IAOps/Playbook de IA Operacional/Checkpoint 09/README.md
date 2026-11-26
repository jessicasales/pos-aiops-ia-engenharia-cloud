# Checkpoint 09 — Gate de qualidade com LLM-as-judge

## O Desafio

O CP08 cobriu a **camada determinística** — formato, latência, custo, tudo que dá para checar sem opinião.

Mas **determinismo não pega qualidade**. A análise de causa-raiz do CP03 **não tem resposta única** verificável por regex: ela **precisa de julgamento**.

Este checkpoint adiciona, em cima do CP08, um **gate de qualidade com LLM-as-judge** para o prompt de causa-raiz.

**Arquivo:** `devops/causa-raiz/promptfooconfig.yaml`

---

## A Rubrica

Avalie a saída da causa-raiz em **4 critérios**, cada um numa escala de **0 a 2** (0 = não atende, 1 = parcial, 2 = atende):

| Critério | Pontos | Descrição |
|----------|--------|-----------|
| **Causa-raiz correta** | 0–2 | Aponta a causa real (reindexação travada → heap saturado → circuit breaker → timeouts → cache queda), não apenas sintomas |
| **Correlação × causa** | 0–2 | Separa causa de consequência (ex: cache hit caindo é efeito, não causa) |
| **Ação proporcional** | 0–2 | Propõe ação coerente com diagnóstico (ex: conter/reagendar reindexação, rever heap), sem sobre/subdimensionar |
| **Honestidade epistêmica** | 0–2 | Reconhece o que os dados não permitem concluir, não fabrica certeza |

**Total:** 0–8  
**Critério de aprovação:** nota total **≥ 6** e **nenhum critério zerado**

---

## O Juiz como Gate

Configure um juiz no promptfoo (`llm-rubric` ou `model-graded-closedqa`) que:
- Aplique exatamente essa rubrica
- Reprove quando nota total < 6

### Calibração

**Para o gate ser confiável, calibre uma vez:**

1. Pontue você mesmo algumas saídas
2. Ajuste o prompt do juiz até a nota dele ficar no **máximo 1 ponto de diferença** da sua em cada critério
3. Calibrado, ele roda sozinho

### Gate Contínuo

O gate **roda a cada alteração**:
- Sempre que o prompt de causa-raiz muda, o gate roda de novo
- Barra a mudança se a nota cair abaixo do corte
- É essa **execução automática** que o CP10 vai colocar no pipeline

---

## Tarefa

**Escrever a rubrica** (4 critérios, escala 0–2, corte ≥ 6)  
**Configurar `promptfooconfig.yaml`** com o juiz como gate  
**Calibrar o juiz** contra sua própria pontuação

## Entregáveis

- A rubrica (critérios, escala, corte)
- `promptfooconfig.yaml` com o juiz configurado
- Saída real da execução do juiz
- Curadoria: como você calibrou o juiz, o que ajustou