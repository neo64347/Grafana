# ECR Repository for Grafana
resource "aws_ecr_repository" "grafana" {
  name                 = "${var.project_name}-grafana"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

# ECR Repository for Prometheus
resource "aws_ecr_repository" "prometheus" {
  name                 = "${var.project_name}-prometheus"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

# ECR Repository for Loki
resource "aws_ecr_repository" "loki" {
  name                 = "${var.project_name}-loki"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

# ECR Repository for Grafana Alloy
resource "aws_ecr_repository" "grafana_agent" {
  name                 = "${var.project_name}-grafana-alloy"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

# ECR Repository for Example Application
resource "aws_ecr_repository" "example_app" {
  name                 = "${var.project_name}-example-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

# ECR Lifecycle Policy for Grafana
resource "aws_ecr_lifecycle_policy" "grafana" {
  repository = aws_ecr_repository.grafana.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Lifecycle Policy for Prometheus
resource "aws_ecr_lifecycle_policy" "prometheus" {
  repository = aws_ecr_repository.prometheus.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Lifecycle Policy for Loki
resource "aws_ecr_lifecycle_policy" "loki" {
  repository = aws_ecr_repository.loki.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Lifecycle Policy for Grafana Alloy
resource "aws_ecr_lifecycle_policy" "grafana_agent" {
  repository = aws_ecr_repository.grafana_agent.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Lifecycle Policy for Example Application
resource "aws_ecr_lifecycle_policy" "example_app" {
  repository = aws_ecr_repository.example_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Repository Policy for Grafana
resource "aws_ecr_repository_policy" "grafana" {
  repository = aws_ecr_repository.grafana.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ECR Repository Policy for Prometheus
resource "aws_ecr_repository_policy" "prometheus" {
  repository = aws_ecr_repository.prometheus.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ECR Repository Policy for Loki
resource "aws_ecr_repository_policy" "loki" {
  repository = aws_ecr_repository.loki.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ECR Repository Policy for Grafana Alloy
resource "aws_ecr_repository_policy" "grafana_agent" {
  repository = aws_ecr_repository.grafana_agent.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ECR Repository Policy for Example Application
resource "aws_ecr_repository_policy" "example_app" {
  repository = aws_ecr_repository.example_app.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_execution_role.arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
