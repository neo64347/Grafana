#!/bin/bash

# Add Terraform to PATH
export PATH="/c/Terraform:$PATH"

# Add alias to bashrc if not already present
if ! grep -q "alias tf=" ~/.bashrc; then
    echo "# Terraform alias for convenience" >> ~/.bashrc
    echo "alias tf=terraform" >> ~/.bashrc
    echo "export PATH=\"/c/Terraform:\$PATH\"" >> ~/.bashrc
fi

# Test the alias
source ~/.bashrc
echo "Testing tf alias..."
tf version

echo "Bash alias setup complete! You can now use 'tf' instead of 'terraform'"
