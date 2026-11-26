# Checkpoint 07 — A biblioteca vira código

## O Desafio

Você já tem um **punhado de prompts parametrizáveis**, cada um nascido sob sua direção.

Mas o Nick Fury não aceita isso espalhado: **o playbook precisa virar um ativo versionado**, tratado como código, que sobreviva à saída de qualquer pessoa do time.

Este checkpoint é sobre **transformar a coleção numa biblioteca de verdade** — e você não vai inventar a estrutura do zero.

---

## A Base: Template prompt-registry

Use como ponto de partida o template: **https://github.com/fabricioveronez/prompt-registry**

Faça um **fork** (ou clone) e organize seus prompts seguindo as convenções dele.

### Convenções do Template

**Categorias** (pastas na raiz, em kebab-case)
- Exemplo: `devops/`, `desenvolvimento/`, etc.
- Uma por domínio, sem aninhar
- Os prompts do playbook caem naturalmente em `devops/`

**Um prompt = Uma pasta**
- Nomeada pelo **resultado**, não pela técnica
  - ✓ `triagem-de-pods/`
  - ✗ `chain-of-thought/`
- Contém dois arquivos:

#### prompt.md
```
—— frontmatter ——
nome: triagem-de-pods
descricao: Triagem rápida de pods problemáticos
versao: 1.0.0
tags: [kubernetes, devops, diagnostico]
inputs:
  - nome: cluster_snapshot
    descricao: Saída de kubectl get/describe + logs
  - nome: namespace
    descricao: Namespace a analisar
—— body ——
Você é um engenheiro DevOps...
(resto do prompt com {{cluster_snapshot}}, {{namespace}}, etc.)
```

#### README.md
```
—— frontmatter (igual ao prompt.md) ——
—— body ——
## Objetivo
...
## Casos de Uso
...
## Exemplo
...
## Limitações
...
```

**Frontmatter completo**
- `nome`, `descricao`, `versao` (semver)
- `tags` (array)
- `inputs` — lista de parâmetros com `nome` e `descricao`

> O campo `inputs` é exatamente onde os parâmetros ficam documentados — os `{{placeholders}}` do prompt.md e o `inputs` do frontmatter são a mesma coisa, agora versionada.

**Versionamento**
- Campo `versao` em cada prompt (semver)
- Commits semânticos com escopo na categoria
  - Exemplo: `feat(devops): adiciona prompt de triagem de pods`
- Índices nos READMEs atualizados a cada mudança

---

## Migração

Mitre para esse formato os prompts que você já produziu nos **Checkpoints 01 a 06**:

Cada um vira uma **pasta com**:
- `prompt.md` parametrizado (com `{{placeholders}}`)
- `README.md` documentado (objetivo, casos de uso, exemplo, limitações)

**Versão inicial:** `1.0.0`  
**Daqui em frente:** toda mudança passa por commit semântico.

> O playbook deixa de ser texto solto e vira **ativo do time**.

---

## Tarefa

**Montar o repositório** a partir do template e **migrar os prompts de CP01 a CP06** para o formato `prompt.md` + `README.md` com frontmatter, versionados e documentados.

## Entregáveis

- Link do repositório baseado no template
- Um prompt no formato completo (`prompt.md` com `{{placeholders}}` + `README.md` com frontmatter) como exemplo dos demais
- Nota curta sobre como você mapeou o playbook nas convenções do template