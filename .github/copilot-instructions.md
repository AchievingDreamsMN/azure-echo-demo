# Copilot Instructions

## Infrastructure Best Practices

- Always use Azure Verified Modules for resource creation.
- Never hardcode secrets; use Azure Key Vault references.
- All Terraform resources must include 'Environment' and 'Owner' tags.

## Code Standards

- Follow existing project patterns and conventions.
- Write tests for new functionality.
- Use meaningful commit messages.

## Security

- Never commit secrets, credentials, or API keys.
- Use GitHub Secrets for CI/CD sensitive values.
- Store application secrets in Azure Key Vault.
- All resources should be prefixed with "demo-" for easy cleanup.

## Terraform Guidelines

- Use modules for reusable infrastructure components.
- Store state in Azure Blob Storage with the configured backend.
- Run `terraform fmt` before committing.
- Include descriptions for all variables.
