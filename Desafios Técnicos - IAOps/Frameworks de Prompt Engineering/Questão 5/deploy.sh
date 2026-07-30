#!/bin/bash

# Script de Deploy da Chronos API
# Uso: ./deploy.sh [namespace] [image-tag] [--dry-run]

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações padrão
NAMESPACE=${1:-production}
IMAGE_TAG=${2:-v1.2.3}
DRY_RUN=${3:-}
DEPLOYMENT_NAME="chronos-api"
SERVICE_NAME="chronos-api"
TIMEOUT=300

# Funções de utilidade
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*"
}

# 1. Validação de pré-requisitos
check_prerequisites() {
    log_info "Validando pré-requisitos..."
    
    # Verificar kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl não encontrado. Instale kubectl primeiro."
        exit 1
    fi
    
    # Verificar conexão com cluster
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Não foi possível conectar ao cluster Kubernetes"
        exit 1
    fi
    
    # Verificar se namespace existe
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_warn "Namespace '$NAMESPACE' não existe. Criando..."
        kubectl create namespace "$NAMESPACE"
        log_success "Namespace criado"
    fi
    
    log_success "Pré-requisitos validados"
}

# 2. Validação de Secrets
check_secrets() {
    log_info "Verificando Secrets..."
    
    if ! kubectl get secret chronos-api-secrets -n "$NAMESPACE" &> /dev/null; then
        log_error "Secret 'chronos-api-secrets' não encontrado em namespace '$NAMESPACE'"
        log_info "Crie o secret com:"
        log_info "  kubectl create secret generic chronos-api-secrets \\"
        log_info "    --from-literal=db-password=<seu-valor> \\"
        log_info "    --from-literal=jwt-secret=<seu-valor> \\"
        log_info "    --from-literal=api-key=<seu-valor> \\"
        log_info "    -n $NAMESPACE"
        exit 1
    fi
    
    log_success "Secrets encontrados"
}

# 3. Validação de ConfigMaps
check_configmaps() {
    log_info "Verificando ConfigMaps..."
    
    if ! kubectl get configmap chronos-api-config -n "$NAMESPACE" &> /dev/null; then
        log_warn "ConfigMap 'chronos-api-config' não encontrado"
        log_info "Aplicando ConfigMap padrão..."
        kubectl apply -f secrets-and-config.yaml
    fi
    
    log_success "ConfigMaps validados"
}

# 4. Validação YAML
validate_manifests() {
    log_info "Validando manifests YAML..."
    
    kubectl apply -f deployment.yaml --dry-run=client -o yaml > /dev/null 2>&1 || {
        log_error "Erro ao validar deployment.yaml"
        exit 1
    }
    
    log_success "Manifests válidos"
}

# 5. Deploy
deploy() {
    log_info "Iniciando deployment da imagem $IMAGE_TAG para namespace '$NAMESPACE'"
    
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_warn "DRY RUN ativado - nenhuma mudança será feita"
        kubectl apply -f deployment.yaml -n "$NAMESPACE" --dry-run=client
        return
    fi
    
    # Aplicar manifests
    kubectl apply -f deployment.yaml -n "$NAMESPACE"
    log_success "Manifests aplicados"
    
    # Atualizar imagem (se tag fornecida diferente)
    if [ "$IMAGE_TAG" != "latest" ]; then
        log_info "Atualizando imagem para $IMAGE_TAG..."
        kubectl set image deployment/$DEPLOYMENT_NAME \
            api=chronos-api:$IMAGE_TAG \
            -n "$NAMESPACE" \
            --record
        log_success "Imagem atualizada"
    fi
}

# 6. Esperar rollout
wait_for_rollout() {
    log_info "Aguardando rollout completar (timeout: ${TIMEOUT}s)..."
    
    if kubectl rollout status deployment/$DEPLOYMENT_NAME \
        -n "$NAMESPACE" \
        --timeout="${TIMEOUT}s"; then
        log_success "Rollout completado com sucesso"
        return 0
    else
        log_error "Rollout falhou ou timeout"
        return 1
    fi
}

# 7. Validação pós-deploy
post_deployment_checks() {
    log_info "Executando verificações pós-deployment..."
    
    # Verificar replicas
    local ready_replicas=$(kubectl get deployment $DEPLOYMENT_NAME -n "$NAMESPACE" \
        -o jsonpath='{.status.readyReplicas}')
    local desired_replicas=$(kubectl get deployment $DEPLOYMENT_NAME -n "$NAMESPACE" \
        -o jsonpath='{.spec.replicas}')
    
    log_info "Replicas: $ready_replicas/$desired_replicas"
    
    if [ "$ready_replicas" == "$desired_replicas" ]; then
        log_success "Todas as replicas estão prontas"
    else
        log_error "Nem todas as replicas estão prontas"
        return 1
    fi
    
    # Verificar CPU/Memory requests
    log_info "Verificando recursos..."
    kubectl top pod -n "$NAMESPACE" -l app=$DEPLOYMENT_NAME 2>/dev/null || \
        log_warn "Metrics não disponíveis (metrics-server não instalado?)"
    
    # Listar pods
    log_info "Pods em execução:"
    kubectl get pods -n "$NAMESPACE" -l app=$DEPLOYMENT_NAME \
        -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,READY:.status.conditions[?(@.type==\"Ready\")].status
    
    log_success "Verificações pós-deployment completadas"
}

# 8. Teste de health check
health_check_test() {
    log_info "Testando health checks..."
    
    # Port-forward
    local pod_name=$(kubectl get pods -n "$NAMESPACE" -l app=$DEPLOYMENT_NAME \
        -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$pod_name" ]; then
        log_error "Nenhum pod encontrado"
        return 1
    fi
    
    log_info "Pod selecionado: $pod_name"
    
    # Testar liveness probe
    log_info "Testando liveness probe (/health/live)..."
    kubectl exec -it "$pod_name" -n "$NAMESPACE" -- \
        curl -f http://localhost:8080/health/live &>/dev/null && \
        log_success "Liveness probe OK" || \
        log_warn "Liveness probe falhou"
    
    # Testar readiness probe
    log_info "Testando readiness probe (/health/ready)..."
    kubectl exec -it "$pod_name" -n "$NAMESPACE" -- \
        curl -f http://localhost:8080/health/ready &>/dev/null && \
        log_success "Readiness probe OK" || \
        log_warn "Readiness probe falhou"
}

# 9. Resumo
print_summary() {
    log_info "========================================"
    log_success "DEPLOYMENT COMPLETADO COM SUCESSO"
    log_info "========================================"
    echo ""
    log_info "Informações do Deployment:"
    log_info "  Namespace: $NAMESPACE"
    log_info "  Deployment: $DEPLOYMENT_NAME"
    log_info "  Imagem: chronos-api:$IMAGE_TAG"
    log_info "  Replicas: $(kubectl get deployment $DEPLOYMENT_NAME -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')"
    echo ""
    log_info "Comandos úteis:"
    log_info "  Ver logs: kubectl logs -f deployment/$DEPLOYMENT_NAME -n $NAMESPACE"
    log_info "  Ver status: kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE"
    log_info "  Port-forward: kubectl port-forward svc/$SERVICE_NAME 8080:80 -n $NAMESPACE"
    log_info "  Descrição: kubectl describe deployment $DEPLOYMENT_NAME -n $NAMESPACE"
    echo ""
}

# 10. Rollback em caso de erro
rollback() {
    log_warn "Executando rollback..."
    kubectl rollout undo deployment/$DEPLOYMENT_NAME -n "$NAMESPACE"
    log_warn "Rollback completado. Verificar status com:"
    log_info "  kubectl rollout status deployment/$DEPLOYMENT_NAME -n $NAMESPACE"
}

# Main
main() {
    log_info "========================================"
    log_info "Chronos API - Script de Deploy"
    log_info "========================================"
    echo ""
    
    check_prerequisites
    check_secrets
    check_configmaps
    validate_manifests
    
    deploy
    
    if [ "$DRY_RUN" == "--dry-run" ]; then
        log_warn "Dry-run concluído. Remova a flag --dry-run para fazer deploy real."
        return
    fi
    
    if wait_for_rollout; then
        post_deployment_checks
        health_check_test || true
        print_summary
    else
        log_error "Deployment falhou"
        read -p "Deseja fazer rollback? (s/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            rollback
        fi
        exit 1
    fi
}

# Executar
main "$@"
