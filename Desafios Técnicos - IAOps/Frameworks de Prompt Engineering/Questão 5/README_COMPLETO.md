# 🚀 Chronos API - Deployment Kubernetes Enterprise-Ready

**Guia Completo de Transformação: De Deployment Básico para Production Grade**

---

## 📑 Sumário

1. [Visão Geral](#visão-geral)
2. [Comparação Before/After](#comparação-beforeafter)
3. [Deployment Completo](#deployment-completo)
4. [Secrets e ConfigMap](#secrets-e-configmap)
5. [Recursos Avançados](#recursos-avançados)
6. [Guia de Deployment](#guia-de-deployment)
7. [Troubleshooting](#troubleshooting)
8. [Checklist](#checklist)

---

## 🎯 Visão Geral

### O Problema Original

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
spec:
  replicas: 1                    # ❌ SPOF
  selector:
    matchLabels:
      app: chronos-api
  template:
    metadata:
      labels:
        app: chronos-api
    spec:
      containers:
      - name: api
        image: chronos-api:latest # ❌ Impredizível
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          value: "MINHASENHA"     # ❌ Plaintext!
        - name: JWT_SECRET
          value: "hvt-jwt-prod-secret"  # ❌ Inseguro
```

**Problemas Críticos:**
- 🔴 1 réplica = SPOF (Single Point of Failure)
- 🔴 Secrets em plaintext = violação de compliance
- 🔴 Imagem `latest` = não reproduzível
- 🔴 Sem health checks = downtime silencioso
- 🔴 Sem limits = pode causar outage
- 🔴 Rodando como root = risco de segurança
- 🔴 Sem estratégia de atualização = downtime

---

## 📊 Comparação Before/After

### 1. Replicas & Alta Disponibilidade

| Aspecto | Antes | Depois |
|---------|-------|--------|
| **Replicas** | 1 | 3+ |
| **Nós** | Pode estar em 1 nó | Distribuído em nós diferentes |
| **PDB** | ❌ | ✅ Garante mínimo 1 sempre |
| **Uptime** | ~90% | 99.99% |
| **RollingUpdate** | ❌ | ✅ Zero downtime |

**Antes vs Depois:**
```
❌ ANTES:
[Node1]
  [Pod1-chronos]  ← Única réplica, crash = 100% downtime

✅ DEPOIS:
[Node1]            [Node2]            [Node3]
  [Pod1]             [Pod2]             [Pod3]
  
  Se Node1 cai:
  [Node1] ❌         [Node2] ✅         [Node3] ✅
                     Serviço continua com 2/3 pods
```

---

### 2. Segurança: Secrets e Configuração

#### ❌ ANTES (INSEGURO)
```yaml
env:
- name: DB_PASSWORD
  value: "MINHASENHA"
- name: JWT_SECRET
  value: "hvt-jwt-prod-secret"
```

**Vulnerabilidades:**
- Plaintext em Git (commit history = forever)
- Visível em `kubectl get deployment -o yaml`
- Todos os logs mostram a senha
- Não criptografado em etcd
- Violação PCI-DSS, SOC2, HIPAA

#### ✅ DEPOIS (SEGURO)
```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: chronos-api-secrets
      key: db-password
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: chronos-api-secrets
      key: jwt-secret
```

**Benefícios:**
- Secrets armazenados separadamente
- Criptografado em repouso (com --encryption-provider)
- Auditável com RBAC
- Possibilita rotação
- Compliant com padrões de segurança

---

### 3. Imagem Versionada

| Aspecto | latest | v1.2.3 |
|---------|--------|--------|
| **Reproducibilidade** | 0% | 100% |
| **Cache** | Risco | Seguro |
| **Audit Trail** | ❌ | ✅ Git history |
| **Rollback** | Não determinístico | Preciso |
| **CI/CD** | Erro-prone | Confiável |

```yaml
# ❌ ANTES
image: chronos-api:latest

# ✅ DEPOIS
image: chronos-api:v1.2.3
imagePullPolicy: IfNotPresent
```

**Timeline de mudanças:**
```
Git history:
commit abc123 - Deploy v1.2.0
commit def456 - Deploy v1.2.1
commit ghi789 - Deploy v1.2.3 ← Exatamente qual foi deployado

vs

commit abc123 - Deploy latest
commit def456 - Deploy latest  ← Qual "latest" foi? Ninguém sabe!
```

---

### 4. Resource Requests & Limits

```yaml
# ❌ ANTES - Sem controle
containers:
- name: api
  image: chronos-api:latest
  # Pod pode consumir CPU/memória infinita!
  # Pode derrubar todo o cluster

# ✅ DEPOIS - Com guardrails
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 512Mi
```

**Impacto:**

```
Sem Limits:
[Pod1] consome 80% CPU → [Pod2] fica starved → Crashes em cascade

Com Limits:
[Pod1] consome 1000m (seu máximo)
[Pod2] consome 1000m (seu máximo)
[Pod3] consome 1000m (seu máximo)
Cada um respeitando seu espaço → Ninguém crashes
```

**Scheduling:**
```
Nó com 2 CPU, 4Gi RAM:
- Requisições: 250m CPU + 256Mi RAM por pod
- Consegue: ~8 pods em scheduling
- Sem requisições: Scheduler pensa que cabe 20 pods → Crash!
```

---

### 5. Health Checks

#### Sem Probes (❌ ANTES)
```
0s:   Container start
5s:   Container crashed
5s:   Kubernetes não sabe!
30s:  Usuário relata: "Sistema down!"
40s:  Alguém percebe e reinicia manualmente
```

#### Com Probes (✅ DEPOIS)
```
0s:   Container start
10s:  Readiness probe: "Não estou pronto, remove tráfego"
30s:  Liveness probe: "Estou vivo!"
35s:  Crash!
35s:  Readiness: Falha! → Removido do load balancer
45s:  Liveness: Falha 3x → Kubernetes reinicia
50s:  Container novo pronto
Downtime: 15s vs 30min manual!
```

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 2
```

---

### 6. Security Context

#### ❌ ANTES
```yaml
# Roda como root por padrão
# UID: 0 (root)
# Filesystem: read-write
# Capabilities: TODAS
```

**Risco de Exploit:**
```bash
$ whoami
root

$ touch /etc/passwd  # Modificar arquivo crítico
$ iptables -A ...    # Modificar regras de rede
$ modprobe ...       # Carregar kernel module
# Controle total do nó!
```

#### ✅ DEPOIS
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
```

**Mesmo exploit agora:**
```bash
$ whoami
1000

$ touch /etc/passwd
touch: cannot touch '/etc/passwd': Permission denied

$ sudo su
sudo: not found  # Capability CAP_SYS_ADMIN foi dropada

$ ls -la /
# Tudo em read-only!
```

---

### 7. Rolling Updates

#### ❌ ANTES
```
Replica Strategy: Recreate
[Pod1][Pod2][Pod3] → [] → [Pod1-new][Pod2-new][Pod3-new]
                     ↑
              30s DOWNTIME!
```

#### ✅ DEPOIS
```
Strategy: RollingUpdate
maxUnavailable: 0 (nunca fica abaixo de 3)
maxSurge: 1 (máximo 4 pods durante atualização)

[Pod1][Pod2][Pod3]
           ↓
[Pod1][Pod2][Pod3][Pod1-new]  (4 pods, 1 old version)
           ↓
[Pod2][Pod3][Pod1-new][Pod2-new]  (4 pods, 2 old versions)
           ↓
[Pod3][Pod1-new][Pod2-new][Pod3-new]  (4 pods, 3 new versions)
           ↓
[Pod1-new][Pod2-new][Pod3-new]  (3 pods, all new)

Tráfego: NUNCA foi 0, sempre ~3 pods disponíveis
Downtime: 0s
```

---

## 📋 Deployment Completo

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
  labels:
    app: chronos-api
    version: v1
    component: api
  annotations:
    description: "Chronos API - Serviço crítico de gestão de timestamps"
    maintained-by: "platform-team"
spec:
  replicas: 3
  
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  
  selector:
    matchLabels:
      app: chronos-api
  
  template:
    metadata:
      labels:
        app: chronos-api
        version: v1
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    
    spec:
      serviceAccountName: chronos-api
      
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - chronos-api
            topologyKey: kubernetes.io/hostname
      
      terminationGracePeriodSeconds: 30
      
      containers:
      - name: api
        image: chronos-api:v1.2.3
        imagePullPolicy: IfNotPresent
        
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        - name: metrics
          containerPort: 9090
          protocol: TCP
        
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: LOG_LEVEL
          value: "info"
        - name: PORT
          value: "8080"
        
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: chronos-api-secrets
              key: db-password
        
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: chronos-api-secrets
              key: jwt-secret
        
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: chronos-api-secrets
              key: api-key
        
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: chronos-api-config
              key: database-url
        
        - name: REDIS_ENABLED
          valueFrom:
            configMapKeyRef:
              name: chronos-api-config
              key: redis-enabled
        
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 512Mi
        
        livenessProbe:
          httpGet:
            path: /health/live
            port: http
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        
        readinessProbe:
          httpGet:
            path: /health/ready
            port: http
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
          successThreshold: 1
        
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/cache
      
      volumes:
      - name: tmp
        emptyDir:
          sizeLimit: 1Gi
      - name: cache
        emptyDir:
          sizeLimit: 500Mi

---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: chronos-api-pdb
  namespace: production
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: chronos-api

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: chronos-api
  namespace: production
  labels:
    app: chronos-api

---
apiVersion: v1
kind: Service
metadata:
  name: chronos-api
  namespace: production
  labels:
    app: chronos-api
  annotations:
    prometheus.io/scrape: "true"
spec:
  type: ClusterIP
  selector:
    app: chronos-api
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  - name: metrics
    port: 9090
    targetPort: metrics
    protocol: TCP
  sessionAffinity: None
```

---

## 🔐 Secrets e ConfigMap

### Secrets (Dados Sensíveis)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: chronos-api-secrets
  namespace: production
  labels:
    app: chronos-api
type: Opaque
stringData:
  db-password: "seu-db-password-super-seguro-aqui"
  jwt-secret: "seu-jwt-secret-complexo-com-caracteres-especiais"
  api-key: "sua-api-key-segura-aqui"
```

**⚠️ NUNCA commit este arquivo em Git!**

**Como criar Secrets com segurança:**

```bash
# Opção 1: Arquivo local (dev only)
kubectl apply -f secrets-and-config.yaml

# Opção 2: Via CLI (sem arquivo)
kubectl create secret generic chronos-api-secrets \
  --from-literal=db-password=valor-aqui \
  --from-literal=jwt-secret=valor-aqui \
  --from-literal=api-key=valor-aqui \
  -n production

# Opção 3: Sealed Secrets (recomendado para produção)
kubeseal -f secrets.yaml > sealed-secrets.yaml
kubectl apply -f sealed-secrets.yaml

# Opção 4: External Secrets Operator
# Referencia secrets do AWS Secrets Manager, HashiCorp Vault, etc
```

---

### ConfigMap (Configurações)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: chronos-api-config
  namespace: production
  labels:
    app: chronos-api
data:
  database-url: "postgresql://user@postgres.production.svc.cluster.local:5432/chronos"
  redis-enabled: "true"
  cache-ttl: "3600"
  log-format: "json"
  request-timeout-seconds: "30"
  max-connections: "100"
  health-check-interval: "30"
```

---

## 🚀 Recursos Avançados

### 1. Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: chronos-api-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: chronos-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
```

**Como funciona:**
- Monitora CPU e memória dos pods
- Quando CPU atinge 70% → aumenta replicas em 100%
- Quando memória atinge 80% → aumenta replicas
- Scale down é mais lento (stabilization 5min) para evitar oscilação

---

### 2. Network Policy (Isolamento de Rede)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: chronos-api-ingress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: chronos-api
  policyTypes:
  - Ingress
  ingress:
  # Traffic do Ingress Controller
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: chronos-api-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: chronos-api
  policyTypes:
  - Egress
  egress:
  # DNS
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
  # PostgreSQL
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  # Redis
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
  # HTTPS externa
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
```

---

### 3. RBAC (Role-Based Access Control)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: chronos-api-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames: ["chronos-api-secrets"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: chronos-api-rolebinding
  namespace: production
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: chronos-api-role
subjects:
- kind: ServiceAccount
  name: chronos-api
  namespace: production
```

---

### 4. Ingress com TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: chronos-api-ingress
  namespace: production
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.chronos.example.com
    secretName: chronos-api-tls
  rules:
  - host: api.chronos.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: chronos-api
            port:
              name: http
```

---

### 5. Monitoring com Prometheus

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: chronos-api-monitor
  namespace: production
spec:
  selector:
    matchLabels:
      app: chronos-api
  podMetricsEndpoints:
  - port: metrics
    interval: 30s
    path: /metrics

---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: chronos-api-alerts
  namespace: production
spec:
  groups:
  - name: chronos-api
    interval: 30s
    rules:
    - alert: ChronosAPIDeploymentDown
      expr: kube_deployment_status_replicas_available{deployment="chronos-api"} < 2
      for: 5m
      annotations:
        summary: "Chronos API: Menos de 2 replicas disponíveis"
    
    - alert: ChronosAPIHighErrorRate
      expr: |
        (sum(rate(http_requests_total{job="chronos-api",status=~"5.."}[5m])) /
         sum(rate(http_requests_total{job="chronos-api"}[5m]))) > 0.05
      for: 5m
      annotations:
        summary: "Chronos API: Taxa de erro acima de 5%"
    
    - alert: ChronosAPIHighLatency
      expr: |
        histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="chronos-api"}[5m])) by (le)) > 1
      for: 5m
      annotations:
        summary: "Chronos API: P95 latency acima de 1s"
```

---

## 📖 Guia de Deployment

### Passo 1: Preparar Secrets

```bash
# Criar namespace (se não existir)
kubectl create namespace production

# Opção A: Via arquivo (dev only)
kubectl apply -f secrets-and-config.yaml

# Opção B: Via CLI (recomendado)
kubectl create secret generic chronos-api-secrets \
  --from-literal=db-password='seu_valor_aqui' \
  --from-literal=jwt-secret='seu_valor_aqui' \
  --from-literal=api-key='seu_valor_aqui' \
  -n production

# Verificar
kubectl get secret chronos-api-secrets -n production
kubectl describe secret chronos-api-secrets -n production
```

### Passo 2: Aplicar Deployment

```bash
# Validar manifest
kubectl apply -f deployment.yaml --dry-run=client

# Aplicar de verdade
kubectl apply -f deployment.yaml

# Acompanhar rollout
kubectl rollout status deployment/chronos-api -n production -w

# Ver pods
kubectl get pods -n production -l app=chronos-api
```

### Passo 3: Verificar Status

```bash
# Overview
kubectl get deployment chronos-api -n production

# Detalhes
kubectl describe deployment chronos-api -n production

# Eventos
kubectl get events -n production --sort-by='.lastTimestamp'

# Logs
kubectl logs -f deployment/chronos-api -n production
```

### Passo 4: Testar Health Checks

```bash
# Port-forward
kubectl port-forward svc/chronos-api 8080:80 -n production

# Em outro terminal
curl http://localhost:8080/health/live   # Liveness
curl http://localhost:8080/health/ready  # Readiness
```

### Passo 5: Aplicar Recursos Avançados (Opcional)

```bash
# HPA, Network Policies, RBAC, Ingress, etc
kubectl apply -f advanced-resources.yaml
```

---

## 🛠️ Troubleshooting

### Problema 1: Pod em CrashLoopBackOff

```bash
# Ver logs
kubectl logs pod/chronos-api-xxx -n production

# Ver logs anteriores
kubectl logs pod/chronos-api-xxx -n production --previous

# Descrição detalhada
kubectl describe pod chronos-api-xxx -n production
```

**Causas comuns:**
- Secret/ConfigMap não encontrados
- Porta 8080 já em uso
- Database não acessível
- Memória insuficiente (OOMKilled)

---

### Problema 2: Pod em Pending

```bash
# Diagnosticar
kubectl describe pod chronos-api-xxx -n production

# Checklist:
# 1. Recursos suficientes no cluster?
kubectl top nodes

# 2. Pod anti-affinity pode ser satisfeita?
kubectl get nodes

# 3. Taints no nó?
kubectl describe node <node-name> | grep Taint
```

---

### Problema 3: Tráfego não Chegando ao Pod

```bash
# Verificar endpoints
kubectl get endpoints chronos-api -n production

# Verificar readiness
kubectl get pod chronos-api-xxx -n production -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'

# Testar conectividade
kubectl exec -it [outro-pod] -n production -- curl http://chronos-api:80
```

---

### Problema 4: Alto Uso de CPU/Memória

```bash
# Ver uso atual
kubectl top pods -n production -l app=chronos-api

# Ver limites
kubectl get pod -n production -o json | \
  jq '.items[] | {name: .metadata.name, limits: .spec.containers[].resources.limits}'

# Aumentar limits
kubectl set resources deployment/chronos-api \
  --limits=cpu=2000m,memory=1Gi \
  -n production --record
```

---

## 📋 Checklist de Deployment

### Antes do Deploy

- [ ] Secrets criados com valores corretos
- [ ] ConfigMap com URLs corretas
- [ ] Imagem versionada disponível em registry
- [ ] Namespace existe
- [ ] Dockerfile tem health check endpoints

### Durante o Deploy

- [ ] `kubectl apply -f deployment.yaml` executado
- [ ] `kubectl rollout status` monitorado
- [ ] Sem erros de ImagePull
- [ ] Pods transitando de Pending → Running
- [ ] Readiness probes passando

### Depois do Deploy

- [ ] Todas as replicas em Running e Ready
- [ ] Port-forward testado
- [ ] Health endpoints respondendo
- [ ] Logs sem erros
- [ ] Métricas sendo coletadas (Prometheus)
- [ ] Alertas configurados

---

## 🎯 Resumo de Melhorias

| Melhoria | Antes | Depois | Ganho |
|----------|-------|--------|-------|
| Replicas | 1 | 3+ | 99.99% uptime |
| Segurança Secrets | Plaintext | Encrypted | ✅ Compliant |
| Imagem | latest | v1.2.3 | 100% reproducível |
| Health Checks | ❌ | ✅ Liveness + Readiness | Auto-healing |
| Resource Control | Nenhum | Requests + Limits | Previsível |
| Shutdown | Immediate | Graceful 30s | Zero errors |
| Security Context | root | 1000 (non-root) | Seguro |
| Updates | Recreate (30s down) | Rolling (0 down) | Zero downtime |
| Auto-scaling | Manual | HPA automática | Hands-free |
| Network | Aberto | Policies + RBAC | Isolado |

---

## 🚀 Próximos Passos

1. **Sealed Secrets** para GitOps
2. **HPA** para auto-scaling automático
3. **Network Policies** para isolamento
4. **Monitoring** com Prometheus + Grafana
5. **Ingress + TLS** para produção
6. **Backup** automático de dados
7. **Disaster Recovery** procedures

---

## 📚 Referências

- [Kubernetes Deployment Docs](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Health Checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Pod Disruption Budgets](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)

---

**Gerado com ❤️ para Production-Grade Kubernetes Deployments**
