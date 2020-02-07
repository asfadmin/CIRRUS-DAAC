# Cumulus Core

## Overview

This repository contains the configuration and deployment scripts to
deploy Cumulus Core for a DAAC. It is a modified version of the
[Cumulus Template
Deploy](https://github.com/nasa/cumulus-template-deploy)
project. Specifically, all parts of the deployment have been
Terraformed and the configuration minimized by using outputs from
other modules and lookups using Terraform AWS provider data sources.

See the [Cumulus
Documentation](https://nasa.github.io/cumulus/docs/deployment/deployment-readme)
for detailed information about configuring, deploying, and running
Cumulus.

## Prerequisites

* [Terraform](https://www.terraform.io/)
* [AWS CLI](https://aws.amazon.com/cli/)
* [GNU Make](https://www.gnu.org/software/make/)
* One or more NGAP accounts (sandbox, SIT, ...)
* AWS credentials for the account(s)

## Organization

The repository is organized into four Terraform modules:

* `tf`: Creates resources for managing Terraform state
* `daac`: Creates DAAC-specific resources necessary for running Cumulus
* `data-persistence`: Creates DynamoDB tables and Elasticsearch
  resources necessary for running Cumulus
* `cumulus`: Creates all runtime Cumulus resources that can then be used
  to run ingest workflows.

To customize the deployment for your DAAC, you will need to update
variables and settings in a few of the modules. Specifically:

### tf module

There is no additional configuration necessary in this module.

### daac module

To change which version of the [Cumulus Message
Adapter](https://github.com/nasa/cumulus-message-adapter) is used to
create the Lambda layer used by all Step Function Tasks, modify the
corresponding variable in the `terraform.tfvars` file.

### data-persistence module

To change whether Elasticsearch is provisioned, modify the
corresponding variable in the `terraform.tfvars`.

### cumulus module

This module contains the bulk of the DAAC-specific settings. There are
three specific things you should customize:

* `terraform.tfvars`: Variables which are likely the same in all
  environments (SIT, UAT, PROD) _and_ which are not 'secrets'.

* `variables/*.tfvars`: Each file contains variables specific to the
  corresponding 'maturity' or environment to which you are
  deploying. For example, in `dev.tfvars` you will likely use a
  pre-production `urs_url`, while in the `prod.tfvars` file you will
  specify the production url.

* `secrets/*.tfvars`: Like the variables above, these files contains
  *secrets* which are specific to the 'maturity' or environment to
  which you are deploying. Create one file for each environment and
  populate it with secrets. See the example file in this directory for
  a starting point. For example, your `dev` `urs_client_password` is
  likely (hopefully!) different than your `prod` password.

*Important Note*: The secrets files will *not* (and *should not*) be
committed to git. The `.gitignore` file will ignore them by default.

## Deploying Cumulus

*Important Note*: When choosing values for MATURITY and DEPLOY_NAME:
* The combined length cannot exceed 12 characters
* Must consist of `a-z` (lower case characters), `0-9`, and `-` (hyphen) only

1. Setup your environment with the AWS profile that has permissions to
   deploy to the target NGAP account:

        $ source env.sh <profile-name> <deploy-name> <maturity>

        e.g., to deploy to the XYZ DAAC's NGAP sandbox account with the initials
        of a developer (to make deployment unique) with maturity of 'dev':

        $ source env.sh xyz-sandbox-cumulus kb dev

        (This assumes we've setup AWS credentials with the name `xyz-sandbox-cumulus`)

2. Deploy Cumulus:

        $ make all

## Deploying Cumulus Workflows

There is a sample Workflow Terraform module in the `workflows`
directory. It deploys the example HelloWorldWorkflow that comes with
Cumulus. You can use this as a base for deploying your own
workflows. Modify the Terraform for your workflow(s) and deploy the
workflow by:

        $ make workflows
