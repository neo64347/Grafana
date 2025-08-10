# Loki is now a sidecar container in application tasks

# EFS File System for Loki Configuration
resource "aws_efs_file_system" "loki_config" {
  creation_token = "${var.project_name}-loki-config"
  encrypted      = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-loki-config"
  })
}

resource "aws_efs_mount_target" "loki_config" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.loki_config.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Service Discovery for Loki
resource "aws_service_discovery_service" "loki" {
  name = "loki"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.prometheus.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = var.common_tags
}

# CloudWatch Log Group for Loki
resource "aws_cloudwatch_log_group" "loki" {
  name              = "/ecs/${var.project_name}-loki"
  retention_in_days = 7

  tags = var.common_tags
}
