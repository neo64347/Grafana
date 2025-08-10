# ECS Cluster references moved to clusters.tf

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-s3-access"
  description = "Policy for S3 access for Grafana"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.grafana_data.arn,
          "${aws_s3_bucket.grafana_data.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# IAM Policy for ECR access
resource "aws_iam_policy" "ecr_access" {
  name        = "${var.project_name}-ecr-access"
  description = "Policy for ECR access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = var.common_tags
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.project_name}-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

# EFS File System for Prometheus Configuration
resource "aws_efs_file_system" "prometheus_config" {
  creation_token = "${var.project_name}-prometheus-config"
  encrypted      = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-prometheus-config"
  })
}

resource "aws_efs_mount_target" "prometheus_config" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.prometheus_config.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Service Discovery for Prometheus
resource "aws_service_discovery_private_dns_namespace" "prometheus" {
  name        = "prometheus.local"
  description = "Private DNS namespace for Prometheus"
  vpc         = module.vpc.vpc_id

  tags = var.common_tags
}

resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

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

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.project_name}-grafana"
  retention_in_days = 7

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/ecs/${var.project_name}-prometheus"
  retention_in_days = 7

  tags = var.common_tags
}
