urs_url          = "https://uat.urs.earthdata.nasa.gov"
# urs_client_id = see secrets/dev.tfvars

cmr_provider     = "NSIDC_CSBX"
cmr_environment  = "UAT"
cmr_username     = "uat_cumulus_nsidc"

ems_host = ""
ems_port = 22
ems_path = "/"
ems_datasource = "UAT"
ems_private_key = "ems-private.pem"
ems_provider = null
ems_retention_in_days = 30
ems_submit_report = false
ems_username = null

metrics_es_host = null
metrics_es_username = null

launchpad_certificate = "launchpad.pfx"

ecs_cluster_instance_image_id = "ami-09167223e07a89a34"

key_name = "nsidc-sb"
