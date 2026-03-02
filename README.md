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

### 1. Create Azure Service Principal

```bash
az login
az ad sp create-for-rbac --name "echo-server-cicd" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository:

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Full JSON output from service principal creation |
| `ARM_CLIENT_ID` | Service principal client ID |
| `ARM_CLIENT_SECRET` | Service principal secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID |
| `ARM_TENANT_ID` | Azure tenant ID |
| `ACR_USERNAME` | Container registry admin username |
| `ACR_PASSWORD` | Container registry admin password |
| `ACR_LOGIN_SERVER` | Container registry login server |

### 3. Initial Infrastructure Setup

```bash
cd terraform

# Initialize Terraform
terraform init

# Create infrastructure
terraform apply
```

### 4. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/azure-echo-demo.git
git push -u origin main
```

The CI/CD pipeline will automatically:
1. Run tests and linting
2. Build and push Docker image
3. Deploy infrastructure with Terraform
4. Update the Container App

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
