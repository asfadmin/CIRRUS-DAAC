
# CHANGELOG

## Unreleased

## v20.2.0.0
* Upgrade to [Cumulus v20.2.0](https://github.com/nasa/cumulus/release/tag/v20.2.0)
* **NOTE** This version of Cumulus requires changes to the RDS database
* For upgrading the db cluster to PostgreSQL v17 please see the cumulus [instructions](https://nasa.github.io/cumulus/docs/next/upgrade-notes/upgrade-rds-cluster-tf-postgres-17)
  * **NOTE** ORNL observed that no "enable_upgrade" variable remains in the cumulus-rds-tf module. Thus, initial run of 'make rds' will fail while trying to delete the v13 parameter group, but will deploy the v17 parameter group. The remaining instructions can be followed from there.

## v20.1.2.1
* Update Lambda runtime to Python3.11

## v20.1.2.0
* Upgrade to [Cumulus v20.1.2](https://github.com/nasa/cumulus/releases/tag/v20.1.2)
* Update default GitHub branch name to 'main'

## v20.1.1.0
* Upgrade to [Cumulus v20.1.1](https://github.com/nasa/cumulus/releases/tag/v20.1.1)
* **NOTE** This version of Cumulus completely removes Elastic Search including ec2 instances. See release notes for more info.
* Bump dashboard version to minimum required [13.1.0](https://github.com/nasa/cumulus-dashboard/releases/tag/v13.1.0) in deploy.yml

## v20.0.1.0
* Upgrade to [Cumulus v20.0.1](https://github.com/nasa/cumulus/releases/tag/v20.0.1)
* **NOTE** This version of Cumulus fixes bugs as mentioned in the release notes
* Remove `figlet` and `banner` from the `Making ...` banner.
* Remove unused providers `null` and `archive` and bump pinned version of `null`
in `daac` module.
* Add variables to `rds` module:
  * `cluster_instance_count`
  * `lambda_memory_sizes`
  * `lambda_timeouts`
  * `max_capacity`
  * `min_capacity`

## v20.0.0.0
* Upgrade to [Cumulus v20.0.0](https://github.com/nasa/cumulus/releases/tag/v20.0.0)
* **NOTE** This version of Cumulus has a migration of reconcilation reports as mentioned
in the release notes
* Update default CMA version to [2.0.4](https://github.com/nasa/cumulus-message-adapter/releases/tag/v2.0.4)
* Add `make shell` for deploying directly from the host machine rather than the
CIRRUS-core docker image.

## v18.5.2.0
* Upgrade to [Cumulus v18.5.2](https://github.com/nasa/cumulus/releases/tag/v18.5.2)
* ECS cluster upgraded to Amazon Linux 2023

## v18.5.1.0
* Upgrade to [Cumulus v18.5.1](https://github.com/nasa/cumulus/releases/tag/v18.5.1)
  * NOTE: Follow the v2 serverless RDS instructions in the v18.5.0.0 change log
  entry if you have not already upgraded to v2 serverless RDS

## v18.5.0.1
* Add GitHub Actions pipeline for deploying to ASF's Sandbox account
* Add SNAPSHOT_IDENTIFIER to GitHub Actions pipeline for the v18.5.0 upgrade

## v18.5.0.0
* Upgrade to [Cumulus v18.5.0](https://github.com/nasa/cumulus/releases/tag/v18.5.0)
  * NOTE: This release may require manual execution per the v2 serverless RDS
  upgrade. You must also update your `cumulus_rds_db_cluster` secret to include `"rejectUnauthorized": false` BEFORE applying the terraform changes otherwise
  the provision-database lambda will fail to connect to the new RDS.
  * RDS V2 migration [instructions](https://nasa.github.io/cumulus/docs/next/upgrade-notes/serverless-v2-upgrade/)
* RDS module updates.
  * Removal of the following variables:
    * `enable_upgrade` upgrade flag that was used for Aurora v13 migration
    * `parameter_group_family` original parameter group family used for v13 migration
    * `auto_pause` No longer a variable
    * `seconds_until_auto_pause` No longer a variable

## v18.4.0.0
* Upgrade to [Cumulus v18.4.0](https://github.com/nasa/cumulus/releases/tag/v18.4.0)

  *NOTE: This release may require manual execution of the database migrations
  for production environments. The bootstrap lambda will run the migrations
  during deployment automatically, however, if there is too much data in the
  database (as is likely the case in production), the migrations will take
  longer than 15 minutes to run, exceeding the lambda timeout. See the release
  notes for manual migration instructions.*
* Refactored bucket configuration variables to use a single map. You will need
  to merge your `standard_bucket_names`, `protected_bucket_names`,
  `public_bucket_names`, and `workflow_bucket_names` into the new combined
  `bucket_config_base` variable and add maturity specific config to
  `bucket_config`.
* Re-Add manual passing of tags to RDS cumulus module. [CUMULUS-3896](https://bugs.earthdata.nasa.gov/browse/CUMULUS-3896)

## v18.3.3.1
* Add `auto_pause` and `seconds_until_auto_pause` variables from Cumulus 18.3.2
  to `rds` module.

## v18.3.3.0
* Upgrade to [Cumulus v18.3.3](https://github.com/nasa/cumulus/releases/tag/v18.3.3)
* Update Lambda runtime to Python3.9
* Tag resources using the aws provider level `default_tags` configuration

## v18.3.1.0
* Upgrade to [Cumulus v18.3.1](https://github.com/nasa/cumulus/releases/tag/v18.3.1)
* Snyk fixes for dev-requirements.txt
* Add descriptions to daac variables
* Update default CMA version to 2.0.3
* Update example workflow lambda to use python3.8
* Update tflint to [v0.51.1](https://github.com/terraform-linters/tflint/releases/tag/v0.51.1)
* Update Dockerfile to be used for tests only
* Update `daac/s3-replicator`, `rds/rds_cluster`, and `workflows/acme_workflow` source to v18.3.1
* Update Dockerfile:
  * NODE_VERSION="20.x"
  * TERRAFORM_VERSION="1.9.2"
  * AWS_CLI_VERSION="2.17.13"
  * Upgrade to amazonlinux:2023 from amazonlinux:2
  * Use `dnf` instead of `yum`
* Remove `jenkins/`, `scripts/`, and `src/` directories and their contents
* Fix deprecation issues in daac module by using `aws_s3_bucket_logging` resources

## v18.2.0.0
* Upgrade to [Cumulus v18.2.0](https://github.com/nasa/cumulus/releases/tag/v18.2.0)
* update required terraform version to `>= 1.5` in all CIRRUS modules matching the requirements
from the Cumulus application.
* Add `DAR=YES/NO` tags as appropriate for s3 buckets
* expose `enable_upgrade` variable in RDS module to allow for changes required for RDS
upgrade
* updates to RDS for PostgreSQL version 13.12
* update requirements.txt to latest versions of cumulus python modules

## v18.0.0.0
* Upgrade to [Cumulus v18.0.0](https://github.com/nasa/cumulus/releases/tag/v18.0.0)
* This new version of Cumulus uses Terraform v1.5.3, it's possible that DAAC terraform
code may need to be updated.

## v17.0.0.0
* Upgrade to [Cumulus v17.0.0](https://github.com/nasa/cumulus/releases/tag/v17.0.0)
* Upgrade terraform modules to use AWS provider version 5.0
* Remove data-migration1 from repo
* Add terraform resources to create bucket policies allowing CloudFront OAI's
read access to distribution buckets.

## v16.0.0.0

* Upgrade to [Cumulus v16.0.0](https://github.com/nasa/Cumulus/releases/tag/v16.0.0)

## v15.0.3.0

* Upgrade to [Cumulus v15.0.3](https://github.com/nasa/Cumulus/releases/tag/v15.0.3)
* Per [Cumulus v15.0.2](https://github.com/nasa/Cumulus/releases/tag/v15.0.2)
release notes, the new `default_log_retention_days` variable has been exposed in
the Cumulus module to allow daac customization,  default is 30 days (the release
notes name it incorrectly)
* Per [Cumulus v15.0.0](https://github.com/nasa/Cumulus/releases/tag/v15.0.0)
release notes, all ECS tasks should be upgraded to use the `1.9.0` image
* Upgraded the terraform aws version to `>= 3.75.2` to support `nodejs16.x` Lambdas

## v14.1.0.0
* Upgrade to [Cumulus v14.1.0](https://github.com/nasa/Cumulus/releases/tag/v14.1.0)
* Bump RDS engine version to 11.13
* Updated the terraform `aws` provider in the `daac` and `workflows` modules
to match those in the underlying Cumulus modules.
* **Reminder** - this version requires
[Cumulus Dashboard v12.0.0](https://github.com/nasa/cumulus-dashboard/releases/tag/v12.0.0)
* Also, any ECS tasks are required to use the `cumuluss/cumulus-ecs-task:1.8.0`
docker image.  This requirement is listed in the
[Cumulus v11.1.8](https://github.com/nasa/Cumulus/releases/tag/v11.1.8)
breaking changes section.

## v13.3.2.0

* Upgrade to [Cumulus v13.3.2](https://github.com/nasa/Cumulus/releases/tag/v13.3.2)

## v11.1.5.0

* Upgrade to [Cumulus v11.1.5](https://github.com/nasa/Cumulus/releases/tag/v11.1.5)

## v11.1.4.0

* Upgrade to [Cumulus v11.1.4](https://github.com/nasa/Cumulus/releases/tag/v11.1.4)
* Note instructions for creating the `files_granule_cumulus_id_index` in the release
notes if you are continually ingesting data

## v11.1.3.0

* Upgrade to [Cumulus v11.1.3](https://github.com/nasa/Cumulus/releases/tag/v11.1.3)
* Bump RDS engine version to 10.18
* Cumulus dashboard
  * NOTE: You will need to move the dashboard bucket in the daac module with the following command:

  ```bash
  terraform state mv 'aws_s3_bucket.standard-bucket["<prefix>-dashboard"]' aws_s3_bucket.dashboard_bucket
  ```

## v11.1.0.1

* CIRRUS-core: added scripts for Cumulus v11.0.0 post-deployment notes

## v11.1.0.0

* Upgrade to [Cumulus v11.1.0](https://github.com/nasa/Cumulus/releases/tag/v11.1.0)
  * see [Cumulus v11.0.0](https://github.com/nasa/Cumulus/releases/tag/v11.0.0) release notes for required migration
  steps for workflows and collection configurations, as well as lambda executions. If upgrading from CIRRUS v9.9.0.0
  or an earlier version, see the v10.1.2.0 notes as well.

## v10.1.2.0

* Upgrade to [Cumulus v10.1.2](https://github.com/nasa/Cumulus/releases/tag/v10.1.2)
  * see [Cumulus v10.0.0](https://github.com/nasa/Cumulus/releases/tag/v10.0.0) release notes for required migration steps for workflows and collection configurations
    * note that some lambdas and other workflow components may need to be updated for compatibility with the message format changes made in Cumulus v10.0.0, e.g., the dmrpp-generator must be upgraded to [v3.3.0.beta](https://ghrcdaac.github.io/dmrpp-generator/#v330beta)
  * CIRRUS-core includes a script for the migration step on [Cumulus v10.1.1](https://github.com/nasa/Cumulus/releases/tag/v10.1.1)

## v9.9.0.0

* change `daac/s3-replicator.tf` to reference `v9.9.0` terraform module
* change `workflows/main.tf` to reference `v9.9.0` terraform module
* Upgrade hashicorp/aws terraform to `~> v3.70.0`
* Pin hashicorp/archive terraform to `~> v2.2.0`
* Pin hashicrop/null terraform to `~> v2.1` consistently
* Update python worklows requirements.txt to the latest cumulus versions

## v9.2.0.2

* Add GitHub Action configuration for [TFLint](https://github.com/terraform-linters/tflint/)

## v9.2.0.0

* add rds template and data-migration1 variables
* update Makefile to support `make rds`
* update cumulus dev.tfvars to show usage of `rds_connection_heartbeat` variable
* change `daac/s3-replicator.tf` to reference `v9.2.0` terraform module
* change `workflows/main.tf` to reference `v9.2.0` terraform module

## v8.1.1.0

* change `daac/s3-replicator.tf` to reference `v8.1.1` terraform module
* change `workflows/main.tf` to reference `v8.1.1` terraform module

## v8.1.0.0

* change `daac/s3-replicator.tf` to reference `v8.1.0` terraform module
* change `workflows/main.tf` to reference `v8.1.0` terraform module

## v6.0.0.0

* change `daac/s3-replicator.tf` to reference `v6.0.0` terraform module
* change `workflows/main.tf` to reference `v6.0.0` terraform module

## v5.0.1.3

* changes necessary for upgrading Terraform to v0.13.6
  * add versions.tf to daac and workflows modules
  * change the required_providers definition syntax in the main.tf file in both
  the daac and workflows modules
  * two small auto-lint changes to daac/main.tf
  * update Docker file with new Terraform

## v5.0.1.2

* add dummy `data-persistence` variable files

## v5.0.1.0

* change `daac/s3-replicator.tf` to reference `v5.0.1` terraform module
* change `workflows/main.tf` to reference `v5.0.1` terraform module

## v5.0.0.0

* change `daac/s3-replicator.tf` to reference `v5.0.0` terraform module
* change `workflows/main.tf` to reference `v5.0.0` terraform module

## v4.0.0.1

* Upgrade aws terraform provider to 3.19.x and ignore gsfc-ngap tags when deciding what components need to be rebuilt

## v4.0.0.0

* change `daac/s3-replicator.tf` to reference `v4.0.0` terraform module
* change `workflows/main.tf` to reference `v4.0.0` terraform module

## v3.0.1.0

* change `daac/s3-replicator.tf` to reference `v3.0.1` terraform module
* change `workflows/main.tf` to reference `v3.0.1` terraform module
* change `daac/main.tf` to add encryption and tags to bucket creation

## v3.0.0.0

* change `daac/s3-replicator.tf` to reference `v3.0.0` terraform module
* change `workflows/main.tf` to reference `v3.0.0` terraform module
* change `daac/outputs.tf` to output a blank bucket_map_key by default,
   it is needed by the new 3.0.0 Cumulus module in CIRRUS-core
* change `Makefile` to add new `plan-daac` and `plan-workflows` targets
  which can be called from the CIRRUS-Core `Makefile` to run `terraform plan`

## v2.0.7.0

* change `daac/s3-replicator.tf` to reference `v2.0.7` terraform module
* change `workflows/main.tf` to reference `v2.0.7` terraform module

## v2.0.6.0

* change `daac/s3-replicator.tf` to reference `v2.0.6` terraform module
* change `workflows/main.tf` to reference `v2.0.6` terraform module

## v2.0.4.0

* change `daac/s3-replicator.tf` to reference `v2.0.4` terraform module
* change `workflows/main.tf` to reference `v2.0.4` terraform module

## v2.0.3.0

* change `daac/s3-replicator.tf` to reference `v2.0.3` terraform module
* change `workflows/main.tf` to reference `v2.0.3` terraform module
* add some comments to `daac/main.tf` to show how to apply a custom TEA bucket map
* add a sample TEA bucket map
* small amount of terraform formatting

## v2.0.2.0

* change `daac/s3-replicator.tf` to reference `v2.0.2` terraform module
* change `workflows/main.tf` to reference `v2.0.2` terraform module

## v2.0.1.0

* change `daac/s3-replicator.tf` to reference `v2.0.1` terraform module
* change `workflows/main.tf` to reference `v2.0.1` terraform module
* update node version to 12.x in `Dockerfile`

## v1.24.0.0

* change `daac/s3-replicator.tf` to reference `v1.24.0` terraform module
* change `workflows/main.tf` to reference `v1.24.0` terraform module

## v1.23.2.0

* change `workflows/main.tf` to reference `v1.23.2` terraform module
* default to cma v1.3.0
* add s3-replication.tf for metrics replication
* updates for bucket mapping - needed for metrics integration
* updates for `make dashboard`
* updates for jenkins

## v1.22.1.0

* change `workflows/main.tf` to reference `v1.22.1` terraform module

## v1.21.0.0

* change `workflows/main.tf` to reference `v1.21.0` terraform module

## v1.20.0.0

* change `workflows/main.tf` to reference `v1.20.0` terraform module

## v1.19.0.0

* change `workflows/main.tf` to reference `v1.19.0` terraform module

## v1.18.0.1

* Remove TF state migration targets from the Makefile since they are
  no longer needed.

## v1.18.0.0

* No changes necessary to be used with CIRRUS-core v1.18.0.0.

## v1.17.0.0

* Initial full release along with `CIRRUS-core`.
