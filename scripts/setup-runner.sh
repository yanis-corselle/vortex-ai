#!/usr/bin/env bash
# ==============================================================================
# VortexAI - GitHub Actions Self-Hosted Runner Setup for Raspberry Pi 5 (ARM64)
# ==============================================================================
# This script automates downloading, configuring, and installing the GitHub
# Actions Runner as a systemd service on Raspberry Pi OS / Linux ARM64.
# ==============================================================================

set -euo pipefail

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Parse flags or prompts
REPO_URL="${1:-}"
RUNNER_TOKEN="${2:-}"
RUNNER_DIR="${RUNNER_DIR:-$HOME/actions-runner}"
RUNNER_VERSION="${RUNNER_VERSION:-2.321.0}"

if [[ -z "${REPO_URL}" ]] || [[ -z "${RUNNER_TOKEN}" ]]; then
    echo "======================================================================"
    echo "  vortexai - GitHub Actions Self-Hosted Runner Installer"
    echo "======================================================================"
    echo "Usage:"
    echo "  ./scripts/setup-runner.sh <GITHUB_REPO_URL> <RUNNER_REGISTRATION_TOKEN>"
    echo ""
    echo "Example:"
    echo "  ./scripts/setup-runner.sh https://github.com/myuser/vortexai AAABBBCCCDDDEEEFFF"
    echo "======================================================================"
    
    if [[ -t 0 ]]; then
        read -rp "Enter GitHub Repository URL (e.g., https://github.com/user/repo): " REPO_URL
        read -rp "Enter GitHub Runner Token: " RUNNER_TOKEN
    else
        log_error "Missing required arguments: REPO_URL and RUNNER_TOKEN"
        exit 1
    fi
fi

# Ensure Docker is installed and user is in docker group
if ! command -v docker &> /dev/null; then
    log_warn "Docker is not detected. Please make sure Docker is installed on the Pi 5."
fi

if id -nG "$USER" | grep -qw "docker"; then
    log_success "User '$USER' is in the 'docker' group."
else
    log_warn "Adding current user '$USER' to 'docker' group..."
    sudo usermod -aG docker "$USER" || true
    log_warn "You may need to log out and log back in for docker group permissions to take effect."
fi

# Create runner directory
log_info "Creating runner directory at ${RUNNER_DIR}..."
mkdir -p "${RUNNER_DIR}"
cd "${RUNNER_DIR}"

# Download latest ARM64 runner package if not already downloaded
RUNNER_TAR="actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz"
if [[ ! -f "${RUNNER_TAR}" ]]; then
    log_info "Downloading GitHub Actions Runner v${RUNNER_VERSION} for Linux ARM64..."
    curl -o "${RUNNER_TAR}" -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TAR}"
else
    log_info "Runner package ${RUNNER_TAR} already downloaded."
fi

# Extract package
log_info "Extracting runner package..."
tar xzf "./${RUNNER_TAR}"

# Configure runner
log_info "Configuring runner for repository: ${REPO_URL}..."
./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --unattended --replace

# Install and start as a systemd service
log_info "Installing systemd service for GitHub Actions Runner..."
sudo ./svc.sh install "${USER}"
log_info "Starting systemd service..."
sudo ./svc.sh start

# Verify status
log_info "Checking systemd service status..."
sudo ./svc.sh status

log_success "GitHub Actions self-hosted runner setup successfully installed and running as systemd service!"
