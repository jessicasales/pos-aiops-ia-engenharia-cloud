### QUESTÃO 6 - Relatório mensal de transações do Ledger

Jennifer está fechando a apresentação que vai levar pra Goldie na semana que vem, sobre crescimento de transações nos últimos 6 meses por categoria. Ela precisa dos números consolidados mas não escreve SQL, então mandou a demanda pra sua fila. O Ledger (PostgreSQL) tem o histórico completo, e as duas tabelas relevantes estão abaixo.

```text
CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  payment_method  VARCHAR(16),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_category ON transactions(category);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```
Categorias em produção hoje: subscription, one_time, refund e credit_adjustment. Só entra no relatório quem tem status = 'completed'. O campo amount_cents está em centavos de real e precisa aparecer na saída em reais com 2 casas decimais. O recorte é dos últimos 6 meses corridos a partir de hoje (2026-04-24), agrupado por mês (no formato YYYY-MM) e por categoria, trazendo duas métricas por linha: quantidade de transações e volume total em reais. Ordenação final: mês crescente, depois categoria crescente.

Tarefa. Aplicando o framework T-A-G, escrever o prompt de IA que produza essa query SQL.

Entregue. Prompt, modelo, output e justificativa mostrando como Task, Action e Goal aparecem no prompt.

---
#### 🤖 Prompt:
```text
#Task
Você é um especialista em banco de dados relacional Postgres, analise informações para construção de uma query SQL.

#Action
Analise as tabelas do banco PostgreSQL:

CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  payment_method  VARCHAR(16),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_category ON transactions(category);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

O recorte é dos últimos 6 meses corridos a partir de hoje (2026-04-24), agrupado por mês (no formato YYYY-MM) e por categoria

#Goal
Objetivo: Construir uma query SQL atualizada com números consolidadas demonstrando o crescimento das transações nos últimos 6 meses por categoria.

Considere os dados atualizados de produção:
- Categorias subscription, one_time, refund e credit_adjustment. 
- Mostrar somente status = 'completed'
- Mostrar campo amount_cents está em reais com 2 casas decimais. 
- Trazer duas métricas por linha: quantidade de transações e volume total em reais
- Ordenação final: mês crescente, depois categoria crescente.
```
---
#### 🛠️ Modelo:
GPT 5.5

---
#### 📦 Output:

># Crescimento das Transações nos Últimos 6 Meses por Categoria
>
>## Query SQL
>
>```sql
>SELECT
>    TO_CHAR(DATE_TRUNC('month', created_at), 'YYYY-MM') AS month,
>    category,
>    COUNT(*) AS transaction_count,
>    ROUND(SUM(amount_cents) / 100.0, 2) AS total_amount_brl
>FROM transactions
>WHERE status = 'completed'
>  AND category IN (
>      'subscription',
>      'one_time',
>      'refund',
>      'credit_adjustment'
>  )
>  AND created_at >= DATE '2026-04-24' - INTERVAL '6 months'
>  AND created_at < DATE '2026-04-25'
>GROUP BY
>    DATE_TRUNC('month', created_at),
>    category
>ORDER BY
>    DATE_TRUNC('month', created_at),
>    category;
>```
>
>---
>
>## Objetivo
>
>Consolidar as transações dos **últimos 6 meses corridos** (considerando a data de referência **2026-04-24**), agrupando os resultados por:
>
>- Mês (`YYYY-MM`)
>- Categoria
>
>Exibindo para cada combinação:
>
>- Quantidade de transações concluídas
>- Volume financeiro total em reais (R$)
>
>---
>
>## Regras Aplicadas
>
>- Considera apenas transações com:
>  - `status = 'completed'`
>
>- Considera somente as categorias:
>  - `subscription`
>  - `one_time`
>  - `refund`
>  - `credit_adjustment`
>
>- O valor armazenado em `amount_cents` é convertido para reais:
>  - divisão por `100`
>  - arredondamento para **2 casas decimais**
>
>- Ordenação:
>  1. Mês crescente
>  2. Categoria crescente
>
>---
>
>## Explicação da Query
>
>| Trecho | Finalidade |
>|---------|------------|
>| `DATE_TRUNC('month', created_at)` | Agrupa todas as transações do mesmo mês. |
>| `TO_CHAR(..., 'YYYY-MM')` | Formata o mês conforme solicitado. |
>| `COUNT(*)` | Quantidade de transações concluídas. |
>| `SUM(amount_cents)` | Soma o volume financeiro em centavos. |
>| `SUM(amount_cents) / 100.0` | Converte centavos para reais. |
>| `ROUND(..., 2)` | Exibe o valor com duas casas decimais. |
>| `created_at >= DATE '2026-04-24' - INTERVAL '6 months'` | Define o início da janela de análise. |
>| `created_at < DATE '2026-04-25'` | Inclui todas as transações do dia 24/04/2026, independentemente do horário. |
>
>---
>
>## Exemplo de Resultado
>
>| month | category | transaction_count | total_amount_brl |
>|-------|----------|------------------:|-----------------:|
>| 2025-10 | credit_adjustment | 18 | 1245.50 |
>| 2025-10 | one_time | 2348 | 584320.80 |
>| 2025-10 | refund | 97 | -8450.20 |
>| 2025-10 | subscription | 5120 | 256430.00 |
>| 2025-11 | credit_adjustment | 22 | 980.00 |
>| ... | ... | ... | ... |
>
>---
>
>## Observações
>
>Esta consulta retorna os valores consolidados por mês e categoria.
>
>Caso seja necessário medir efetivamente o **crescimento**, a consulta pode ser estendida utilizando funções de janela (`LAG`) para calcular indicadores como:
>
>- Crescimento mensal da quantidade de transações (%)
>- Crescimento mensal do volume financeiro (%)
>- Diferença absoluta em relação ao mês anterior
>- Tendência de crescimento por categoria
---
#### 💡 Justificativa: 
Preferi escrever na Task a função que iria desempenhar pra ativar um estudo mais coeso da necessidade.

Em Action, dei o detalhamento do que seria a task de análise da query

Em Goal escrevi o objetivo central: o retorno esperado com os detalhes específicos e ordenados, pra melhor aproveitamento.