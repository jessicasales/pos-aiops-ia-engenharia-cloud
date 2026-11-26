# Checkpoint 08 — Testes determinísticos com promptfoo

## O Princípio

**Prompt na biblioteca sem teste é prompt em que ninguém confia.**

A partir daqui, cada prompt ganha o seu próprio `promptfooconfig.yaml`, ao lado do `prompt.md` na pasta do prompt — **o teste viaja junto com o prompt**.

Neste checkpoint você escreve esses testes e **roda de verdade** (`promptfoo eval`).

---

## A Realidade: Nem Tudo É Testável

⚠️ **Nem todo prompt dá para testar de forma determinística** (sem julgamento humano).

- ✓ **Testáveis (saída estruturada):** causa-raiz (CP03), backpressure (CP04), migração (CP05)
- ✗ **Não testáveis assim:** saída aberta, resposta única verificável por regex

A avaliação com julgamento é a **camada que você monta no CP09** e estende no CP10.

---

## Cobertura: Três Prompts de Saída Estruturada

Aqui você cobre os três prompts que **têm saída estruturada**, e os **requisitos de cada um já estão dados**:

### 1. nota-de-triagem

**Arquivo:** `devops/nota-de-triagem/promptfooconfig.yaml`

**Executar contra:** 3 alertas crus do CP02

**Asserts obrigatórios:**
- Contém os cinco rótulos: `ALERTA:`, `IMPACTO:`, `HIPÓTESE INICIAL:`, `AÇÃO IMEDIATA:`, `ESCALAR PARA:`
- Campo de escalonamento tem handle no formato `@palavra` (regex: `ESCALAR PARA:.*@\w+`)
- Nota é concisa: **máximo 8 linhas**

**Esqueleto:**
```yaml
prompts:
  - file://devops/nota-de-triagem/prompt.md
providers:
  - openai:gpt-4o-mini
  # adicione um segundo provider de outro fornecedor
tests:
  - vars:
      alerta_cru: >
        2026-05-12 14:02:09 UTC [Sentinel] autoscaler hit max replicas (60/60)
        on sentinel-api, queue depth on Relay growing 2k/min, CPU avg 88%
    assert:
      # complete com os asserts da lista acima
```

### 2. triagem-de-pods

**Arquivo:** `devops/triagem-de-pods/promptfooconfig.yaml`

**Executar contra:** 3 entradas (snapshots) do CP01

**Asserts obrigatórios:**
- **Entrada 1:** saída cita `sentinel-api-7d9c8b6f4-h4m2t` e causa (contém `OOMKilled` ou memória)
- **Entrada 2:** cita os 2 pods problemáticos e suas causas (tag `2.9.2`/`ImagePullBackOff` e falta de cpu/`Insufficient`)
- **Entrada 3 (saudável):** saída indica que não há pod problemático, não classifica nenhum pod em falha

### 3. networkpolicy-sentinel

**Arquivo:** `devops/networkpolicy-sentinel/promptfooconfig.yaml`

**Executar contra:** manifesto permissivo + regras + mapa de serviços do CP06

**Asserts obrigatórios:**
- É YAML válido com `kind: NetworkPolicy` e `policyTypes` contendo `Ingress` e `Egress`
- Não há regra allow-all (saída **não contém** `- {}`)
- Egress libera Forge (porta 5432) e Cerebro (porta 9200)
- Ingress libera Relay (`app: relay`)
- **Toda regra tem comentário** (`#`)

---

## Limites Operacionais Globais

Além dos requisitos específicos, **todo config** inclui dois limites:

| Limite | Valor | Descrição |
|--------|-------|-----------|
| **Latência** | 5s | Cada chamada responde em no máximo 5s |
| **Custo** | US$ 0,01 | Cada chamada custa no máximo 0,01 |

> O playbook trata latência e custo como parte da qualidade. Um modelo mais caro ou mais lento pode reprovar aqui — é esse trade-off que você precisa pesar e justificar.

---

## Tipos de Assert

Use os tipos disponíveis no promptfoo conforme cada requisito:

- `contains`, `regex`, `not-contains` — para validação de conteúdo
- `is-json` — para validação de formato
- `javascript` — para lógica complexa (ex: contar linhas, rejeitar padrões)
- `latency`, `cost` — para limites operacionais

---

## Tarefa

**Escrever um `promptfooconfig.yaml` por prompt** (os 3 acima), cada um cumprindo os requisitos + limites, **rodar `promptfoo eval`** e **registrar o resultado de cada um**.

## Entregáveis

- Os 3 arquivos de configuração
- Saída real de cada execução (`promptfoo eval`, com pass/fail)
- Curadoria: o que passou, o que falhou, o que você ajustou