# Cumulus DAAC

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

* [Docker](https://www.docker.com/get-started)
* One or more NGAP accounts (sandbox, SIT, ...)
* AWS credentials for those account(s)

## Development Setup

You can run tests inside of a Docker container:

        $ make image
        $ make container-shell

1. To run linter (flake8) & unit tests (pytest) once:

        $ make test

2. To run linter & tests when source files change:

        $ make test-watch

## Organization

The repository is organized into the following Terraform modules:

### Cumulus Core Modules

* `daac`: Creates DAAC-specific resources necessary for running Cumulus
* `cumulus`: Creates all runtime Cumulus resources that can then be used
  to run ingest workflows.
* `workflows`: Creates a Cumulus workflow with a sample Python lambda.
* `rds`: This module deploys the default [https://github.com/nasa/cumulus/tree/master/tf-modules/cumulus-rds-tf] (`terraform-aws-cumulus-rds` serverless module)

### Optional Cumulus Ecosystem Component Modules:

* `orca`: Creates an instance of the
  [https://nasa.github.io/cumulus-orca/](operational cloud recovery archive)
* `orca_recovery_workflow`: Using configuration information from the `cumulus`
  and `orca` modules creates a default Cumulus workflow, that can be used with
  Orca for granule recovery.

To customize the deployment for your DAAC, you will need to update
variables and settings in a few of the modules. Specifically:

### daac module

To change which version of the [Cumulus Message
Adapter](https://github.com/nasa/cumulus-message-adapter) is used to
create the Lambda layer used by all Step Function Tasks, modify the
corresponding variable in the `daac/terraform.tfvars` file.

### cumulus module

This module contains the bulk of the DAAC-specific settings. There are
three specific things you should customize:

* `cumulus/terraform.tfvars`: Variables which are likely the same in all
  environments (SIT, UAT, PROD) _and_ which are not 'secrets'.

* `cumulus/variables/*.tfvars`: Each file contains variables specific to
  the corresponding 'maturity' or environment to which you are
  deploying. For example, in `dev.tfvars` you will likely use a
  pre-production `urs_url`, while in the `prod.tfvars` file you will
  specify the production url.

* `cumulus/secrets/*.tfvars`: Like the variables above, these files
  contains *secrets* which are specific to the 'maturity' or environment
  to which you are deploying. Create one file for each environment and
  populate it with secrets. See the example file in this directory for
  a starting point. For example, your `dev` `urs_client_password` is
  likely (hopefully!) different than your `prod` password.

*Important Note*: The secrets files will *not* (and *should not*) be
committed to git. The `.gitignore` file will ignore them by default.

### workflows module

DAAC-specific workflows, lambdas, and configuration will be deployed
by this module. Most workflow development work will be done here.

### orca module

This module will deploy an instance of ORCA ([https://nasa.github.io/cumulus-orca/](Operational Cloud Recovery Archive)).   The module configuration roughly translates to the configuration documentation listed on the ORCA page by exposing all of the variables from that module.  

To configure this module, you will need to customize `orca/variables/*.tfvars` and `orca/secrets/*.tfvars` with appropriate values for each environment you're deploying this module to.  There is an `example.tfvars` file in each folder as a template for the values that are required, for all possible variable options consult the `orca/variables.tf` variables file and/or the ORCA documentation as the majority of these are passed through directly to the ORCA terraform module. 

If using this module, you will need to configure the `cumulus` module's `use_orca` variable to true.  This will cause the `cumulus` module to read the `orca` module outputs to configure Cumulus to use ORCA.   No other configuration is required for Cumulus to use ORCA if using this module.

This module _must_ be deployed _after_ the `daac` and `rds` submodules as it requires information from those modules to deploy, and _before_ the `cumulus` module.

The Makefile supports the following actions for this module:

* orca         - Init and deploy all `orca` stack resources
* plan-orca    - Init and run a `terraform plan` on the `orca` stack to show the
  intended change-set
* destroy-orca - Init, and then destroy existing `orca` module resources.
  Please note this will *not* configure any values derived from this module's
  remote state in the `cumulus` or `orca_recovery_workflow` modules

### orca_recovery_workflow module

This module will deploy a basic granule recovery workflow for use with Cumulus.
It makes use of remote state data from the `cumulus` module and `orca` module
and must be deployed after both.   The deployed `OrcaRecoveryAdapterWorkflow`
can be used via Cumulus collection configuration or Bulk Granule actions to
trigger a recovery for granules as needed. The Makefile supports the following
actions for this module:

* orca_recovery_workflow         - Init and deploy all `orca_recovery_workflow`
  stack resources
* plan-orca_recovery_workflow    - Init and run a `terraform plan` on the
  `orca_recovery_workflow` stack to show the intended change-set
* destroy-orca_recovery_workflow - Init, and then destroy existing
  `orca_recovery_workflow` module resources.

## Deploying Cumulus

See [CIRRUS-core README](https://github.com/asfadmin/CIRRUS-core/blob/master/README.md).

## Developing Cumulus Workflows

There is a sample Workflow Terraform module in the `workflows`
directory. It deploys a `NOP` (No Operation) lambda and workflow. You
can use this as a base for deploying your own workflows. It includes a
Python lambda with unit tests. You can run the tests as shown above.

## Deploying dashboard to S3 bucket

There is a `dashboard` make target which will build and deploy a version of a
Cumulus dashboard to a bucket named `$DEPLOY_NAME-cumulus-$MATURITY-dashboard`
which is created during the cumulus deployment.

To build the dashboard you will first have to clone the source repo from
[https://github.com/nasa/cumulus-dashboard](https://github.com/nasa/cumulus-dashboard)

The dashboard build process requires npm to be installed. Additionally,
since the final step copies data to your dashboard bucket, you need to run
`source env.sh <profile-name> <deploy-name> <maturity>` to set up your AWS
environment prior to running the build process

You need to pass in:
```bash
DASHBOARD_DIR=/path/to/your/dashboard
CUMULUS_API_ROOT="your api root"
DEPLOY_NAME=your deploy name  # Set by env.sh
MATURITY=dev                  # Set by env.sh
```

Example
```bash
source env.sh sbx-profile kb dev
export DASHBOARD_DIR="../cumulus-dashboard"
export CUMULUS_API_ROOT="https://xxx.execute-api.us-west-2.amazonaws.com:8000/dev"
make dashboard
```
