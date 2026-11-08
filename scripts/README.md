# VortexAI - Scripts Directory

This directory contains automation and helper scripts for managing the VortexAI stack.

## Available Scripts

### 1. `deploy.sh`
- **Purpose**: Manual deployment script from Mac to Raspberry Pi 5.
- **Action**: Synchronizes repository files via `rsync` over SSH, creates/updates `.env`, stops and removes old containers/volumes, and runs `docker compose up -d`.
- **Usage**:
  ```bash
  ./scripts/deploy.sh
  ```

### 2. `setup-runner.sh`
- **Purpose**: Automated setup script for the GitHub Actions Self-Hosted Runner on Raspberry Pi 5 (ARM64).
- **Action**: Downloads, extracts, configures the runner, and installs it as a persistent `systemd` background service.
- **Usage**:
  ```bash
  ./scripts/setup-runner.sh "https://github.com/yanis-corselle/vortex-ai" "YOUR_REGISTRATION_TOKEN"
  ```

### 3. `test-stack.sh`
- **Purpose**: Health check and connectivity test script for the deployed VortexAI services.
- **Action**: Tests HTTP reachability against all stack endpoints (FreeLLMAPI, AnythingLLM, n8n, Evolution API).
- **Usage**:
  ```bash
  ./scripts/test-stack.sh [target_ip_or_host]
  ```
