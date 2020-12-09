"""
DICPLER = DIsmantlement of Cumlus, Ever Lasting resources
"""

import json
import os
import re

from subprocess import call

import boto3

# TODO: Fix 2020-12-03 23:05:31,272 - Could not execute AWS request: An error occurred
#   (ClusterContainsContainerInstancesException) when calling the DeleteCluster operation:
#   The Cluster cannot be deleted while Container Instances are active or draining.

ARGS = "-d cloudwatch -d ecs -d es -d events -d lambda -d logs -d " \
       "secretsmanager -d sns -d sqs -d states"

EVENT_SOURCE_MAPPING_FILE = "event_source_mapping.json"
BUCKET_FILE = "bucket.txt"
IAM_FILE = "iam.json"


class Dicpelr:
    no_dry_run = True  # TODO: Set Default to == False

    STACK_NAME = f"{os.getenv('DEPLOY_NAME')}-cumulus-{os.getenv('MATURITY')}"
    AWS_REGION = os.getenv("AWS_REGION")
    AWS_PROFILE = os.getenv("AWS_PROFILE")
    AWS_CLI_PRAMS = f"--profile {AWS_PROFILE} --region={AWS_REGION} --tag Deployment={STACK_NAME}"

    lambda_event_source_map_uuids = []
    s3_bucket_names = []
    iam_roles = []

    def __init__(self):
        self._create_iam_file()
        self._set_iam_vars()

        self._create_event_source_mapping_json_file()
        self._set_lambda_event_source_map_uuids_var()

        self._create_s3_bucket_file()
        self._set_s3_bucket_var()

    #   *********************************************************
    #  ******* Start of Functions that Create Files *******
    # *********************************************************
    def _create_event_source_mapping_json_file(self):
        os.system(f"aws lambda --profile {self.AWS_PROFILE} list-event-source-mappings >> {EVENT_SOURCE_MAPPING_FILE}")

    def _create_s3_bucket_file(self):
        os.system(f"aws s3 --profile {self.AWS_PROFILE} ls >> {BUCKET_FILE}")

    def _create_iam_file(self):
        os.system(f"aws iam --profile {self.AWS_PROFILE} list-roles >> {IAM_FILE}")

    #   **************************************************************************
    #  ******* Start of Functions that Convert Files to Vars *******
    # **************************************************************************
    def _set_lambda_event_source_map_uuids_var(self):
        with open(EVENT_SOURCE_MAPPING_FILE) as f:
            data = f.read()
            self.lambda_event_source_map_uuids = json.loads(data)["EventSourceMappings"]
        os.remove(EVENT_SOURCE_MAPPING_FILE)

    def _set_s3_bucket_var(self):
        with open(BUCKET_FILE) as f:
            data = f.read().split()
        os.remove(BUCKET_FILE)

        for bucket in data:
            REGEX = re.compile(f"{self.STACK_NAME}(.*)")
            if re.match(REGEX, bucket):
                self.s3_bucket_names.append(bucket)

    def _set_iam_vars(self):
        with open(IAM_FILE) as f:
            data = f.read()
            self.iam_roles = json.loads(data)["Roles"]
        os.remove(IAM_FILE)

    #   *********************************************************
    #  ******* Start of Functions for Deleting Resources *******
    # *********************************************************
    def delete_all_resources(self):
        pass

    def _run_purge_script(self, args):
        arguments = f"{self.AWS_CLI_PRAMS} {args}"
        if self.no_dry_run:
            arguments = f"{arguments}  --no-dry-run -c false"
        # TODO: Update this to a more elegant solution
        call(f"python3 src/purge.py {self.AWS_CLI_PRAMS} {arguments}".split())

    def delete_iam_roles(self):
        # TODO: Update this to do a similar process to delete_lambda_event_source_mappings()
        # TODO: Fix "An error occurred (DeleteConflict) when calling the DeleteRole operation: Cannot delete entity,
        #  must delete policies first."
        for role in self.iam_roles:
            REGEX = re.compile(f"{self.STACK_NAME}-(.*)")
            role_name = role["RoleName"]
            if re.match(REGEX, role_name):
                print(f"Deleting IAM Role {role_name} in profile {self.AWS_PROFILE}")
                os.system(f"aws iam --profile {self.AWS_PROFILE} delete-role --role-name {role_name}")

    def delete_lambda_event_source_mappings(self):
        for event_map in self.lambda_event_source_map_uuids:
            # (publishGranules|sqs2sf|sfEventSqsToDbRecords)
            REGEX = re.compile(f"arn:aws:(.*){self.STACK_NAME}-(.*)")
            esa = event_map["EventSourceArn"]
            if re.match(REGEX, esa):
                uuid = event_map["UUID"]
                print(f"Deleting {esa} with the UUID: {uuid}")
                os.system(f"aws lambda --profile {self.AWS_PROFILE} delete-event-source-mapping --uuid {uuid}")

    def delete_tea_cloudformation(self):
        CLOUDFORMATION_ARGS = "-d cloudformation"
        self._run_purge_script(CLOUDFORMATION_ARGS)

    def delete_dynamodb_tables(self):
        DYNAMO_DB_ARGS = "-d dynamodb"
        self._run_purge_script(DYNAMO_DB_ARGS)

    def delete_ec2(self):
        EC2_ARGS = "-d ec2"
        self._run_purge_script(EC2_ARGS)

    def delete_s3(self):
        for b in self.s3_bucket_names:
            print(f"Deleting the s3 bucket: {b}")
            s3 = boto3.resource('s3')
            b = s3.Bucket(b)
            b.object_versions.delete()
            b.delete()

    def delete_ecs_cluster_profile(self):
        os.system(f"aws iam --profile {self.AWS_PROFILE} delete-instance-profile "
                  f"--instance-profile-name {self.STACK_NAME}_ecs_cluster_profile")



