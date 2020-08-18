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
