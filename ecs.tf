# ECS Service for Grafana (Main Cluster)
resource "aws_ecs_service" "grafana" {
  name            = "${var.project_name}-grafana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.grafana]

  tags = var.common_tags
}

# ECS Task Definition for Grafana
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.grafana_cpu
  memory                   = var.grafana_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = var.grafana_ecr_image != "" ? var.grafana_ecr_image : var.grafana_image

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = var.grafana_admin_password
        },
        {
          name  = "GF_INSTALL_PLUGINS"
          value = "grafana-s3-datasource,grafana-prometheus-datasource"
        },
        {
          name  = "GF_SERVER_ROOT_URL"
          value = "http://${aws_lb.main.dns_name}"
        },
        {
          name  = "GF_DATASOURCES_DEFAULT_PROMETHEUS_URL"
          value = "http://${aws_service_discovery_service.prometheus.name}.${aws_service_discovery_private_dns_namespace.prometheus.name}:9090"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "grafana"
        }
      }

      essential = true
    }
  ])

  tags = var.common_tags
}

# Prometheus and Loki are now sidecar containers in application tasks
