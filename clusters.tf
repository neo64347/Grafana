# Main ECS Cluster for Grafana
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-main-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

# Application ECS Cluster for services with sidecars
resource "aws_ecs_cluster" "application" {
  name = "${var.project_name}-application-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

# CloudWatch Log Groups for Application Cluster
resource "aws_cloudwatch_log_group" "application_cluster" {
  name              = "/ecs/${var.project_name}-application-cluster"
  retention_in_days = 7

  tags = var.common_tags
}



