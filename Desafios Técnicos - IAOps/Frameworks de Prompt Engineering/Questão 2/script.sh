#!/usr/bin/env bash
#
# ledger-backup.sh
# Backup diário automatizado do banco de dados Ledger.
# SRE Team - hvt.io
#

# --- Configurações de Erro e Segurança ---
set -o errexit  # Sair imediatamente se um comando falhar
set -o nounset  # Sair se tentar usar uma variável não declarada
set -o pipefail # Captura falhas em qualquer ponto de um pipeline (ex: pg_dump | gzip)

# --- Variáveis de Configuração ---
readonly AWS_REGION="us-east-1"
readonly SECRET_NAME="ledger/prod/backup_user" # Ajuste para o nome exato do seu secret no AWS Secrets Manager
readonly DB_HOST="ledger-db.internal.hvt.io"
readonly DB_PORT="5432"
readonly DB_NAME="ledger_prod"
readonly DB_USER="backup_user"

readonly BACKUP_DIR="/var/backups/ledger"
readonly LOG_FILE="/var/log/ledger-backup.log"
readonly S3_BUCKET="s3://hvt-ledger-backups"
readonly RETENTION_DAYS=30

readonly TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
readonly BACKUP_FILENAME="ledger_prod_${TIMESTAMP}.sql.gz"
readonly LOCAL_BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILENAME}"

# --- Funções de Log e Notificação ---
log() {
    local -r level="$1"
    local -r message="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') [${level}] - ${message}" | tee -a "${LOG_FILE}"
}

log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1" >&2; }

# Função de limpeza automática em caso de sucesso ou falha (Trap)
cleanup() {
    local -r exit_code=$?
    if [[ -f "${LOCAL_BACKUP_PATH}" ]]; then
        log_info "Limpando arquivo temporário local: ${LOCAL_BACKUP_PATH}"
        rm -f "${LOCAL_BACKUP_PATH}"
    fi
    
    if [[ ${exit_code} -eq 0 ]]; then
        log_info "Processo de backup finalizado com SUCESSO."
    else
        log_error "Processo de backup FALHOU com exit code ${exit_code}."
    fi
    exit ${exit_code}
}

# Registra o trap para sempre rodar a função cleanup na saída do script
trap cleanup EXIT

# --- Validações Iniciais ---
log_info "Iniciando rotina de backup..."

# 1. Verifica privilégios de escrita no log e diretório de backup
if [[ ! -w "${BACKUP_DIR}" ]]; then
    log_error "Sem permissão de escrita em ${BACKUP_DIR} ou diretório não existe."
    exit 1
fi

# 2. Verifica dependências de binários
for cmd in pg_dump aws gzip jq; do
    if ! command -v "${cmd}" &> /dev/null; then
        log_error "Dependência obrigatória não encontrada: ${cmd}"
        exit 1
    fi
done

# --- Execução do Fluxo ---

# Step 1: Buscar credenciais no AWS Secrets Manager
log_info "Buscando senha no AWS Secrets Manager..."
if ! SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "${SECRET_NAME}" --region "${AWS_REGION}" --output json 2>> "${LOG_FILE}"); then
    log_error "Falha ao buscar o Secret [${SECRET_NAME}] no Secrets Manager."
    exit 1
fi

# Extrai o password usando jq (ajuste a chave do JSON conforme o seu padrão no AWS Secrets)
PGPASSWORD=$(echo "${SECRET_VALUE}" | jq -r '.SecretString | fromjson | .password')
export PGPASSWORD

if [[ -z "${PGPASSWORD}" || "${PGPASSWORD}" == "null" ]]; then
    log_error "A senha extraída do Secrets Manager está vazia ou é inválida."
    exit 1
fi

# Step 2: Executar o Dump e Compactação
log_info "Executando pg_dump e compactando com gzip..."
# Nota: Usamos gzip -c para direcionar o stream diretamente para o arquivo final de forma performática
if ! pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -F c | gzip > "${LOCAL_BACKUP_PATH}" 2>> "${LOG_FILE}"; then
    log_error "Falha durante a execução do pg_dump ou compactação."
    exit 1
fi

# Valida o tamanho do arquivo gerado
readonly FILE_SIZE=$(du -sh "${LOCAL_BACKUP_PATH}" | cut -f1)
log_info "Dump gerado com sucesso localmente. Tamanho: ${FILE_SIZE}"

# Step 3: Upload para o Amazon S3
log_info "Enviando arquivo para o bucket S3: ${S3_BUCKET}"
if ! aws s3 cp "${LOCAL_BACKUP_PATH}" "${S3_BUCKET}/${BACKUP_FILENAME}" --region "${AWS_REGION}" 2>> "${LOG_FILE}"; then
    log_error "Falha no upload do arquivo para o S3."
    exit 1
fi
log_info "Upload concluído com sucesso."

# Step 4: Aplicação da Política de Retenção (30 dias)
log_info "Aplicando política de retenção de ${RETENTION_DAYS} dias no S3..."
# Define a data limite em formato Epoch para comparação rápida
readonly CUTOFF_DATE=$(date -d "${RETENTION_DAYS} days ago" +%s)

# Lista os objetos do bucket e remove os que possuem LastModified anterior à CUTOFF_DATE
aws s3api list-objects-v2 --bucket "${S3_BUCKET#s3://}" --query 'Contents[?LastModified<`'"$(date -d "@$CUTOFF_DATE" +%Y-%m-%dT%H:%M:%S)"'`].[Key]' --output text | while read -r s3_key; do
    if [[ -n "${s3_key}" && "${s3_key}" != "None" ]]; then
        log_warn "Removendo backup antigo do S3: ${s3_key}"
        aws s3 rm "${S3_BUCKET}/${s3_key}" >> "${LOG_FILE}" 2>&1 || log_error "Falha ao remover ${s3_key}"
    fi
done

log_info "Política de retenção processada."