# Grafana Observability Stack on AWS ECS (Terraform)

Terraform code that deploys a self-hosted observability stack on **AWS ECS Fargate**: **Grafana** for dashboards, **Prometheus** for metrics, **Loki** for logs and **Grafana Alloy** for collection. It also deploys an example application that ships its own metrics and logs through sidecar containers.

```
                    Internet
                       │
               ┌───────▼────────┐
               │  Application   │  :80
               │ Load Balancer  │
               └───────┬────────┘
                       │
 ┌─────────────────────┼──────────── VPC (2 AZs, private subnets, NAT) ──────────┐
 │                     │                                                          │
 │  Main ECS cluster   ▼                     Application ECS cluster              │
 │  ┌──────────────────────┐                 ┌──────────────────────────────────┐ │
 │  │ Grafana        :3000 │◄── queries ─────│ example-app task                 │ │
 │  └──────────────────────┘                 │  ├─ app container                │ │
 │  ┌──────────────────────┐                 │  ├─ prometheus-sidecar   :9090   │ │
 │  │ Grafana Alloy        │── remote write ►│  └─ loki-sidecar         :3100   │ │
 │  └──────────────────────┘                 └──────────────────────────────────┘ │
 │                                                                                │
 │  Cloud Map DNS (*.prometheus.local) · EFS (configs) · S3 (Grafana data)        │
 │  ECR (images) · CloudWatch Logs · IAM task roles                               │
 └────────────────────────────────────────────────────────────────────────────────┘
```

## What gets created

| Area | Resources | File |
|---|---|---|
| Networking | VPC with public and private subnets across 2 AZs, a single NAT gateway | `vpc.tf` |
| Compute | Two ECS clusters (main + application) with Container Insights | `clusters.tf` |
| Grafana | Fargate service and task definition, behind an ALB | `ecs.tf`, `resources.tf` |
| Prometheus / Loki | Sidecar containers in the app task; configs on EFS; Cloud Map service discovery | `sidecar-app.tf`, `loki.tf`, `resources.tf` |
| Collection | Grafana Alloy service that tails logs and scrapes metrics | `grafana-agent.tf`, `grafana-alloy.river` |
| Images | ECR repositories with lifecycle and repository policies | `ecr.tf` |
| Storage | Versioned, encrypted, private S3 bucket for Grafana data | `s3.tf` |
| Security | Security groups for the ALB, ECS tasks and EFS; IAM roles for task execution, S3 and ECR | `sg.tf`, `resources.tf` |

## Prerequisites

- Terraform ≥ 1.0 (AWS provider `~> 5.0`)
- AWS CLI v2, configured with credentials that can create the resources above
- `jq` (used by `deploy.sh`)

## Quick start

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set a strong grafana_admin_password (required, no default)

./deploy.sh          # init → plan → asks for confirmation → apply
```

Or run Terraform directly:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

When it finishes, open the `grafana_url` output and log in as `admin` with the password from `terraform.tfvars`. Then add Prometheus (`http://example-app.prometheus.local:9090`) and Loki (`http://example-app.prometheus.local:3100`) as data sources.

## Configuration

The main variables (see `variables.tf` for all of them):

| Variable | Default | Notes |
|---|---|---|
| `aws_region` | `us-west-2` | |
| `project_name` | `grafana-monitoring` | Prefix for resource names |
| `vpc_cidr` | `10.0.0.0/16` | |
| `grafana_admin_password` | none | **Required.** Sensitive; keep it in `terraform.tfvars` (git-ignored) |
| `*_image` / `*_ecr_image` | Public images | Set the ECR URI to pull from your own registry |
| `*_cpu` / `*_memory` | 256 / 512 | Per-task Fargate sizing |

## Useful outputs

`grafana_url`, `alb_dns_name`, `main_cluster_name`, `application_cluster_name`, `vpc_id`, `s3_bucket_name` and the ECR repository URLs for each image.

## Tear down

```bash
./deploy.sh destroy
```

## Notes and next steps

- The ALB listens on HTTP :80. For anything beyond a demo, add an ACM certificate and an HTTPS listener.
- The images default to `:latest`. Pin versions for repeatable deployments.
- Terraform state is local. Use an S3 backend with DynamoDB locking for team use.

## License

MIT. See [LICENSE](LICENSE).
