SHELL := /usr/bin/env bash
HARBOR_ADMIN_PASS ?= admin

.PHONY: dev prod init-tf apply-tf

dev: 
	skaffold run -p dev
	$(MAKE) apply-tf
	$(MAKE) robot


prod: 
	skaffold run -p prod
	$(MAKE) apply-tf


init-tf:
	terraform -chdir=terraform init


apply-tf: init-tf
	terraform -chdir=terraform apply -auto-approve \
		-var "harbor_admin_password=$(HARBOR_ADMIN_PASS)"

robot:
	@echo "Writing robot creds to .env"
	@echo "ROBOT_USER=$$(terraform -chdir=terraform output -raw robot_name)" > .env
	@echo "ROBOT_PASS=$$(terraform -chdir=terraform output -raw robot_secret)" >> .env
