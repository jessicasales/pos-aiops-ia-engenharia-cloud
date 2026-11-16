### CHECKPOINT 1 - O primeiro prompt do playbook

Todo playbook começa com um item, e o da Aegis vai nascer de uma dor concreta da SRE. O time do Sam Wilson precisa de uma triagem rápida e confiável da saúde dos pods no cluster onde o Sentinel está hospedado — algo que qualquer plantonista possa rodar e confiar no resultado.

Hoje isso é resolvido no improviso. Alguém joga na IA um pedido solto, mais ou menos assim:
```text
cria um script pra mim que olha os pods do meu cluster kubernetes e me
fala quais estão com problema, tipo reiniciando muito ou sem subir
```
Funciona mais ou menos, mas é vago demais pra virar item de playbook. Em vez de um script descartável, o que você vai construir é um prompt parametrizável que recebe um snapshot do cluster e devolve uma triagem com a causa provável de cada pod problemático. O prompt parte do princípio de que o snapshot foi coletado por quem tem acesso ao cluster — ele recebe o dado pronto na entrada, não vai buscar nada (sem agente, sem tool: o snapshot é colado no prompt).

E pra chegar numa conclusão de verdade, o snapshot não é só a lista de pods: vem com os eventos (kubectl describe) e os logs das aplicações. Três exemplos completos do que o prompt recebe:

Entrada 1 — pod reiniciando:
```bash
$ kubectl get pods -n sentinel-prod
NAME                            READY   STATUS             RESTARTS       AGE
sentinel-api-7d9c8b6f4-2xk9p    1/1     Running            0              6d
sentinel-api-7d9c8b6f4-h4m2t    0/1     CrashLoopBackOff   14 (90s ago)   42m
sentinel-worker-5b8f9c8d-jq7rs  1/1     Running            0              6d
sentinel-scheduler-6c4d7f-nn8vx 1/1     Running            0              6d
$ kubectl describe pod sentinel-api-7d9c8b6f4-h4m2t -n sentinel-prod
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
    Limits:         memory: 512Mi
    Requests:       memory: 256Mi
Events:
  Type     Reason   Age                 From     Message
  ----     ------   ----                ----     -------
  Warning  BackOff  2m (x18 over 40m)   kubelet  Back-off restarting failed container api
$ kubectl logs sentinel-api-7d9c8b6f4-h4m2t -n sentinel-prod --previous
2026-05-13 10:14:02 [INFO]  [api] startup complete, version 2.9.1
2026-05-13 10:14:48 [INFO]  [cache] loading 6h alert cache (heap 410Mi/512Mi)
2026-05-13 10:15:10 [WARN]  [runtime] high GC pressure, heap 498Mi/512Mi
2026-05-13 10:15:12 [FATAL] [runtime] out of memory, shutting down process
```
Entrada 2 — pods que não sobem:
```bash
$ kubectl get pods -n sentinel-prod
NAME                            READY   STATUS             RESTARTS   AGE
sentinel-api-7d9c8b6f4-2xk9p    1/1     Running            0          6d
sentinel-api-7d9c8b6f4-zzp10    0/1     ImagePullBackOff   0          8m
sentinel-ingest-8f7a9c5b-4dkqm  0/1     Pending            0          8m
sentinel-scheduler-6c4d7f-nn8vx 1/1     Running            0          6d
$ kubectl describe pod sentinel-api-7d9c8b6f4-zzp10 -n sentinel-prod
    State:    Waiting
      Reason: ImagePullBackOff
    Image:    registry.aegis.io/sentinel-api:2.9.2
Events:
  Type     Reason   Age   From     Message
  ----     ------   ----  ----     -------
  Warning  Failed   7m    kubelet  Failed to pull image "registry.aegis.io/sentinel-api:2.9.2": manifest unknown
  Warning  Failed   7m    kubelet  Error: ErrImagePull
  Normal   BackOff  6m    kubelet  Back-off pulling image "registry.aegis.io/sentinel-api:2.9.2"
$ kubectl describe pod sentinel-ingest-8f7a9c5b-4dkqm -n sentinel-prod
    State:    Waiting
      Reason: Pending
    Requests: cpu: 2
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  7m    default-scheduler  0/6 nodes are available: 6 Insufficient cpu
```
Entrada 3 — tudo saudável:
```bash
$ kubectl get pods -n sentinel-prod
NAME                            READY   STATUS    RESTARTS     AGE
sentinel-api-7d9c8b6f4-2xk9p    1/1     Running   0            6d
sentinel-api-7d9c8b6f4-h4m2t    1/1     Running   0            6d
sentinel-worker-5b8f9c8d-jq7rs  1/1     Running   1 (3d ago)   6d
sentinel-scheduler-6c4d7f-nn8vx 1/1     Running   0            6d
$ kubectl logs sentinel-api-7d9c8b6f4-2xk9p -n sentinel-prod --tail=3
2026-05-13 11:02:31 [INFO] [api] health check OK, 0 errors in the last 5min
2026-05-13 11:03:31 [INFO] [api] processed 4.2k alerts/min, p99 latency 120ms
2026-05-13 11:04:31 [INFO] [api] health check OK
```
A partir do snapshot recebido, o prompt precisa: apontar os pods em estado problemático; para cada um, chegar à causa provável cruzando o status com os eventos e os logs (não só repetir o STATUS); recomendar a próxima ação do plantão; devolver uma saída legível, e não um dump cru; e reconhecer quando não há nada problemático (o caso da Entrada 3). Como é o primeiro item da biblioteca, é aqui que a estrutura dela começa a tomar forma.

*Tarefa.* Escrever o prompt parametrizável de triagem de pods (use meta-prompting para criá-lo) e executá-lo contra os três exemplos de entrada acima.

*Entregue.* Prompt parametrizável, execução (modelo e output) nos exemplos e curadoria.

---
#### 🤖 Prompt:
```text
# Prompt — Triagem Operacional de Pods Kubernetes

Você é um engenheiro DevOps/SRE sênior especializado em Kubernetes e troubleshooting de workloads em produção.

Sua função é analisar exclusivamente o snapshot de um cluster Kubernetes fornecido na entrada e realizar uma triagem operacional dos pods.

Você não possui acesso ao cluster, não deve executar comandos, consultar ferramentas externas ou solicitar informações adicionais durante a análise.

Todo o diagnóstico deve ser baseado exclusivamente nos dados fornecidos no snapshot.

## Objetivo

A partir do snapshot recebido:

1. Identificar pods em estado potencialmente problemático.
2. Para cada pod problemático, determinar a causa provável, cruzando:
   - estado do pod;
   - `kubectl describe`;
   - Events;
   - requests/limits, quando disponíveis;
   - estado anterior do container;
   - exit code;
   - logs da aplicação;
   - mensagens de erro.
3. Não apenas repetir o valor de `STATUS`.
4. Recomendar a próxima ação operacional do plantão.
5. Diferenciar claramente:
   - fato observado;
   - causa provável;
   - evidência;
   - ação recomendada.
6. Reconhecer explicitamente quando não houver pods problemáticos.
7. Não inventar informações ausentes no snapshot.

## Entrada

O snapshot será fornecido na variável:

{{CLUSTER_SNAPSHOT}}

Ele pode conter, entre outros:

- `kubectl get pods`;
- `kubectl describe pod`;
- Events;
- logs atuais ou `--previous`;
- requests/limits;
- estados dos containers;
- exit codes;
- mensagens do scheduler/kubelet;
- informações adicionais relevantes ao troubleshooting.

## Critérios para identificar problemas

Considere como potencialmente problemático qualquer pod que apresente evidência como:

- `CrashLoopBackOff`;
- `Error`;
- `OOMKilled`;
- `ImagePullBackOff`;
- `ErrImagePull`;
- `Pending`;
- `ContainerCreating` por período relevante, quando houver evidência de problema;
- `CreateContainerError`;
- `RunContainerError`;
- `NotReady`;
- reinícios recorrentes ou anormais;
- falha de readiness/liveness;
- eventos `Warning` relevantes;
- erros explícitos nos logs;
- falha de scheduling;
- outros estados que indiquem indisponibilidade ou degradação.

Um pod `Running` com reinício isolado antigo não deve ser automaticamente classificado como problemático. Avalie contexto, frequência e evidências disponíveis.

Para cada pod suspeito, identifique:

- namespace;
- nome do pod;
- `STATUS`;
- `READY`;
- quantidade de `RESTARTS`;
- idade;
- estado atual do container.

Procure eventos que expliquem diretamente o problema. Dê prioridade a eventos como:

- `FailedScheduling`;
- `Failed`;
- `BackOff`;
- falhas de pull de imagem;
- falhas de mount;
- falhas de probes;
- problemas de recursos;
- erros reportados pelo kubelet.

Quando disponível, analise:

- `Last State`;
- `Reason`;
- `Exit Code`.

Exemplos importantes:

- `OOMKilled` + exit code `137` → forte evidência de encerramento por limite de memória.
- `Error` + exit code diferente de zero → investigar logs e contexto.
- `Completed` → não classificar automaticamente como falha.

## Correlação das evidências

Cruze os logs com o estado e os eventos.

Não considere uma mensagem de log isolada como causa definitiva quando houver evidência mais forte no estado do container ou nos eventos.

Exemplo:

STATUS = CrashLoopBackOff
Last State = OOMKilled
Exit Code = 137
Logs = out of memory


Conclusão:

O processo está excedendo o limite de memória configurado.
A conclusão é baseada no cruzamento das três evidências.
Produza a causa mais provável em linguagem operacional.

Não invente:

- capacidade real dos nodes;
- configuração não apresentada;
- valores históricos;
- comportamento da aplicação não evidenciado;
- causa raiz além do que os dados permitem concluir.

Quando os dados não forem suficientes para determinar a causa, informe:

Causa provável: indeterminada com os dados disponíveis.

Explique também qual evidência está faltando.

Recomende a ação mais apropriada para o plantão, priorizando:

1. mitigação imediata;
2. confirmação do diagnóstico;
3. correção definitiva.

A ação deve ser compatível com as evidências disponíveis.

Não recomende alterações destrutivas ou irreversíveis sem necessidade.

Errado:
Causa: ImagePullBackOff.

Correto:
Causa provável: a imagem `registry...:2.9.2` não pode ser obtida porque o registry retornou `manifest unknown`, indicando que essa tag/imagem não está disponível no registry.

Sempre que possível, relacione:
STATUS → EVENTO → ESTADO/EXIT CODE → LOG → CONCLUSÃO


Priorize, nesta ordem:

1. erro explícito no evento;
2. estado/Reason/Exit Code do container;
3. erro explícito nos logs;
4. `STATUS` do pod;
5. inferências secundárias.

`CrashLoopBackOff` é normalmente o sintoma de que o container está falhando e sendo reiniciado. Procure a razão da falha no `Last State`, exit code, eventos e logs.

Se houver:

FailedScheduling
0/N nodes are available: ... Insufficient cpu

A causa provável é insuficiência de CPU disponível para atender ao request do pod.

Não atribua o problema a memória, node failure ou autoscaling se isso não estiver evidenciado.

Se houver:

manifest unknown


Considere como causa provável que a referência da imagem/tag não está disponível no registry.
Não atribua automaticamente o problema a credenciais, rede ou DNS.
Pods `Running` e `Ready`, sem evidências relevantes de falha, devem ser classificados como saudáveis.
Um restart antigo e isolado não é suficiente, por si só, para declarar o pod problemático.
Se nenhum pod apresentar evidência suficiente de problema, declare explicitamente:

Nenhum pod problemático identificado no snapshot.

## Formato da saída

Produza uma saída resumida e legível.

Status geral: SAUDÁVEL | ATENÇÃO | CRÍTICO
Pods problemáticos: <quantidade>

Depois da tabela, detalhe cada ocorrência:

Diagnóstico:
 <explicação objetiva da causa provável>

Evidências:
- <evidência 1>
- <evidência 2>
- <evidência 3>

Próxima ação do plantão:
 <ação recomendada>

Prioridade: P1 — imediata | P2 — alta | P3 — normal

Não crie uma tabela vazia.

Quando não houver pods problemáticos, retorne:

Status geral: SAUDÁVEL
Pods problemáticos: 0

Conclusão:
 Nenhum pod problemático identificado no snapshot fornecido.

Observações:
 <eventuais reinícios antigos ou outros sinais que mereçam acompanhamento, caso existam>

## Restrições

- Não executar comandos.
- Não utilizar ferramentas.
- Não consultar o cluster.
- Não consultar fontes externas.
- Não inventar dados.
- Não assumir informações que não estejam no snapshot.
- Não tratar todo `Warning` como causa raiz.
- Não tratar todo restart como incidente.
- Não recomendar mudanças de configuração sem relacioná-las às evidências.
- Separar claramente diagnóstico baseado em evidência de hipótese.
- Ser objetivo e adequado para uso durante um plantão.
```
---
#### 🛠️ Modelo - Prompt:
GPT 5.6 Sol Light

---
#### 📦 Output:

##### Exemplo 1 - *Modelo: GPT-5.6 Luna*

>## Resultado da execução
>
>```text
>Status geral: CRÍTICO
>
>Pods problemáticos: 1
>```
>
>| Namespace     | Pod                          | STATUS           | READY | RESTARTS | AGE | Estado atual               | Prioridade    |
>| ------------- | ---------------------------- | ---------------- | ----- | -------- | --- | -------------------------- | ------------- |
>| sentinel-prod | sentinel-api-7d9c8b6f4-h4m2t | CrashLoopBackOff | 0/1   | 14       | 42m | Waiting / CrashLoopBackOff | P1 — imediata |
>
>### Diagnóstico
>
>**Causa provável:** o container `api` está excedendo o limite de memória de **512Mi**, sendo encerrado pelo runtime com `OOMKilled`.
>
>A sequência observada é consistente com:
>
>`CrashLoopBackOff → OOMKilled → Exit Code 137 → pressão de memória nos logs → processo encerrado → BackOff`
>
>### Evidências
>
>* `STATUS = CrashLoopBackOff` e `READY = 0/1`.
>* `Last State = Terminated`, `Reason = OOMKilled`, `Exit Code = 137`.
>* Limite de memória configurado: `512Mi`.
>* Logs mostram crescimento do heap:
>
>  * `410Mi/512Mi` durante o carregamento do cache;
>  * `498Mi/512Mi` com alta pressão de GC;
>  * posteriormente `out of memory, shutting down process`.
>* Evento `BackOff` ocorreu **18 vezes em 40 minutos**, confirmando falhas recorrentes de reinicialização.
>
>### Próxima ação do plantão
>
>**Mitigação imediata:** tratar o pod como indisponível e verificar o impacto da indisponibilidade da API no serviço. O snapshot não fornece dados suficientes para determinar se o outro pod `sentinel-api-7d9c8b6f4-2xk9p` consegue absorver a carga.
>
>**Confirmação:** validar, a partir de dados adicionais do ambiente, se o consumo de memória está efetivamente atingindo o limite e se o carregamento do cache de 6h está relacionado ao crescimento de memória.
>
>**Correção definitiva:** revisar o consumo de memória da aplicação e, com base em medição, avaliar ajuste do `memory limit` e/ou alteração do comportamento de carregamento do cache. **Não é possível determinar pelo snapshot qual desses ajustes é o correto.**
>
>**Prioridade: P1 — imediata**
>
>### Demais pods
>
>Os outros três pods estão `Running`, `READY 1/1` e sem reinícios, sem evidência apresentada de problema:
>
>* `sentinel-api-7d9c8b6f4-2xk9p`
>* `sentinel-worker-5b8f9c8d-jq7rs`
>* `sentinel-scheduler-6c4d7f-nn8vx`
>
>**Conclusão:** há **1 ocorrência crítica**, e a evidência disponível aponta especificamente para **estouro do limite de memória do container da API**, não para falha de node, scheduler, imagem ou rede.

---

##### Exemplo 2 - *Modelo: Gemini Flash 3.6*

>Status geral: CRÍTICO
>Pods problemáticos: 2
>
>| Namespace | Pod | Status | Ready | Restarts | Idade |
>| --- | --- | --- | --- | --- | --- |
>| `sentinel-prod` | `sentinel-api-7d9c8b6f4-zzp10` | `ImagePullBackOff` | `0/1` | 0 | 8m |
>| `sentinel-prod` | `sentinel-ingest-8f7a9c5b-4dkqm` | `Pending` | `0/1` | 0 | 8m |
>
>---
>
>### Detalhamento dos Pods Problemáticos
>
>**Pod:** `sentinel-api-7d9c8b6f4-zzp10` (`sentinel-prod`)
>
>Diagnóstico:
>A imagem `registry.aegis.io/sentinel-api:2.9.2` não pôde ser baixada porque o container registry retornou `manifest unknown`, indicando que a tag ou imagem `2.9.2` não existe ou não está publicada no registry especificado.
>
>Evidências:
>
>* **STATUS / Reason:** `ImagePullBackOff` / Container em estado `Waiting` com a razão `ImagePullBackOff`.
>* **Eventos:** Warning `Failed` do kubelet reportando `Failed to pull image "registry.aegis.io/sentinel-api:2.9.2": manifest unknown`.
>
>Próxima ação do plantão:
>
>1. Verificar no pipeline de CI/CD se o build/push da versão `2.9.2` foi concluído com sucesso no registry `registry.aegis.io`.
>2. Caso a tag esteja incorreta no Deployment, realizar o rollback para a versão funcional anterior (`kubectl rollout undo deployment/sentinel-api -n sentinel-prod`) ou corrigir a tag do container para uma imagem existente.
>
>Prioridade: P1 — imediata
>
>---
>
>**Pod:** `sentinel-ingest-8f7a9c5b-4dkqm` (`sentinel-prod`)
>
>Diagnóstico:
>O Kubernetes Scheduler não conseguiu alocar o pod em nenhum nó do cluster devido à falta de capacidade computacional livre de CPU para suprir o `request` configurado no pod.
>
>Evidências:
>
>* **STATUS / Reason:** `Pending` / Container em estado `Waiting` com a razão `Pending`.
>* **Requests:** `cpu: 2`.
>* **Eventos:** Warning `FailedScheduling` do `default-scheduler` informando `0/6 nodes are available: 6 Insufficient cpu`.
>
>Próxima ação do plantão:
>
>1. Verificar a utilização atual do cluster e checar se há recursos alocados desnecessariamente ou se é necessário acionar o autoscaler/adicionar novos nós ao pool.
>2. Caso o recurso solicitado (`cpu: 2`) esteja sobredimensionado para a aplicação, ajustar a especificação de `requests.cpu` do Deployment para um valor adequado.
>
>Prioridade: P2 — alta

---

##### Exemplo 3 - *Modelo: Claude Sonnet 5*

>Status geral: SAUDÁVEL
>Pods problemáticos: 0
>
>Conclusão:
> Nenhum pod problemático identificado no snapshot fornecido. Todos os pods do namespace `sentinel-prod` estão `Running` com `READY 1/1`, e os logs de `sentinel-api-7d9c8b6f4-2xk9p` mostram health checks OK e operação normal (processamento de alertas, latência p99 de 120ms), sem erros.
>
>Observações:
> O pod `sentinel-worker-5b8f9c8d-jq7rs` apresenta 1 restart, ocorrido há 3 dias, mas está atualmente `Running` e `Ready` (1/1). Trata-se de um restart isolado e antigo, sem recorrência nem evidência adicional (eventos, exit code, logs) que o correlacione a um problema em curso — não há dados suficientes no snapshot para determinar a causa desse restart. Recomenda-se apenas acompanhamento passivo: caso o restart se repita, valer verificar `kubectl describe pod` (Last State/Exit Code) e eventos para investigar a causa raiz.