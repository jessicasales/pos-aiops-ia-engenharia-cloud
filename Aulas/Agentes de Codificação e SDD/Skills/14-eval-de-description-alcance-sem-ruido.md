# Eval de Description — alcance sem ruído

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Skills |
| **Aula** | 14 — Eval de Description: Alcance sem Ruído (11:37) |
| **Assunto** | Testar o disparo (hit rate) da description de uma skill |
| **Data** | 29/10/2026 19:02 |
| **Tags** | `eval` `description tuning` `hit rate` `triggering` `skill-creator` `terraform` `multicloud` |

## Resumo da aula

Depois de evoluir a skill `padroes-terraform` para multicloud (aula 13), o comportamento mudou, mas a **description** continuou enviesada para AWS (nomes de serviço AWS; Azure e GCP como coadjuvantes). Esta aula avalia o **disparo** da skill: com a skill-creator, gera **6 termos que devem disparar** e **6 que não devem**, grava num arquivo separado e roda um **teste de hit rate**, visualizando o resultado na **interface web** da skill-creator.

## Conceitos principais

### Dois tipos de avaliação de skill
| Avaliação | Pergunta | Arquivo |
|---|---|---|
| **Comportamento / execução** | O output está correto? | `evals.json` |
| **Triggering (disparo)** | A skill carrega quando deve — e não carrega quando não deve? | arquivo separado, ex. `description-tuning.json` |

No teste de trigger, **o output não importa**: só se disparou ou não.

### Estrutura do caso de trigger
Cada item tem `query`, `should_trigger` (true/false) e uma nota com o porquê.
- ✅ Deve disparar: "cria um resource group e um storage account com blob container para o artefato" — pedido puro, **sem citar Terraform/TF/IaC**; "escreve a infraestrutura como código do nosso AKS com node pool de sistema separado".
- ❌ Não deve disparar: "qual a diferença entre Blob Storage do Azure e o Cloud Storage do GCP?" — é **conceitual** (pedido de explicação), e a skill é de **criação**.

### Interface web da skill-creator
- Mostra query, se deveria disparar, o porquê, e quantas tentativas dispararam (ex.: 2 de 3).
- Permite **adicionar novas queries** e exportar o eval set para rodar de novo e evoluir a description.

### Quando rodar
Sempre que mudar bastante o comportamento da skill ou adicionar recursos, adicione sentenças ligadas aos novos recursos e rode o teste de trigger também.

## Prompts da aula

```text
Nesse momento, a minha skill de Terraform foi evoluída para suportar múltiplos cloud providers, não mais só a AWS. A description hoje é muito focada em nomes de serviço da AWS e em uso da AWS, e os outros cloud providers viraram coadjuvantes. Quero rodar um description tuning que me ajude a detectar termos que devem disparar essa skill e termos que não devem disparar a skill, para que eu consiga rodar depois um teste de hit e identificar onde devo melhorar a description dela. Quero que você liste seis termos que devem disparar essa skill e seis termos que não devem disparar essa skill, para poder efetuar o teste.
```

```text
Não coloque junto com os evals de execução (evals.json). Crie um arquivo separado, description-tuning.json, para rodar só a parte de gatilho (triggering). Deixe separado em um arquivo específico para trigger da skill.
```

```text
/skill-creator Execute o teste de hit rate da skill de Terraform para medir a eficiência da description da skill.
```

```text
Quero a interface web para analisar os resultados e adicionar novos gatilhos.
```

## Pegadinhas
- A lista de termos gerada é probabilística — a sua pode sair diferente.
- Falhas no teste podem não ser da description: na demo, a skill procurou arquivos `.tf` inexistentes. Leia o motivo de cada falha.
- Não misture casos de trigger com evals de execução.

## Dúvidas para revisar
- Criar um `description-tuning.json` para as minhas skills mais usadas.
