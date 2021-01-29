
# CHANGELOG

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
