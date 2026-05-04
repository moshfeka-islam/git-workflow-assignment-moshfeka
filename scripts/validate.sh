#!/bin/bash
echo "Validating repository structure..."

required_files=(
  "README.md"
  "app/config.yaml"
  "app/feature-flags.yaml"
  "infra/backend.tf"
  "infra/variables.tf"
  "infra/environments/dev.tfvars"
  "infra/environments/staging.tfvars"
  "infra/environments/prod.tfvars"
  "docs/git-notes.md"
  "docs/conflict-resolution.md"
  "docs/command-log.md"
)

all_ok=true
for f in "${required_files[@]}"; do
  if [ -f "$f" ]; then
    echo "  [OK] $f"
  else
    echo "  [MISSING] $f"
    all_ok=false
  fi
done

if $all_ok; then
  echo "All required files present."
  exit 0
else
  echo "Some files are missing."
  exit 1
fi
