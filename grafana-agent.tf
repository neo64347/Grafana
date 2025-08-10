# Grafana Alloy ECS Service
resource "aws_ecs_service" "grafana_agent" {
  name            = "${var.project_name}-grafana-alloy"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana_agent.arn
  desired_count   = var.grafana_agent_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  tags = var.common_tags
}

# Grafana Alloy ECS Task Definition
resource "aws_ecs_task_definition" "grafana_agent" {
  family                   = "${var.project_name}-grafana-alloy"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.grafana_agent_cpu
  memory                   = var.grafana_agent_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "grafana-alloy"
      image = var.grafana_agent_ecr_image != "" ? var.grafana_agent_ecr_image : var.grafana_agent_image

      portMappings = [
        {
          containerPort = 12345
          protocol      = "tcp"
        }
      ]

      command = [
        "run",
        "/etc/grafana-alloy/config.river"
      ]

      mountPoints = [
        {
          sourceVolume  = "grafana-alloy-config"
          containerPath = "/etc/grafana-alloy"
          readOnly      = true
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana_agent.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "grafana-alloy"
        }
      }

      essential = true
    }
  ])

  volume {
    name = "grafana-alloy-config"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.grafana_agent_config.id
      root_directory = "/"
    }
  }

  tags = var.common_tags
}

# EFS File System for Grafana Alloy Configuration
resource "aws_efs_file_system" "grafana_agent_config" {
  creation_token = "${var.project_name}-grafana-alloy-config"
  encrypted      = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-grafana-alloy-config"
  })
}

resource "aws_efs_mount_target" "grafana_agent_config" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.grafana_agent_config.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

# CloudWatch Log Group for Grafana Alloy
resource "aws_cloudwatch_log_group" "grafana_agent" {
  name              = "/ecs/${var.project_name}-grafana-alloy"
  retention_in_days = 7

  tags = var.common_tags
}
