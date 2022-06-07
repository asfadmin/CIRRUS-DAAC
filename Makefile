# ---------------------------
SELF_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
DIST_DIR := ${SELF_DIR}/dist
SERVED_BY_CUMULUS_API ?= "true"

.SILENT:
.ONESHELL:
.PHONY: clean container-shell test test-watch daac workflows

# ---------------------------
define banner =
echo
echo "========================================"
if command -v figlet 2>/dev/null; then
	figlet $@
elif command -v banner 2>/dev/null; then
	banner $@
else
	echo "Making: $@"
fi
echo "========================================"
endef

# ---------------------------
${DIST_DIR}:
	mkdir ${DIST_DIR}

# ---------------------------
clean:
	rm -rf ${DIST_DIR}
	find workflows -name "*.pyc" -type f -delete
	find workflows -name __pycache__ -type d -delete

# ---------------------------
image: Dockerfile
	docker build -f Dockerfile -t cirrus-daac .

container-shell:
	docker run -it --rm \
		--user `id -u` \
		-v ${PWD}:/CIRRUS-DAAC \
		-v ~/.aws:/root/.aws \
		--name=cirrus-daac \
		cirrus-daac

# ---------------------------
test:
	cd workflows
	flake8
	pytest -vv

test-watch:
	cd workflows
	ptw -c --beforerun flake8

# ---------------------------
%-init:
	$(banner)
	cd $*
	rm -f .terraform/environment
	terraform init -reconfigure -input=false -no-color \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4}" \
		-backend-config "key=$*/terraform.tfstate" \
		-backend-config "dynamodb_table=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} 2>/dev/null || terraform workspace select ${DEPLOY_NAME}

modules = daac workflows rds
init-modules := $(modules:%-init=%)

# ---------------------------
daac: daac-init
	$(banner)
	cd $@
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		$$VARIABLES_OPT \
		-input=false \
		-auto-approve \
		-no-color

# ---------------------------
plan-daac: daac-init
	$(banner)
	cd daac
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform plan \
		$$VARIABLES_OPT \
		-input=false \
		-no-color

# ---------------------------
${DIST_DIR}/lambda_dependencies_layer.zip: ${DIST_DIR} workflows/requirements.txt
	mkdir -p ${DIST_DIR}/python
	cd ${DIST_DIR}/python
	pip3 install -r ${SELF_DIR}/workflows/requirements.txt --target .
	cd ..
	zip -r ${DIST_DIR}/lambda_dependencies_layer.zip python/*

${DIST_DIR}/lambdas.zip: ${DIST_DIR} workflows/lambdas/*.py
	cd workflows
	zip ${DIST_DIR}/lambdas.zip lambdas/*.py

artifacts: \
	${DIST_DIR}/lambda_dependencies_layer.zip \
	${DIST_DIR}/lambdas.zip

workflows: workflows-init artifacts
	$(banner)
	cd $@
	terraform apply -var 'DIST_DIR=${DIST_DIR}' -input=false -auto-approve -no-color

plan-workflows: workflows-init artifacts
	$(banner)
	cd workflows
	terraform plan -var 'DIST_DIR=${DIST_DIR}' -input=false -no-color

destroy-workflows: workflows-init
	$(banner)
	cd workflows
	terraform destroy -var 'DIST_DIR=${DIST_DIR}' -input=false -auto-approve -no-color

# ---------------------------
rds: rds-init
	$(banner)
	cd $@
	if [ -f "secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		$$SECRETS_OPT \
		$$VARIABLES_OPT \
		-input=false \
		-auto-approve \
		-no-color

# ---------------------------
plan-rds: rds-init
	$(banner)
	cd rds
	if [ -f "secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform plan \
		$$SECRETS_OPT \
		$$VARIABLES_OPT \
		-input=false \
		-no-color

# ---------------------------
destroy-rds: rds-init
	$(banner)
	cd rds
	if [ -f "secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	export TF_CMD="terraform destroy \
				$$VARIABLES_OPT \
				$$SECRETS_OPT \
				-input=false \
				-no-color \
				-auto-approve"
	eval $$TF_CMD

# ---------------------------
pcrs: workflows/providers/* workflows/collections/* workflows/rules/*
	if [ -z ${cumulus_id_rsa+x} ];  then echo "Env Var \$cumulus_id_rsa is not set, using ~/.ssh/id_rsa"; fi
	scripts/deploy-pcrs.sh ${SELF_DIR}/workflows ${cumulus_id_rsa-"~/.ssh/id_rsa"}

# ------ Cumulus Dashboard ------

# We could get more granular with the dependencies here, but using the
# dashboard directory is probably fine since we aren't developing it.
cumulus-dashboard/dist: cumulus-dashboard cumulus-init
	if [ "${MATURITY}" = "dev" ]; then
		export SERVED_BY_CUMULUS_API=true
	fi
	export DAAC_NAME=${DEPLOY_NAME}
	export STAGE=${MATURITY}
	export HIDE_PDR=false
	export LABELS=daac
	export APIROOT=$(shell cd cumulus && terraform output archive_api_uri)
	cd $(@D)
	@echo "APIROOT=$$APIROOT"
	npm install --no-optional --cache ../.npm
	npm run build

.PHONY: dashboard
dashboard: cumulus-dashboard/dist
	$(banner)
	aws s3 sync cumulus-dashboard/dist s3://${DEPLOY_NAME}-cumulus-${MATURITY}-dashboard --delete
