# SDD K8S

| Campo | Valor |
|---|---|
| **Curso** | Pós AIOps e IA na Engenharia de Cloud |
| **Módulo** | Agentes de Codificação e SDD |
| **Capítulo** | Spec Driven Development |
| **Aula** | 14 — SDD K8S (35:14) |
| **Assunto** | Aplicação do ciclo completo do opsx para criar o manifesto Kubernetes da aplicação, reaproveitando o mesmo fluxo da aula anterior |
| **Data** | 29/10/2026 15:20 |
| **Tags** | opsx, openspec, kubernetes, kind, explore, propose, apply, archive, harness |

## Resumo da aula

Com o Docker já funcionando (aula anterior), o instrutor dá o próximo passo rumo a produção: criar o manifesto Kubernetes. Reaplica o mesmo ciclo `explore → propose → apply → sync → archive` do opsx, desta vez mostrando com mais detalhe os ajustes finos que precisam ser feitos durante o processo — incluindo um momento em que a IA altera um arquivo fora do escopo esperado (o `docker-compose.yml` diretamente) e precisa ser corrigida para refletir a mudança apenas via especificação. A aula termina com o deploy testado tanto localmente (Docker Compose) quanto em um cluster Kubernetes local criado com Kind.

## Conceitos principais

### Explore — levantamento interativo do manifesto K8s

O instrutor roda `/opsx:explore` pedindo "implementar a criação do manifesto Kubernetes para a aplicação" (sem precisar apontar manualmente para o TRD — o agente já busca PRD/TRD automaticamente no projeto). Decisões tomadas durante a conversa interativa:

- Banco de dados: `Deployment` simples, **sem PVC** por enquanto (uma versão mais avançada, provisionando o ambiente via IA em cloud, ficará para depois).
- Rota de health/readiness: como ainda não existe endpoint de health check, usar o path raiz (`/`) temporariamente.
- Empacotamento: YAML puro (alternativas descartadas: Kustomize, Helm Chart).
- Objetivo da etapa: levantar o escopo para depois usar nas propostas do OpenSpec (não implementar ainda).
- Um único arquivo YAML dentro da pasta `k8s/` (boas práticas do Kubernetes, recursos separados por `---` na ordem: ConfigMap, Secret, ConfigMap do Postgres, Secret, Deployment, Service).
- Service da aplicação: **LoadBalancer** (não ClusterIP), para acesso externo; o Postgres continua interno.
- Imagem: Docker Hub, namespace próprio (`encontros-tech`).

### Propose — adicionando critérios de teste

Ao rodar `/opsx:propose`, o instrutor usa dictation (Super Whisper) para adicionar um critério extra: a lista de tarefas deve terminar com um teste final do manifesto usando a ferramenta **Kind** (Kubernetes in Docker), já instalada na máquina, garantindo que a aplicação funciona corretamente no ambiente Kubernetes. O agente cria a change `add-k8s-manifest` com os 4 artefatos (proposal, spec, design, tasks) — como é um escopo pequeno, cria apenas uma spec com todos os requisitos/cenários.

### Incidente: a IA sai do escopo (alteração direta do Docker Compose)

Ao pedir para trocar o nome da imagem Docker tanto no manifesto quanto no `docker-compose.yml`, o agente **editou diretamente o arquivo real** do Compose, em vez de refletir a mudança na especificação do OpenSpec. O instrutor corrigiu isso explicitamente: "não altere diretamente o arquivo docker-compose; quero que toda a implementação seja feita pela especificação que está sendo criada para o OpenSpec." O agente deu rollback e passou a capturar a mudança como uma nova Spec Delta (alteração da capability existente "empacotamento com Docker") dentro da própria change.

Esse episódio expôs outro detalhe: o agente esqueceu de atualizar o `proposal.md` para refletir que agora também altera a capability de Docker (só criava a nova capability do Kubernetes) — o instrutor precisou apontar o erro de design manualmente. Lição destacada: trabalhar sem um harness ajustado deixa o fluxo "meio descontrolado" — pequenos ajustes de comportamento feitos "em cima da hora" não ficam documentados corretamente na spec/capability, e isso se acumula em projetos com muitas alterações (50, 100 changes). A aula adianta que ajustes no harness serão abordados em aulas futuras para evitar esse tipo de comportamento.

### Ajuste final: dois grupos de teste

O instrutor também pede para adicionar, no `tasks.md`, um teste específico para a alteração do Docker Compose, além do teste com Kubernetes — resultando em dois grupos de teste separados (Docker Compose e cluster Kubernetes), já que um pode passar e o outro não.

### Apply — execução com Sonnet

Trocando para o Sonnet (mais barato, usado na fase de codificação), o instrutor roda `/opsx:apply`. O agente executa as tarefas, cria o manifesto YAML completo (namespace, ConfigMap, labels, security context, liveness/readiness probes no path raiz, volume para Prometheus, estimativa de resources) e também ajusta o Docker Compose. Observação lateral: o agente encontrou um bug propositalmente deixado no endpoint de criação de eventos (usado em outras aulas) e, como instruído, não o corrigiu.

### Testes manuais

1. **Docker Compose**: `docker compose up -d --build`, acesso em `localhost:8000`, validação funcional.
2. **Kubernetes (Kind)**: criação do cluster (`kind create cluster`), build e push da imagem via Docker Compose, `kubectl apply -f k8s/encontros-tech...`, verificação com `kubectl get all -n encontros-tech`, troubleshooting de pods (banco de dados demorando a ficar disponível), `kubectl logs` para diagnosticar, e acesso via `kubectl port-forward` (já que o Kind não fornece IP externo real para o LoadBalancer).

### Archive com sincronização embutida

Ao rodar `/opsx:archive` sem ter feito o `/opsx:sync` antes, o próprio comando detecta Spec Deltas pendentes ("delta specs found") e pergunta se o usuário quer sincronizar agora ou arquivar sem sincronizar. O instrutor opta por sincronizar na hora — mostrando que é possível pedir no mesmo prompt para fazer sync e depois archive. Ao final, a change sai de `changes/` para `archive/`, e as capabilities ficam todas sincronizadas na spec consolidada, sem nenhuma change pendente.

### Observação de encerramento

O instrutor reforça: nem toda implementação precisa partir de um PRD — é possível evoluir o projeto a partir de requisitos técnicos (como foi o caso do Docker e do Kubernetes). A partir da próxima aula, o foco volta a ser a implementação de features via PRDs, mas antes disso o curso fará ajustes no comportamento do OpenSpec (harness).

## Comandos e configurações

```
/opsx:explore
Implementar a criação do manifesto Kubernetes para a aplicação.

/opsx:propose
# critério de teste adicionado via dictation:
# "Na lista de tarefas, preciso que tenha no final a tarefa final de testes
#  desse manifesto para garantir o funcionamento da aplicação no ambiente
#  Kubernetes. Para a criação desse ambiente de testes, utilize a
#  ferramenta Kind já instalada aqui na minha máquina e garanta que a
#  aplicação é executada nesse ambiente Kubernetes e funciona corretamente."

# correção de comportamento indesejado:
"Não altere diretamente o arquivo docker-compose. Eu quero que toda a
implementação, toda a alteração seja feita pela especificação que está
sendo criada para o OpenSpec."

# ajuste de escopo de testes:
"Considere no arquivo tasks.md adicionar também o teste com alteração do
Docker Compose, fazendo o teste no Docker Compose e depois também com o
Kubernetes."

/opsx:apply
/opsx:archive   # detecta deltas pendentes e oferece sincronizar antes de arquivar

# comandos de infraestrutura usados nos testes
kind create cluster
docker compose build
docker compose push
kubectl apply -f k8s/encontros-tech...
kubectl get all -n encontros-tech
kubectl logs <pod> -n encontros-tech
kubectl get service -n encontros-tech
kubectl port-forward service/app 8080:80 -n encontros-tech
```

## Pegadinhas

- A IA, por padrão, tende a querer criar vários arquivos separados para os manifestos K8s — é preciso pedir explicitamente um único arquivo YAML seguindo boas práticas, se essa for a preferência do time.
- A IA pode executar alterações fora do escopo esperado (editar arquivos reais diretamente em vez de refletir na especificação) — é essencial revisar o que ela faz e corrigir o comportamento explicitamente, nunca assumir que ela vai seguir o fluxo correto sozinha.
- Esquecer de atualizar o `proposal.md` quando uma capability existente também é alterada (não só a nova) é um erro real que a IA pode cometer — o instrutor precisou corrigir manualmente.
- Pequenos ajustes "em cima da hora" na especificação, se não documentados corretamente, podem acumular inconsistências à medida que o projeto cresce (50-100 changes).
- Testar a criação do cluster Kind antes de rodar o fluxo completo evita problemas de configuração do Docker Desktop (o instrutor teve um problema específico de ambiente, não reproduzível necessariamente no ambiente do aluno).
- Em clusters Kind, o Service do tipo LoadBalancer não recebe IP externo real — usar `kubectl port-forward` para testar localmente.

## Dúvidas para revisar

- Quais ajustes específicos de harness serão feitos nas próximas aulas para evitar que a IA altere arquivos fora da especificação?
- Como ficaria o fluxo se, em vez de PVC, o projeto decidisse usar um StatefulSet ou um banco de dados externo provisionado via IaC?
- Vale a pena sempre revisar o `proposal.md` manualmente após qualquer alteração de capability existente, para garantir que o impacto foi documentado corretamente?
