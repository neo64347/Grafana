# Outputs
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "grafana_url" {
  description = "The URL of the Grafana instance"
  value       = "http://${aws_lb.main.dns_name}"
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for Grafana data"
  value       = aws_s3_bucket.grafana_data.bucket
}

output "ecs_cluster_name" {
  description = "The name of the main ECS cluster (deprecated, use main_cluster_name)"
  value       = aws_ecs_cluster.main.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "grafana_ecr_repository_url" {
  description = "The URL of the Grafana ECR repository"
  value       = aws_ecr_repository.grafana.repository_url
}

output "prometheus_ecr_repository_url" {
  description = "The URL of the Prometheus ECR repository"
  value       = aws_ecr_repository.prometheus.repository_url
}

output "loki_ecr_repository_url" {
  description = "The URL of the Loki ECR repository"
  value       = aws_ecr_repository.loki.repository_url
}

output "grafana_agent_ecr_repository_url" {
  description = "The URL of the Grafana Alloy ECR repository"
  value       = aws_ecr_repository.grafana_agent.repository_url
}

output "example_app_ecr_repository_url" {
  description = "The URL of the Example Application ECR repository"
  value       = aws_ecr_repository.example_app.repository_url
}

output "main_cluster_name" {
  description = "The name of the main ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "application_cluster_name" {
  description = "The name of the application ECS cluster"
  value       = aws_ecs_cluster.application.name
}
