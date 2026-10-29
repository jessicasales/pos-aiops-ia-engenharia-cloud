# PRD Seed — segundo PRD do projeto

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 06 — PRD Seed (11:19) |
| **Assunto** | Aplicar o mesmo fluxo brainstorm → PRD à funcionalidade de popular dados (seed) |
| **Data** | 29/10/2026 20:04 |
| **Tags** | `prd` `brainstorm` `seed` `idempotência` `predicados` |

## Resumo da aula

Repetição do fluxo da aula anterior (brainstorm → PRD), agora para a funcionalidade de **seed**: hoje a aplicação sobe sem eventos cadastrados, e o cadastro inicial é feito manualmente via arquivo `.http`. Objetivo: um script de seed automatizado.

## Conceitos principais

### Decisões levantadas no brainstorm
- **Disparo**: script separado por comando (não automático no startup, não os dois).
- **Idempotência**: só popula se a tabela estiver vazia — sem verificação registro a registro.
- **Independência**: o script deve ser **totalmente independente da aplicação** — o brainstorm identificou ambiguidade aqui e perguntou se deveria reusar o model da app (zero import de `src/`) ou abrir conexão própria. Decisão: **zero import de `src/`**, abre sua própria conexão.
- **Fonte de dados**: hardcoded no script, baseada no arquivo `.http` existente, com datas atualizadas para o momento atual (ancoradas em "agora").
- Tecnologia, localização e nome do arquivo ficaram **em aberto** — isso é decisão de planejamento/implementação, não de PRD.

### Observação sobre o fluxo de perguntas do brainstorm
O agente às vezes faz as 3 perguntas em texto corrido; em outros momentos, gera uma interface de múltipla escolha (`Ask to User`) para você marcar — depende do comportamento do momento.

### Resultado
PRD salvo com estrutura igual à anterior: contexto, atores, predicados (Dado/Quando/Então — ex. "dado que a tabela de eventos está vazia, quando o script é executado, então os 10 eventos da lista fixa são inseridos"), invariantes (rodar o script qualquer número de vezes nunca duplica a carga inicial), restrições, fora do escopo (orquestração de pipeline, migration, tecnologia, execução automática no startup), critérios de aceite.

## Prompts da aula

```text
Atualmente, a aplicação inicia sem nenhum registro de evento. Existe um arquivo
.http que é utilizado para fazer esse cadastro inicial. Mas eu quero criar um
script de seed para automatizar esse processo de população de criação de
registros quando eu faço o start da aplicação. E aí, dessa forma, eu consigo
fazer cadastros iniciais localmente para desenvolvimento ou até colocar numa
pipeline CI/CD.
```
(usa o mesmo prompt-template de brainstorm da aula anterior)

```text
Agora, a partir de TUDO que amadurecemos no brainstorm acima, escreva o PRD
do seed. Use nossa conversa como fonte — não recomece nem me re-entreviste.

REGRA CENTRAL: o PRD descreve COMPORTAMENTO e REGRA DE NEGÓCIO (o "o quê"/"porquê"), nunca a implementação (biblioteca, estrutura de arquivo, conexão com o banco são decisão de ADR/TRD).

Mantenha o formato do PRD agêntico que já usamos (contexto, atores, predicados Dado/Quando/Então, invariantes, restrições, fora do escopo com porquê, critérios de aceite). O que não ficou definido, infira e marque inline com *(premissa — confirme ou corrija)*.

Ao terminar, me mostre o PRD para revisão.
```

## Pegadinhas
- O resultado é **probabilístico, não determinístico** — seu PRD pode sair ligeiramente diferente do da aula; sempre revise antes de aceitar.
- Tecnologia nunca entra no PRD, mesmo quando o brainstorm pergunta — isso vai para TRD/ADR (próximas aulas).

## Dúvidas para revisar
- Os dois PRDs (health/ready e seed) estão prontos — a próxima etapa é a documentação técnica (TRD/ADR) para então implementar.
