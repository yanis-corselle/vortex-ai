# VortexAI - DevOps & Automation Stack

Self-hosted AI assistant, DevOps automation, and monitoring ecosystem running on Raspberry Pi 5 (ARM64).

---

## 🚀 Quick Start & Deployment

### 1. Manual Deployment from Mac (`deploy.sh`)

For rapid development and manual testing without committing to Git:

```bash
# Optional: create a local .env file with your Pi connection details
cp .env.example .env

# Run deployment script
./scripts/deploy.sh
```

The script will:
1. Read target connection options (`PI_HOST`, `PI_USER`, `PI_PORT`, `PI_DIR`) from environment/`.env`.
2. Perform pre-flight SSH and tool checks.
3. Synchronize code via `rsync` over SSH.
4. Execute `docker compose up -d` on the Raspberry Pi 5.

---

### 2. GitOps Automated Deployment (GitHub Actions)

A self-hosted GitHub Actions runner on the Raspberry Pi 5 automatically deploys changes on every push to `main`.

- **Workflow File**: `.github/workflows/deploy.yml`
- **Runner Setup**: Follow the detailed guide in [docs/RUNNER_SETUP.md](docs/RUNNER_SETUP.md) or execute:

```bash
./scripts/setup-runner.sh "https://github.com/YOUR_USER/vortexai" "YOUR_REGISTRATION_TOKEN"
```

---

## 📁 Repository Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitOps deployment pipeline
├── docs/
│   └── RUNNER_SETUP.md         # GitHub Actions self-hosted runner guide
├── scripts/
│   └── setup-runner.sh         # Self-hosted runner installation script
├── .clinerules                 # Guidelines and stack rules
├── .env.example                # Environment variables template
├── deploy.sh                   # SSH manual deployment script
└── docker-compose.yml          # Container orchestration stack
```
