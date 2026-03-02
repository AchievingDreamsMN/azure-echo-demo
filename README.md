# Azure Container Apps Echo Server Demo

A complete CI/CD demonstration deploying a Python echo server to Azure Container Apps using Terraform and GitHub Actions.

## 🎯 Project Overview

This project demonstrates:
- **Python FastAPI** web application
- **Azure Container Apps** for serverless container hosting
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD automation

## 📁 Project Structure

```
azure-echo-demo/
├── app/
│   ├── main.py              # FastAPI echo server
│   └── requirements.txt     # Python dependencies
├── terraform/
│   ├── main.tf              # Azure infrastructure
│   ├── variables.tf         # Configuration variables
│   └── outputs.tf           # Output values
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD pipeline
├── Dockerfile               # Container definition
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Azure subscription
- Azure CLI installed
- Terraform >= 1.5.0
- Docker (for local testing)
- GitHub account

### Local Development

```bash
# Install dependencies
cd app
pip install -r requirements.txt

# Run locally
python main.py
# Visit http://localhost:8080
```

### Docker Testing

```bash
# Build image
docker build -t echo-server .

# Run container
docker run -p 8080:8080 echo-server
```

## ☁️ Azure Deployment

### Architecture

```
GitHub Secrets (minimal)     Azure Key Vault
├── AZURE_CREDENTIALS   →    ├── acr-login-server
├── ARM_CLIENT_ID            ├── acr-username
├── ARM_CLIENT_SECRET        └── acr-password
├── ARM_SUBSCRIPTION_ID
└── ARM_TENANT_ID
```

### 1. Bootstrap (One-Time Setup)

```powershell
# Run the bootstrap script
.\scripts\bootstrap.ps1

# This creates:
# - demo-bootstrap-rg (resource group for Terraform state)
# - Storage account for state files
# - Service principal for GitHub Actions
```

### 2. Configure GitHub Secrets

Add these **5 secrets** to your GitHub repository (Settings → Secrets → Actions):

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Full JSON from bootstrap output |
| `ARM_CLIENT_ID` | Service principal client ID |
| `ARM_CLIENT_SECRET` | Service principal secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |

**Note:** ACR credentials are stored in Azure Key Vault, not GitHub!

### 3. Initial Infrastructure (Creates Key Vault + ACR)

```bash
cd terraform/environments/prod

# Update backend storage account name from bootstrap output
# Then:
terraform init
terraform apply
```

This creates:
- Azure Container Registry
- Azure Key Vault with ACR credentials
- Production Container App

### 4. Deploy QA Environment

Push to `develop` branch triggers QA deployment:

```bash
git checkout develop
git push origin develop
```

### 5. Deploy to Production

Push to `main` branch triggers production deployment (with approval gate):

```bash
git checkout main
git merge develop
git push origin main
```

## 🔧 Configuration

### Terraform Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `project_name` | echo-server | Resource naming prefix |
| `location` | eastus | Azure region |
| `min_replicas` | 0 | Minimum container instances |
| `max_replicas` | 3 | Maximum container instances |

### Customization

```bash
terraform apply -var="project_name=my-app" -var="location=westus2"
```

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Interactive web UI |
| `/echo` | POST | Echo JSON message |
| `/health` | GET | Health check |

### Example API Usage

```bash
# Echo a message
curl -X POST https://your-app.azurecontainerapps.io/echo \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, Azure!"}'

# Response
{"echo": "🔊 Hello, Azure!", "original": "Hello, Azure!"}
```

## 💰 Cost Optimization

- Container Apps uses consumption-based pricing
- `min_replicas: 0` scales to zero when idle

## 🧹 Cleanup After Demo

Delete all demo resources with one command:

```powershell
.\scripts\cleanup.ps1
```

This removes:
- All `demo-*` resource groups
- Service principal
- App registration

Or manually:
```bash
# Terraform destroy (preserves state for re-deploy)
cd terraform/environments/prod && terraform destroy
cd ../qa && terraform destroy

# Full cleanup (deletes everything)
az group delete --name demo-bootstrap-rg --yes
az group delete --name demo-echo-server-qa-rg --yes
az group delete --name demo-echo-server-prod-rg --yes
az group delete --name demo-echo-server-acr-rg --yes
```
- Basic tier ACR for development
- 30-day log retention

## 🧹 Cleanup

```bash
# Destroy all resources
cd terraform
terraform destroy
```

## 📝 License

MIT License - feel free to use this as a template!

---

**Built to demonstrate CI/CD and Azure proficiency** 🚀
