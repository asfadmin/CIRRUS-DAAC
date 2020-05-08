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

modules = daac workflows
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

destroy-workflows: workflows-init
	$(banner)
	cd workflows
	terraform destroy -var 'DIST_DIR=${DIST_DIR}' -input=false -auto-approve -no-color

# ---------------------------
pcrs: workflows/providers/* workflows/collections/* workflows/rules/*
	if [ -z ${cumulus_id_rsa+x} ];  then echo "Env Var \$cumulus_id_rsa is not set, using ~/.ssh/id_rsa"; fi
	scripts/deploy-pcrs.sh ${SELF_DIR}/workflows ${cumulus_id_rsa-"~/.ssh/id_rsa"}

# ------ Cumulus Dashboard ------
#
#  Deploying the dashboard requires the environment variables:
#
#    CUMULUS_API_ROOT: The HTTP URL for the Cumulus instance's API, e.g.:
#
#      CUMULUS_API_ROOT="https://mlcjs8s9ac.execute-api.us-east-1.amazonaws.com/dev/"
#
#    CUMULUS_DASHBOARD_VERSION: The version number (e.g., v1.7.2) to build & deploy
#
#    Then call:
#
#      make dashboard
#
tmp:
	mkdir -p tmp

tmp-cumulus-dashboard: tmp
	rm -rf tmp/cumulus-dashboard
	git clone https://github.com/nasa/cumulus-dashboard tmp/cumulus-dashboard
	cd tmp/cumulus-dashboard
	git fetch origin ${CUMULUS_DASHBOARD_VERSION}:refs/tags/${CUMULUS_DASHBOARD_VERSION}
	git checkout ${CUMULUS_DASHBOARD_VERSION}

build-dashboard: tmp-cumulus-dashboard
	cd tmp/cumulus-dashboard
	SERVED_BY_CUMULUS_API=${SERVED_BY_CUMULUS_API} \
	DAAC_NAME=${DEPLOY_NAME} \
	STAGE=${MATURITY} \
	HIDE_PDR=false \
	LABELS=daac \
	APIROOT=${CUMULUS_API_ROOT} \
	./bin/build_in_docker.sh

deploy-dashboard: dashboard-init
	cd tmp/cumulus-dashboard
	aws s3 sync dist s3://${DEPLOY_NAME}-cumulus-${MATURITY}-dashboard --acl public-read

dashboard: build-dashboard deploy-dashboard
