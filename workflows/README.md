# VortexAI - n8n Workflows (IaC)

This directory contains declarative JSON definitions of n8n workflows for the VortexAI stack. Storing workflows here enables Infrastructure as Code (IaC) and ensures they are version-controlled and automatically provisioned.

## How It Works

1. **Declarative Storage**: Each workflow is stored as a `.json` file in this directory.
2. **Automated Provisioning**: When the n8n container starts (via Docker Compose), it mounts `./workflows` to `/backup/workflows` inside the container and runs:
   ```bash
   n8n import:workflow --input=/backup/workflows
   ```
   This automatically imports or updates all workflows in the n8n database upon container initialization.
3. **CI/CD Validation**: On every pull request, GitHub Actions validates all JSON workflow files using `jq` to ensure they are syntactically valid before merging into `main`.

## Adding or Modifying Workflows

1. Create or export your workflow from n8n web interface (`http://<pi-ip>:5678`) as JSON.
2. Place or update the `.json` file inside the `workflows/` directory.
3. Commit and push your changes to `main`. The self-hosted GitHub Actions runner will automatically deploy and update the workflows on the Raspberry Pi 5.
