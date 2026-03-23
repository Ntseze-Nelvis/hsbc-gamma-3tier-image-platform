#!/bin/bash
echo "🔧 Fixing Terraform configuration..."

# Fix providers.tf
cat > providers.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
EOF

# Remove profile from variables.tf if it exists
if grep -q "variable \"profile\"" variables.tf; then
    echo "Removing profile variable from variables.tf..."
    sed -i '/variable "profile"/,+5d' variables.tf
fi

# Update .gitlab-ci.yml
cat > .gitlab-ci.yml << 'EOF'
image:
  name: hashicorp/terraform:1.6
  entrypoint: [""]

stages:
  - validate
  - fmt
  - plan
  - apply

variables:
  TF_ROOT: "."
  TF_IN_AUTOMATION: "true"
  TF_VAR_aws_region: "eu-north-1"
  TF_VAR_environment: "dev"
  TF_VAR_project_name: "hsbc-gamma-dev"

cache:
  paths:
    - .terraform

before_script:
  - cd ${TF_ROOT}
  - terraform --version
  - |
    terraform init \
      -backend-config="bucket=${TF_STATE_BUCKET}" \
      -backend-config="key=${TF_STATE_KEY}" \
      -backend-config="region=${TF_STATE_REGION}" \
      -reconfigure

validate:
  stage: validate
  script:
    - terraform validate
  only:
    - main

fmt:
  stage: fmt
  script:
    - terraform fmt -check -recursive
  only:
    - main

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan
  only:
    - main

apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  when: manual
  only:
    - main
EOF

# Commit and push
git add providers.tf variables.tf .gitlab-ci.yml
git commit -m "Fix: Remove profile variable, configure proper backend"
git push origin main

echo "✅ Done! Check pipeline at:"
echo "https://gitlab.com/Ntseze-Nelvis/hsbc-gamma-3tier-image-platform/-/pipelines"