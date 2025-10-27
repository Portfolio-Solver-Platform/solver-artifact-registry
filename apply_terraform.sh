#!/usr/bin/env bash
HARBOR_ADMIN_PASS="${HARBOR_ADMIN_PASS:=admin}"

terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve -var "harbor_admin_password=$HARBOR_ADMIN_PASS"

