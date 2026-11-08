#!/usr/bin/env bash
# ==============================================================================
# VortexAI - Stack Health & Connectivity Test Script
# ==============================================================================
# Usage: ./scripts/test-stack.sh [target_ip_or_host]
# Tests HTTP endpoints and connectivity for all services in the VortexAI stack.
# ==============================================================================

set -euo pipefail

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Load .env if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

if [[ -f "${ENV_FILE}" ]]; then
    set -o allexport
    source "${ENV_FILE}"
    set +o allexport
fi

TARGET_HOST="${1:-${PI_HOST:-192.168.1.152}}"
log_info "Testing VortexAI stack services on target host: ${TARGET_HOST}"

services=(
    "FreeLLMAPI (AI Router)|http://${TARGET_HOST}:3001"
    "AnythingLLM (Knowledge/RAG)|http://${TARGET_HOST}:3000"
    "n8n (Automation Engine)|http://${TARGET_HOST}:5678"
    "Evolution API (WhatsApp Gateway)|http://${TARGET_HOST}:8080"
)

failed=0

for item in "${services[@]}"; do
    name="${item%%|*}"
    url="${item#*|}"
    
    log_info "Checking ${name} at ${url}..."
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "${url}" | grep -qE "^[2345]"; then
        log_success "${name} is reachable!"
    else
        log_error "${name} did not respond at ${url}."
        failed=$((failed + 1))
    fi
done

if [[ ${failed} -eq 0 ]]; then
    log_success "All VortexAI stack services are up and responding successfully! 🚀"
    exit 0
else
    log_error "${failed} service(s) failed health checks."
    exit 1
fi
