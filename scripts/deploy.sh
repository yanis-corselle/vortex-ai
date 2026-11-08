#!/usr/bin/env bash
# ==============================================================================
# Vortexai - Manual Deployment Script (Mac -> Raspberry Pi 5)
# ==============================================================================
# Usage: ./deploy.sh [environment]
# Synchronizes repository source files to Raspberry Pi over SSH and restarts
# the Docker Compose stack.
# ==============================================================================

set -euo pipefail

# Color formatting for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# 1. Load local .env if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
    log_warn ".env file not found. Proceeding without local configuration."
fi

# 2. Set default connection options without hardcoding credentials
PI_HOST="${PI_HOST:-192.168.1.152}"
PI_USER="${PI_USER:-yanis}"
PI_DIR="${PI_DIR:-~/vortexai}"
PI_PORT="${PI_PORT:-22}"

log_info "Target Host: ${PI_USER}@${PI_HOST}:${PI_PORT}"
log_info "Target Directory: ${PI_DIR}"

# 3. Pre-flight dependency check
for cmd in ssh rsync; do
    if ! command -v "${cmd}" &> /dev/null; then
        log_error "Required CLI tool '${cmd}' is not installed or not in PATH."
        exit 1
    fi
done

# 4. Check SSH Connectivity
log_info "Testing SSH connection to ${PI_USER}@${PI_HOST}..."
if ! ssh -q -p "${PI_PORT}" -o ConnectTimeout=5 "${PI_USER}@${PI_HOST}" "echo 1" &>/dev/null; then
    log_error "Could not establish SSH connection to ${PI_USER}@${PI_HOST} on port ${PI_PORT}."
    log_error "Please ensure SSH access is configured (e.g. SSH keys added, host reachable)."
    exit 1
fi
log_success "SSH connection established."

# 5. Create remote target directory if it does not exist
log_info "Ensuring remote directory '${PI_DIR}' exists..."
ssh -p "${PI_PORT}" "${PI_USER}@${PI_HOST}" "mkdir -p ${PI_DIR}"

# 6. Synchronize project files using rsync
log_info "Synchronizing project files to Raspberry Pi..."
rsync -avz \
    --exclude='.git/' \
    --exclude='.github/' \
    --exclude='.DS_Store' \
    --exclude='*.log' \
    --exclude='node_modules/' \
    --exclude='tmp/' \
    -e "ssh -p ${PI_PORT}" \
    "${SCRIPT_DIR}/" \
    "${PI_USER}@${PI_HOST}:${PI_DIR}/"

log_success "Code synchronization complete."

# 7. Restart / Deploy Docker Compose containers on the Raspberry Pi
log_info "Deploying Docker Compose stack on Raspberry Pi..."
REMOTE_DEPLOY_CMD="cd ${PI_DIR} && \
if [ ! -f .env ] && [ -f .env.example ]; then \
    echo 'Creating .env from .env.example on remote host...'; \
    cp .env.example .env; \
fi && \
if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ] || [ -f compose.yaml ]; then \
    echo 'Stopping and removing all containers/volumes...'; \
    docker rm -f evolution-db 2>/dev/null || true; \
    docker compose -p vortexai down --volumes --remove-orphans || true; \
    echo 'Starting containers...'; \
    docker compose -p vortexai up -d --remove-orphans; \
    echo 'Current container status:'; \
    docker compose -p vortexai ps; \
else \
    echo 'No docker-compose file found in ${PI_DIR}. Skipping docker compose up.'; \
fi"

ssh -p "${PI_PORT}" "${PI_USER}@${PI_HOST}" "${REMOTE_DEPLOY_CMD}"

log_success "Deployment completed successfully! 🎉"
