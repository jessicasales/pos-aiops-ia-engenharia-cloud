# Orquestração pelo Agente Principal

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Sub Agentes |
| **Aula** | 07 — Orquestração pelo Agente Principal (25:19) |
| **Assunto** | O agente principal como orquestrador: decomposição de um incidente em sub-tarefas paralelas usando o modelo de sub-briefing ORDEM (Objetivo, Retorno, Domínio, Exclusão, Momento) |
| **Data** | 29/10/2026 22:05 |
| **Tags** | orquestracao, ordem, sub-briefing, paralelismo, troubleshoot, incidente, worktree |

## Resumo da aula

Última aula do capítulo "Sub Agentes". Até aqui, os sub-agents foram usados de forma sequencial (um de cada vez). Nesta aula, o agente principal (orquestrador) passa a **decompor um problema em sub-tarefas e disparar múltiplos sub-agents em paralelo**, consolidando os resultados. O cenário prático é um **incidente real com dois bugs simultâneos** no projeto Encontros Tech: (1) a localidade do evento aparece vazia na listagem/página do evento (bug de código/template) e (2) o rollout no Kubernetes é dado como concluído instantaneamente, com pods entrando em `Ready` de imediato (ausência de liveness/readiness probes). O orquestrador usa os sub-agents `software-developer` e `devops-engineer` já criados, investigando os dois problemas em paralelo e depois aplicando as correções, também coordenadas.

## Conceitos principais

### Evolução das formas de trabalho com agentes no capítulo

1. Sem agente nenhum — tudo na sessão principal (início do capítulo).
2. Sub-agentes sequenciais — um de cada vez, de forma linear.
3. **Sub-agentes em paralelo, orquestrados pelo agente principal** (esta aula) — o agente principal deixa de ser um "solicitante simples" e passa a **coordenar**: decompor em sub-tarefas, distribuir para os sub-agents certos, e sintetizar os resultados.

### Critérios antes de paralelizar

1. **Área de domínio de cada sub-agente**: já estabelecido (DevOps para infraestrutura, desenvolvimento para código).
2. **Concorrência de arquivos**: múltiplos sub-agents trabalhando na mesma base de código/arquivos pode gerar o mesmo problema que vários desenvolvedores editando o mesmo arquivo — conflitos de merge. É preciso decompor de forma que os domínios de escrita não se sobreponham.
3. **Qualidade do contrato (briefing)**: quanto melhor estruturado o briefing de cada sub-tarefa, melhor a resposta e mais eficiente o sub-agente.

### O modelo de sub-briefing ORDEM

Estrutura de 5 campos que o orquestrador deve preencher para **cada sub-tarefa** criada — o "contrato" que torna a decomposição verificável antes de virar execução:

- **O — Objetivo**: o que a sub-tarefa precisa produzir (específico, não genérico — ex.: "faça o diagnóstico" é vago; "determine se o código atual é capaz de gravar/ler/renderizar a localidade do evento" é específico).
- **R — Retorno**: o formato de resposta esperado (conclusão em uma frase, evidência de erro encontrado, arquivo Markdown/JSON, etc.).
- **D — Domínio**: o que a sub-tarefa pode escrever/ler — quais arquivos/diretórios.
- **E — Exclusão**: o que a sub-tarefa **não** cobre, porque pertence a outra sub-tarefa.
- **M — Momento**: com quem ela corre junto (paralelo) e o que ela precisa esperar (dependência sequencial).

### Demonstração: diagnóstico orquestrado de um incidente com dois bugs

O instrutor provocou dois bugs de propósito: um bug de template (campo renomeado de `location` para `city` na exibição, mas o dado real continua em `location` no banco) e a remoção das probes de liveness/readiness do manifesto Kubernetes.

**Prompt de diagnóstico** enviado ao orquestrador (sem citar nenhum agente pelo nome — o roteamento sai da `description` de cada um): descreve o incidente (localidade vazia na listagem; rollout "instantâneo" com pods entrando em Ready de imediato); define o papel do orquestrador como **coordenar, não executar** (proibido abrir arquivo, rodar comando ou consultar o cluster por conta própria — toda leitura ocorre dentro de uma sub-tarefa); dá a política de decomposição (cortar por **localidade** do problema, não por sintoma — uma sub-tarefa por subsistema/conjunto de arquivos/modelo mental; usar o menor número de sub-tarefas possível; delegar aos agentes especializados disponíveis, escolhendo pela função; o que for independente deve correr em paralelo); exige a estrutura ORDEM para cada sub-tarefa; e **exige apresentação do plano antes de qualquer delegação** (sem aplicar correção nesta etapa).

Resultado: o orquestrador decompôs em 2 sub-tarefas paralelas, ambas somente leitura:
- **Sub-tarefa A** (`software-developer`): determinar se o código é capaz de gravar/ler/renderizar a localidade do evento, percorrendo toda a cadeia (modelo SQLAlchemy, etc.). Domínio de escrita: nenhum. Exclusão: não olhar cluster/manifesto/imagem/configmap. Momento: corre junto com B, não espera ninguém.
- **Sub-tarefa B** (`devops-engineer`): o que está rodando e por que o rollout passou tão rápido. Domínio de escrita: nenhum. Exclusão: não analisar lógica de domínio/esquema. Momento: corre junto com A, não espera ninguém.

Após confirmação do plano pelo usuário, o orquestrador disparou os dois sub-agents em paralelo e, ao final, sintetizou: as duas investigações não se contradizem; o defeito é na aplicação (template), não na infraestrutura/esquema (o dado está correto no banco como `location`, o problema é só a exibição — "print na tela"); o deployment não tem probes (não é "probe fraca", é **ausência total**), o que fez o rollout "passar" mesmo com o pod entrando em crash loop algumas vezes antes de estabilizar.

### Demonstração: correção orquestrada

Com o diagnóstico confirmado, um segundo prompt pede a correção, mantendo a mesma política de coordenação (orquestrador não executa, nem lê por conta própria), mas agora com **domínio de escrita real e não sobreposto** entre as duas sub-tarefas (duas mudanças em camadas diferentes, que não disputam arquivo). Ponto de atenção explícito: a **validação é sequencial** — só pode ocorrer depois que a nova imagem for construída e o rollout feito (dependência real entre as sub-tarefas, diferente do diagnóstico, que era 100% paralelo). Instrução adicional: se alguma mudança não puder ser feita por nenhum agente disponível, o orquestrador deve parar e reportar, em vez de executar ele mesmo.

Resultado observado: o orquestrador disparou as duas correções; o `devops-engineer` (que corrigiu as probes) terminou primeiro, mas **aguardou** o `software-developer` terminar a correção do template antes de disparar uma segunda chamada ao `devops-engineer` para fazer a validação/rollout final — o próprio orquestrador percebeu a dependência sequencial e se ajustou, usando inclusive um *worktree* separado para a correção. Resultado final: "incidente fechado, validação independente, passou nos 5 itens". Pontos deixados em aberto pelo próprio relatório: o probe nunca foi exercitado sob falha real (readiness nunca testado com banco indisponível) e uma recomendação de usar *pin* de versão de imagem.

### Economia de contexto, mesmo em um fluxo complexo

Em ambas as etapas (diagnóstico e correção), a janela de contexto do agente principal ficou em torno de **7-10%**, apesar de todo o processo de investigação, decisão e correção ter sido conduzido por ele — reafirmando que o ganho de usar sub-agentes orquestrados não é só paralelismo, mas também preservação da janela de contexto da sessão principal.

### Fechamento do capítulo

O instrutor recomenda formalizar esse fluxo de orquestração (modelo ORDEM, política de coordenação) como uma **skill** reutilizável, e incentiva replicar o padrão em outros cenários: desenvolvimento de features, investigação de incidentes, e qualquer fluxo que se beneficie de decomposição e execução paralela de sub-agentes especializados.

## Comandos e configurações

```text
# Modelo de sub-briefing ORDEM
Sub-tarefa N — agente <nome>
Objetivo:
Retorno:
Domínio:
Exclusão:
Momento:
```

```text
# Prompt de diagnóstico orquestrado
Estamos num incidente na aplicação Encontros Tech, que roda neste cluster.

O que eu observei: a localidade dos eventos aparece vazia na listagem e na página do evento.

E outra coisa: quando eu subi essa versão, o rollout foi dado como concluído praticamente na hora, e os pods entraram em Ready de imediato.

Seu papel aqui é coordenar a investigação, não executá-la. Não abra arquivo do projeto, não rode comando e não consulte o cluster por conta própria. Toda leitura acontece dentro de uma sub-tarefa, e o que chega até você são as sínteses.

Como decompor:

- corte por localidade, não por sintoma: uma sub-tarefa por subsistema, conjunto de arquivos e modelo mental. O que compartilha isso fica junto, o que não compartilha se separa;
- use o menor número de sub-tarefas que cubra o problema;
- delegue aos agentes especializados disponíveis neste projeto, escolhendo pela função de cada um;
- o que for independente deve correr em paralelo.

Para cada sub-tarefa, especifique:

Objetivo: o que essa sub-tarefa precisa produzir.
Retorno: conclusão em uma frase, evidências com arquivo ou recurso, e o que ficou em aberto.
Domínio: o que essa sub-tarefa pode escrever. Nesta etapa, nenhum.
Exclusão: o que ela não cobre, porque é de outra.
Momento: com quem ela corre junto e quem ela espera.

Antes de delegar, me apresente o plano de decomposição. Não delegue nada até eu confirmar.

Não aplique nenhuma correção nesta etapa.
```

```text
# Prompt de correção orquestrada
Diagnóstico confirmado. Agora a correção.

Mesmo papel: você coordena e não executa, e isso vale para leitura também. Não abra arquivo, não rode comando e não consulte o cluster por conta própria. Toda investigação e toda escrita acontecem dentro de uma sub-tarefa, e a escrita com Domínio declarado.

São duas mudanças, em camadas diferentes, e elas não disputam arquivo. O que é sequencial é a validação: ela só acontece depois da imagem nova e do rollout.

Aplique a mesma estrutura de sub-briefing. Os Domínios não podem se sobrepor.

Se alguma das mudanças não puder ser feita por nenhum agente disponível, pare e me diga qual e por quê, em vez de fazer você mesmo.

Me apresente o plano antes de executar.
```

## Pegadinhas

- Decompor por **sintoma** (em vez de por localidade/subsistema) tende a gerar sub-tarefas que competem pelos mesmos arquivos — o critério certo é separar por modelo mental/conjunto de arquivos que não se sobrepõe.
- Mesmo com sub-tarefas "paralelas" no papel, o orquestrador pode identificar uma dependência real durante a execução (como aconteceu na correção, onde a validação precisou esperar a imagem nova) e se ajustar sozinho — mas vale deixar essa dependência explícita no prompt sempre que for previsível, em vez de confiar que o orquestrador vai improvisar corretamente.
- Proibir explicitamente o orquestrador de ler arquivos/rodar comandos por conta própria é essencial para garantir que ele realmente delegue, em vez de "ajudar" e poluir a própria janela de contexto.
- Pedir que o orquestrador pare e relate quando uma tarefa não puder ser feita por nenhum agente disponível evita que ele mesmo tente executar fora do padrão de delegação estabelecido.

## Dúvidas para revisar

- Vale transformar esse fluxo de orquestração (ORDEM + política de coordenação) em uma skill reutilizável, como o próprio instrutor sugere?
- Como esse padrão se comportaria com 3 ou mais sub-agentes especializados trabalhando em um incidente com mais de dois subsistemas afetados?
- O uso de *worktree* pelo `devops-engineer` para a correção foi uma decisão espontânea do agente — vale formalizar essa prática (trabalho em worktree isolado) como uma regra explícita no System Prompt dos agentes de escrita?
