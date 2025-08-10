variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "grafana-monitoring"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "grafana-monitoring"
    ManagedBy   = "terraform"
  }
}

variable "grafana_image" {
  description = "Grafana Docker image"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "grafana_ecr_image" {
  description = "Grafana ECR image URI"
  type        = string
  default     = ""
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "grafana_cpu" {
  description = "CPU units for Grafana task"
  type        = number
  default     = 256
}

variable "grafana_memory" {
  description = "Memory for Grafana task (MiB)"
  type        = number
  default     = 512
}

variable "grafana_desired_count" {
  description = "Desired number of Grafana tasks"
  type        = number
  default     = 1
}

variable "prometheus_image" {
  description = "Prometheus Docker image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "prometheus_ecr_image" {
  description = "Prometheus ECR image URI"
  type        = string
  default     = ""
}

variable "prometheus_cpu" {
  description = "CPU units for Prometheus task"
  type        = number
  default     = 256
}

variable "prometheus_memory" {
  description = "Memory for Prometheus task (MiB)"
  type        = number
  default     = 512
}

variable "prometheus_desired_count" {
  description = "Desired number of Prometheus tasks"
  type        = number
  default     = 1
}

variable "loki_image" {
  description = "Loki Docker image"
  type        = string
  default     = "grafana/loki:latest"
}

variable "loki_ecr_image" {
  description = "Loki ECR image URI"
  type        = string
  default     = ""
}

variable "loki_cpu" {
  description = "CPU units for Loki task"
  type        = number
  default     = 256
}

variable "loki_memory" {
  description = "Memory for Loki task (MiB)"
  type        = number
  default     = 512
}

variable "loki_desired_count" {
  description = "Desired number of Loki tasks"
  type        = number
  default     = 1
}

variable "grafana_agent_image" {
  description = "Grafana Alloy Docker image"
  type        = string
  default     = "grafana/alloy:latest"
}

variable "grafana_agent_ecr_image" {
  description = "Grafana Alloy ECR image URI"
  type        = string
  default     = ""
}

variable "grafana_agent_cpu" {
  description = "CPU units for Grafana Alloy task"
  type        = number
  default     = 256
}

variable "grafana_agent_memory" {
  description = "Memory for Grafana Alloy task (MiB)"
  type        = number
  default     = 512
}

variable "grafana_agent_desired_count" {
  description = "Desired number of Grafana Alloy tasks"
  type        = number
  default     = 1
}

variable "example_app_image" {
  description = "Example application Docker image"
  type        = string
  default     = "nginx:alpine"
}

variable "example_app_ecr_image" {
  description = "Example application ECR image URI"
  type        = string
  default     = ""
}

variable "example_app_cpu" {
  description = "CPU units for example application task"
  type        = number
  default     = 512
}

variable "example_app_memory" {
  description = "Memory for example application task (MiB)"
  type        = number
  default     = 1024
}

variable "example_app_desired_count" {
  description = "Desired number of example application tasks"
  type        = number
  default     = 1
}
