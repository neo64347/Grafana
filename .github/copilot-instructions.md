# Copilot Instructions for Grafana Terraform Infrastructure

## Project Overview
This repository manages Grafana infrastructure using Terraform. It includes configuration for AWS resources, Grafana setup, and related monitoring/logging tools. The codebase is designed for modular, environment-driven deployments.

## Architecture & Major Components
- **Terraform Modules**: All infrastructure is defined in `.tf` files (e.g., `main.tf`, `variables.tf`, `outputs.tf`).
- **Configuration Files**: Sensitive/environment-specific data is kept in `.tfvars` and `.tfvars.json` files (excluded from version control).
- **Grafana & Monitoring**: Includes configuration for Grafana (`grafana.ini`, `grafana-agent.tf`), Loki (`loki-config.yaml`, `loki.tf`), Prometheus (`prometheus.yml`), and supporting AWS resources (ECR, ECS, S3, VPC, Security Groups).
- **Deployment Scripts**: Use `deploy.sh` for orchestration or custom deployment steps.

## Developer Workflows
- **Initialize Terraform**: `terraform init`
- **Plan Infrastructure**: `terraform plan -var-file=terraform.tfvars`
- **Apply Changes**: `terraform apply -var-file=terraform.tfvars`
- **Destroy Resources**: `terraform destroy -var-file=terraform.tfvars`
- **Custom Deploy**: Run `deploy.sh` for additional setup or automation.

## Conventions & Patterns
- **Sensitive Data**: Never commit `.tfvars` or secrets; these are ignored via `.gitignore`.
- **Modularity**: Each major AWS resource (ECR, ECS, S3, VPC, etc.) has its own `.tf` file for clarity and separation of concerns.
- **Outputs**: Use `outputs.tf` to expose key resource attributes for integration or debugging.
- **Variables**: All configurable parameters are defined in `variables.tf`.
- **Resource Naming**: Follow consistent naming patterns for AWS resources to avoid collisions and ease management.

## Integration Points
- **AWS**: All infrastructure is provisioned in AWS; ensure credentials are configured locally.
- **Grafana**: Configuration and deployment are managed via Terraform and supporting config files.
- **Monitoring**: Loki and Prometheus are integrated for logging and metrics.

## Key Files & Directories
- `main.tf`, `variables.tf`, `outputs.tf`: Core Terraform logic
- `grafana-agent.tf`, `grafana-alloy.river`: Grafana agent setup
- `loki-config.yaml`, `loki.tf`: Loki configuration
- `prometheus.yml`: Prometheus configuration
- `deploy.sh`: Deployment script
- `.gitignore`: Excludes sensitive and transient files
- `README.md`: Project overview and setup instructions

## Example: Adding a New AWS Resource
1. Create a new `<resource>.tf` file (e.g., `rds.tf`).
2. Define resource blocks and outputs.
3. Add variables to `variables.tf` if needed.
4. Reference outputs in `outputs.tf`.
5. Update `.gitignore` if new sensitive files are introduced.

## Troubleshooting
- Check `crash.log` for Terraform errors.
- Use `terraform state list` to inspect managed resources.
- Review `outputs.tf` for resource attributes.

---
_If any section is unclear or missing, please provide feedback to improve these instructions._
