# Checkpoint 01 — O primeiro prompt do playbook

## O Problema

Todo playbook começa com um item, e o da Aegis vai nascer de uma dor concreta da SRE. 

O time do Sam Wilson precisa de uma **triagem rápida e confiável da saúde dos pods** no cluster onde o Sentinel está hospedado — algo que qualquer plantonista possa rodar e confiar no resultado.

Hoje isso é resolvido no improviso. Alguém joga na IA um pedido solto, mais ou menos assim:

> cria um script pra mim que olha os pods do meu cluster kubernetes e me fala quais estão com problema, tipo reiniciando muito ou sem subir

Funciona mais ou menos, mas é vago demais para virar item de playbook.

## A Solução

Em vez de um script descartável, você vai construir um **prompt parametrizável** que:
- Recebe um **snapshot do cluster** como entrada
- Devolve uma **triagem com a causa provável** de cada pod problemático

O prompt parte do princípio de que o snapshot foi coletado por quem tem acesso ao cluster — ele recebe o dado pronto na entrada, não vai buscar nada (sem agente, sem tool: o snapshot é colado no prompt).

## Composição do Snapshot

Para chegar numa conclusão de verdade, o snapshot não é só a lista de pods: **vem com eventos** (`kubectl describe`) e **logs das aplicações**.

Três exemplos completos do que o prompt recebe:

### Entrada 1 — Pod reiniciando

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

### Entrada 2 — Pods que não sobem

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

### Entrada 3 — Tudo saudável

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

## Requisitos do Prompt

A partir do snapshot recebido, o prompt precisa:

✓ Apontar os pods em estado problemático  
✓ Para cada um, chegar à **causa provável** cruzando status com eventos e logs (não só repetir o STATUS)  
✓ Recomendar a **próxima ação do plantão**  
✓ Devolver uma **saída legível**, não um dump cru  
✓ Reconhecer quando **não há nada problemático** (caso da Entrada 3)  

Como é o primeiro item da biblioteca, é aqui que a estrutura dela começa a tomar forma.

---

## Tarefa

**Escrever o prompt parametrizável de triagem de pods** (use meta-prompting para criá-lo) e **executá-lo contra os três exemplos acima**.

## Entregáveis

- Prompt parametrizável
- Execução (modelo e output) nos exemplos
- Curadoria