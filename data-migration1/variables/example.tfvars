#could not figure out a way to retrieve the provider_kms_key_id using terraform
#however it can be searched for in the console using your delpoyment name

# got this command via cumulus team to retrieve the key
#    aws lambda get-function --function-name "<prefix>-ApiEndpoints" --query 'Configuration.Environment.Variables.provider_kms_key_id'
provider_kms_key_id = "key_id"
