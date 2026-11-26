# Checkpoint 06 — Endurecendo a NetworkPolicy do Sentinel

## O Problema

A Natasha Romanoff barrou um manifesto de NetworkPolicy que ia subir pro namespace do Sentinel:
- **Estava permissivo demais**
- **Um erro ali expõe o produto core**

> 💡 **NetworkPolicy** é a regra de rede do Kubernetes — define quem pode falar com quem
> - **Ingress** = o que pode entrar nos pods
> - **Egress** = para onde eles podem sair
> - **default-deny** = bloquear tudo por padrão, liberar só o necessário

Antes de virar item do playbook, esse tipo de artefato crítico precisa passar por **verificação e refino** — não pode sair na primeira tentativa.

## O Manifesto Barrado

Este é o manifesto que a Natasha barrou. Repara que ele libera tudo:

# manifesto barrado pela revisão de segurança — permissivo demais
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-allow
  namespace: sentinel-prod
spec:
  podSelector: {}          # aplica a todos os pods do namespace
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - {}                   # libera QUALQUER origem
  egress:
    - {}                   # libera QUALQUER destino
```

### Problema Óbvio

- `podSelector: {}` pega **todos os pods do namespace**
- Regras `- {}` liberam **qualquer entrada e qualquer saída**
- É um **allow-all disfarçado de política**

---

## Padrão da Aegis

A versão corrigida precisa seguir estes requisitos:

### NetworkPolicy para "sentinel-prod"

✓ Pods do Sentinel só aceitam tráfego de entrada do:
  - Relay (consumo de eventos)
  - Gateway de API da plataforma

✓ Pods do Sentinel só fazem saída para:
  - Forge (warehouse, porta 5432)
  - Cerebro (busca, porta 9200)
  - DNS interno

✓ Nada de "allow all" em ingress ou egress  
✓ Política `default-deny` explícita no namespace  
✓ Toda regra com comentário explicando o fluxo legítimo

### Mapa de Serviços

| Serviço | Namespace | Label | Porta |
|---------|-----------|-------|-------|
| Sentinel | `sentinel-prod` | `app=sentinel` | — |
| Relay | `relay-prod` | `app=relay` | — |
| API gateway | `edge` | `app=api-gateway` | — |
| Forge | `forge-prod` | `app=forge` | 5432 (Postgres) |
| Cerebro | `cerebro-prod` | `app=cerebro` | 9200 (Elasticsearch) |
| DNS interno | `kube-system` | `k8s-app=kube-dns` | 53 |

---

## A Tarefa: Verificação e Refino Iterativo

Você vai construir um prompt parametrizável que:
1. Recebe um manifesto permissivo (mais as regras + mapa de serviços)
2. Devolve a versão **corrigida e endurecida**
3. Passa por um processo de **verificação e refino dirigido por você**

A IA vai:
- Criticar a própria saída
- Levantar perguntas que um revisor de segurança faria
- Melhorar a versão a cada rodada

**Registra as iterações:** v1 → verificação → v2 → verificação → v3...  
Essas iterações são **parte do valor da entrega**.

---

## Tarefa

**Escrever o prompt parametrizável** (use meta-prompting) **que recebe o manifesto permissivo + regras + mapa de serviços** e **conduzir a verificação e refino**.

## Entregáveis

- Prompt parametrizável
- Execução com as iterações (v1 → verificação → v2 → …)
- Curadoria