# Example Application Service with Sidecars
resource "aws_ecs_service" "example_app" {
  name            = "${var.project_name}-example-app"
  cluster         = aws_ecs_cluster.application.id
  task_definition = aws_ecs_task_definition.example_app.arn
  desired_count   = var.example_app_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.example_app.arn
  }

  tags = var.common_tags
}

# Example Application Task Definition with Sidecars
resource "aws_ecs_task_definition" "example_app" {
  family                   = "${var.project_name}-example-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.example_app_cpu
  memory                   = var.example_app_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = var.example_app_ecr_image != "" ? var.example_app_ecr_image : var.example_app_image

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_ENV"
          value = "production"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.example_app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }

      essential = true
    },
    {
      name  = "prometheus-sidecar"
      image = var.prometheus_ecr_image != "" ? var.prometheus_ecr_image : var.prometheus_image

      portMappings = [
        {
          containerPort = 9090
          protocol      = "tcp"
        }
      ]

      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--web.console.libraries=/etc/prometheus/console_libraries",
        "--web.console.templates=/etc/prometheus/consoles",
        "--storage.tsdb.retention.time=200h",
        "--web.enable-lifecycle"
      ]

      mountPoints = [
        {
          sourceVolume  = "prometheus-config"
          containerPath = "/etc/prometheus"
          readOnly      = true
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.example_app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "prometheus-sidecar"
        }
      }

      essential = false
    },
    {
      name  = "loki-sidecar"
      image = var.loki_ecr_image != "" ? var.loki_ecr_image : var.loki_image

      portMappings = [
        {
          containerPort = 3100
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "LOKI_CONFIG"
          value = "/etc/loki/local-config.yaml"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "loki-config"
          containerPath = "/etc/loki"
          readOnly      = true
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.example_app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "loki-sidecar"
        }
      }

      essential = false
    }
  ])

  volume {
    name = "prometheus-config"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.prometheus_config.id
      root_directory = "/"
    }
  }

  volume {
    name = "loki-config"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.loki_config.id
      root_directory = "/"
    }
  }

  tags = var.common_tags
}

# Service Discovery for Example App
resource "aws_service_discovery_service" "example_app" {
  name = "example-app"

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

# CloudWatch Log Group for Example App
resource "aws_cloudwatch_log_group" "example_app" {
  name              = "/ecs/${var.project_name}-example-app"
  retention_in_days = 7

  tags = var.common_tags
}



