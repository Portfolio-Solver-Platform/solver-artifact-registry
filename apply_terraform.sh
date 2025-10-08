#!/bin/bash
HARBOR_ADMIN_PASS="${HARBOR_ADMIN_PASS:=admin}"
KUBE_CONFIG_PATH="${KUBE_CONFIG_PATH:="~/.kube/config"}"
export KUBE_CONFIG_PATH=$KUBE_CONFIG_PATH
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve -var "harbor_admin_password=$HARBOR_ADMIN_PASS"

