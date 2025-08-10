#!/bin/bash

# Grafana Monitoring Stack Deployment Script
# This script helps deploy the Terraform infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TERRAFORM_VERSION"
}

# Check if AWS CLI is configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
    print_status "AWS Account: $AWS_ACCOUNT"
    print_status "AWS Region: $AWS_REGION"
}

# Check if terraform.tfvars exists
check_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            print_status "Created terraform.tfvars from example. Please review and edit as needed."
            print_warning "IMPORTANT: Update the grafana_admin_password in terraform.tfvars before proceeding!"
            exit 0
        else
            print_error "terraform.tfvars.example not found. Please create terraform.tfvars manually."
            exit 1
        fi
    fi
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
}

# Plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
}

# Apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform configuration..."
    terraform apply tfplan
}

# Show outputs
show_outputs() {
    print_status "Deployment completed successfully!"
    echo
    print_status "Outputs:"
    terraform output
    echo
    print_status "Next steps:"
    echo "1. Access Grafana at the URL shown above"
    echo "2. Login with admin / <password-from-tfvars>"
    echo "3. Configure S3 and Prometheus datasources"
    echo "4. Import dashboards as needed"
}

# Main deployment function
deploy() {
    print_status "Starting Grafana Monitoring Stack deployment..."
    
    check_terraform
    check_aws_cli
    check_tfvars
    
    init_terraform
    plan_terraform
    
    echo
    print_warning "Review the plan above. Do you want to proceed with the deployment? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apply_terraform
        show_outputs
    else
        print_status "Deployment cancelled."
        exit 0
    fi
}

# Destroy function
destroy() {
    print_warning "This will destroy all resources. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Destroying infrastructure..."
        terraform destroy
        print_status "Infrastructure destroyed successfully."
    else
        print_status "Destroy cancelled."
    fi
}

# Help function
show_help() {
    echo "Grafana Monitoring Stack Deployment Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  deploy   - Deploy the infrastructure (default)"
    echo "  destroy  - Destroy the infrastructure"
    echo "  help     - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 destroy"
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac



