# Self-Hosted GitHub Actions Runner Setup (Raspberry Pi 5 ARM64)

This guide documents the installation and systemd service configuration for the **GitHub Actions Self-Hosted Runner** on the Raspberry Pi 5 (ARM64).

---

## 1. Prerequisites on Raspberry Pi 5

Ensure your Raspberry Pi 5 is running 64-bit OS (Raspberry Pi OS 64-bit or Ubuntu ARM64) with Docker installed:

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Verify Docker installation
docker --version
docker compose version

# Add your user to the docker group if not already done
sudo usermod -aG docker $USER
newgrp docker
```

---

## 2. Option A: Automated Installation Script

Run the automated installer script provided in the repository:

```bash
./scripts/setup-runner.sh "https://github.com/YOUR_GITHUB_USERNAME/vortexai" "YOUR_REGISTRATION_TOKEN"
```

---

## 3. Option B: Manual Installation Procedure

### Step 1: Create a Runner Directory
```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
```

### Step 2: Download & Extract the Linux ARM64 Runner
Get the latest runner version for ARM64 architecture:

```bash
curl -o actions-runner-linux-arm64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-arm64-2.321.0.tar.gz

# Extract package
tar xzf ./actions-runner-linux-arm64-2.321.0.tar.gz
```

### Step 3: Configure the Runner
Generate a new registration token from GitHub (**Repository Settings -> Actions -> Runners -> New self-hosted runner**):

```bash
./config.sh --url https://github.com/YOUR_GITHUB_USERNAME/vortexai --token YOUR_REGISTRATION_TOKEN
```

### Step 4: Install as a `systemd` Service
To ensure the runner automatically starts on boot and runs 24/7 as a background service:

```bash
# Install the systemd service
sudo ./svc.sh install $USER

# Start the systemd service
sudo ./svc.sh start

# Check the service status
sudo ./svc.sh status
```

---

## 4. Useful Service Management Commands

```bash
# Check status
sudo systemctl status actions.runner.*

# View logs in real-time
journalctl -u actions.runner.* -f

# Restart runner service
sudo ./svc.sh stop
sudo ./svc.sh start
```

---

## 5. Verification

Once installed and active:
1. Go to your GitHub repository -> **Settings -> Actions -> Runners**.
2. Verify that your Raspberry Pi runner appears with status **Idle** / **Online**.
3. Push a change to the `main` branch to trigger `.github/workflows/deploy.yml`.
