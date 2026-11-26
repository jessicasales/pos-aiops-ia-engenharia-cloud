# Checkpoint 10 — O playbook em produção contínua

## O Fechamento

A biblioteca já está **organizada** e alguns prompts já **têm testes**.

Falta o que separa um repositório de prompts de um **sistema confiável**: garantir que **nenhuma alteração entre sem passar pelos testes**.

Esse é o fechamento — **o playbook como código de produção**, com a suíte de avaliação rodando sozinha a cada mudança.

---

## O Escopo

### Cobertura Completa

Leva a cobertura de testes pro **repositório inteiro**:
- Cada prompt da biblioteca precisa do seu conjunto promptfoo
  - **Determinístico** onde der
  - **Com juiz** onde precisar de julgamento

### Pipeline de Integração

Monta o pipeline que **roda essa suíte a cada alteração**:
- **Toda** pull request e push
- **Falha o build** quando um prompt regride (mudança piora um prompt vs. versão anterior)

---

## Ferramenta: GitHub Actions

**O promptfoo tem uma action oficial:**  
https://www.promptfoo.dev/docs/integrations/github-action/

Use como ponto de partida para:
- Rodar a suíte no PR
- Comentar resultado direto na PR

---

## Decisões de Design do Gate

A ferramenta está definida (GitHub Actions), mas o **desenho do gate** é seu. Existem múltiplos caminhos defensáveis. Você precisa tomar decisões sobre:

### 1. Critério de Falha

| Opção | Descrição | Custo/Risco |
|-------|-----------|-----------|
| **Só determinísticos** | Falha se assert estruturado falhar | Baixo custo, risco de deixar qualidade cair |
| **Determinísticos + juiz** | Falha também se nota do juiz < 6 | Maior custo (mais chamadas), risco de flutuação |
| **Juiz com threshold dinâmico** | Ajusta corte por tipo de mudança | Complexidade, ajuste fino |

### 2. Escopo da Avaliação

| Opção | Descrição | Custo/Risco |
|-------|-----------|-----------|
| **Suíte inteira** | Roda todos os prompts a cada mudança | Maior gasto de tokens, maior confiança |
| **Só prompts alterados** | Roda apenas os que mudaram | Menor custo, risco de regressão em dependências |
| **Prompts alterados + testes que falharam** | Roda alterados + testes que passaram antes | Balanço, mais complexo |

### 3. Gestão de Custos

| Aspecto | Decisão |
|--------|---------|
| **Custo por PR** | Quanto máximo gastar por avaliação? |
| **Throttling** | Aguardar entre PRs? Limitar concorrência? |
| **Secrets** | Onde guardar chaves de provedores? (Secrets do repositório) |

---

## A Entrega

A entrega central é:

1. **Arquivo de workflow** (`.github/workflows/promptfoo.yml`) **funcionando**
2. **Evidência de execução:**
   - Um sucesso (todos os prompts passam)
   - Idealmente, uma **falha provocada** (um prompt regredido propositalmente)
3. **Estratégia de gate** (o que falha o build e por quê)
4. **Justificativa estendida:**
   - Comparar **ao menos 2 alternativas** em cada decisão
   - Apontar **o que se ganha e o que se perde** em cada uma

> Este é o ponto em que o playbook encosta no terreno de automações que vem mais adiante. O que você automatiza aqui é a **base do que vem depois**.

---

## Tarefa

**Levar a cobertura de testes** a todos os prompts  
**Construir o pipeline em GitHub Actions** que roda a suíte a cada alteração e **barra regressão**

## Entregáveis

- Arquivo de workflow do GitHub Actions
- Evidência de execução (sucesso + falha provocada idealmente)
- Estratégia de gate (o que falha o build e por quê)
- Justificativa estendida: comparação de ao menos 2 alternativas em cada decisão de design