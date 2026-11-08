# VortexAI - Self-Hosted Personal Assistant, AI Routing & Automation Stack

Self-hosted AI assistant, routing proxy (FreeLLMAPI), knowledge management (AnythingLLM), workflow automation (n8n), and WhatsApp gateway (Evolution API) ecosystem running on Raspberry Pi 5 (ARM64).

---

## 🚀 Quick Start & Deployment

### 1. Manual Deployment from Mac (`scripts/deploy.sh`)

For rapid development and manual testing without committing to Git:

```bash
# Run deployment script
./scripts/deploy.sh
```

The script will:
1. Read target connection options (`PI_HOST`, `PI_USER`, `PI_PORT`, `PI_DIR`) from `.env`.
2. Perform pre-flight SSH and tool checks.
3. Synchronize code via `rsync` over SSH.
4. Execute `docker compose up -d` on the Raspberry Pi 5.

### 2. Stack Health & Connectivity Test (`scripts/test-stack.sh`)

To verify that all services are online and responding:

```bash
./scripts/test-stack.sh
```

---

### 3. GitOps Automated Deployment (GitHub Actions)

A self-hosted GitHub Actions runner on the Raspberry Pi 5 automatically deploys changes on every push to `main`.

- **Workflow File**: `.github/workflows/deploy.yml`
- **Runner Setup**: Follow the detailed guide in [docs/RUNNER_SETUP.md](docs/RUNNER_SETUP.md) or execute:

```bash
./scripts/setup-runner.sh "https://github.com/yanis-corselle/vortex-ai" "YOUR_REGISTRATION_TOKEN"
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
│   ├── README.md               # Scripts documentation
│   ├── deploy.sh               # SSH manual deployment script
│   ├── setup-runner.sh         # Self-hosted runner installation script
│   └── test-stack.sh           # Stack health check script
├── .clinerules                 # Guidelines and stack rules
├── .env                        # Environment variables configuration
├── .env.example                # Environment variables template
├── README.md                   # Project documentation
└── docker-compose.yml          # Container orchestration stack
```

