import boto3
import argparse
import logging
from botocore.exceptions import ClientError

'''
usage: purge.py [-h] -p PROFILE -t TAGS
                [-d {cloudformation,cloudwatch,dynamodb,ec2,ecs,es,events,lambda,logs,s3,secretsmanager,sns,sqs,states}]
                [--purge-bucket BUCKET_LIST] [-r REGION] [-c {true,false}]
                [-n] [-b BUCKET]

arguments:
  -h, --help              show this help message and exit

  REQUIRED Params:
  --profile PROFILE       AWS profile to use for cleaning
  --region  REGION        AWS Region to purge from
  --tag     TAGS          'TagName=Value' or 'TagName=Value1,Value2' pairs to filter objects.
                          --tag is required EVEN when doing a specific bucket purge, its just ignored


  OPTIONAL Params:
  --bucket-filter BUCKET  When finding bucket, only search THIS prefix. Optional, but faster!
  --confirm       BOOL    true/false ask to confirm deletes (Default=true)
  --do            TYPES   Only do this type of resource ( one or more )
  --purge-bucket  BUCKET  Skip everything else, just purge this bucket bucket!
  --no-dry-run            Dont do a dry run, ACTUALLY do the delete!

examples:

  # Show what CIRRUS resources willl be deleted. This is just a dry run, so it'll JUST list.
  ./purge.py --profile $AWS_PROFILE --region=$AWS_REGION \
             --tag Deployment=$DEPLOY_NAME --bucket $DEPLOY_NAME --confirm=false

  # Purge all S3 buckets named s3://bb-terraform* and Logs resources with tags Deployment=bb-terraform & Maturity=DEV
  ./purge.py --profile dev-account \
             --tag Deployment=bb-terraform --tag Maturity=DEV \
             --bucket bb-terraform \
             --do s3 --do events --do logs \
             --no-dry-run

  # Purge S3 bucket name s3://bb-terraform-state REGAURDLESS of tags
  ./purge.py --profile dev-account \
             --tag Maturity=DEV \
             --purge-bucket bb-terraform-state \
             --no-dry-run

'''

KNOWN_TYPES = ['cloudformation', 'cloudwatch', 'dynamodb', 'ec2', 'ecs', 'es', 'events', 'kms', 'lambda', 'logs', 's3',
               'secretsmanager', 'sns', 'sqs', 'states']

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--profile", dest="profile", required=True,
                    help="AWS profile to use for cleaning")
parser.add_argument("-t", "--tag", dest="tags", action='append', required=True,
                    help="Filter Tag in the format of 'Key=Value' and 'Key=Value1,Value2'")
parser.add_argument("-d", "--do", dest="do", action='append', choices=KNOWN_TYPES,
                    help="process test types of resources")
parser.add_argument("--purge-bucket", dest="bucket_list", action='append',
                    help="Skip everything else, just purge a bucket!")
parser.add_argument("-r", "--region", dest="region", default="us-east-1",
                    help="aws region to inspect")
parser.add_argument("-c", "--confirm", dest="confirm", default="true", choices=['true', 'false'],
                    help="Ask to delete objects before proceding")
parser.add_argument("-n", "--no-dry-run", dest="dryrun", action='store_false',
                    help="Not a dry run, ACTUALLY do the delete")
parser.add_argument("-b", "--bucket-filter", dest="bucket", default=None,
                    help="Bucket filter to use when searching bucket tags")
args = parser.parse_args()

logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
log = logging.getLogger(__name__)

for tag in args.tags:
    if not len(tag.split('=')) == 2:
        log.error(f"Tag '{tag}' is not valid, it should be 'Key=Value'")
        exit(-1)

filter_tags = [{'Key': t[0], 'Values': t[1].split(',')} for t in [tag.split('=') for tag in args.tags]]
log.info(f"Filter Tags: {filter_tags}")

log.info(f"Connecting to AWS Profile {args.profile}")
session = boto3.Session(profile_name=args.profile, region_name=args.region)
rgt_client = session.client('resourcegroupstaggingapi')  # , region_name=args.region)

unsupported_objects = []

def get_confirmation(resource):
    if args.confirm == 'false':
        log.debug("Skipping user confirmation because ---confirm=false")
        return True

    resp = input(f"Confirm deletion of {resource['Class']} {resource['Type']} [yes/no]:")
    if resp == 'yes':
        return True
    if resp.lower() in ('no', 'n'):
        log.warning(f"Aborting deletion of {resource['Class']} {resource['Type']}")
        return False

    # Try again
    log.warning(f"Response '{resp}' is not valid. Confirmation MUST be 'yes' or 'no'")
    return get_confirmation(resource)


#########
# Deletion handlers
def delete_api_gateway(resource):
    api_client = session.client('apigateway')

    # Object Specifics
    resource['RestApiId'] = resource['Type'].split('/')[2]
    log.info(resource)

    if get_confirmation(resource):
        log.info(f"Deleting API gateway REST API {resource['Arn']}")
        if not args.dryrun:
          api_client.delete_rest_api(restApiId=resource['RestApiId'])

def delete_lambda(resource):
    l_client = session.client('lambda')

    # Object Specifics
    resource['SubType'] = resource['Type'].split(':')[0]
    resource['Name'] = "/".join(resource['Type'].split(':')[1:])

    if resource['SubType'] == 'function':
        delete_lambda_function(resource, l_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"Lambda {resource['SubType']} deletion not yet supported")


def delete_lambda_function(resource, l_client):
    if get_confirmation(resource):
        log.info(f"Deleting Lambda Function {resource['Name']}")
        if not args.dryrun:
            l_client.delete_function(FunctionName=resource['Arn'])


def delete_events(resource):
    e_client = session.client('events')

    # Object Specifics
    resource['SubType'] = resource['Type'].split('/')[0]
    resource['Name'] = resource['Type'].split('/')[1]

    if resource['SubType'] == 'rule':
        delete_events_rule(resource, e_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"Events {resource['SubType']} deletion not yet supported")


def delete_events_rule(resource, e_client):
    if get_confirmation(resource):
        log.info(f"Deleting CloudWatch Event Rule {resource['Name']}")
        if not args.dryrun:
            for target in e_client.list_targets_by_rule(Rule=resource['Name'])['Targets']:
                log.info(f"Removing Rule {resource['Name']} Target {target['Id']} ")
                e_client.remove_targets(Rule=resource['Name'], Ids=[target['Id']])

            e_client.delete_rule(Name=resource['Name'])


def delete_ecs(resource):
    ecs_client = session.client('ecs')

    # Object Specifics
    resource['SubType'] = resource['Type'].split('/')[0]
    resource['Name'] = resource['Type'].split('/')[1]

    if resource['SubType'] == 'task-definition':
        resource['Version'] = resource['Name'].split(':')[1]
        resource['Name'] = resource['Name'].split(':')[0]
        delete_ecs_task(resource, ecs_client)
    elif resource['SubType'] == 'cluster':
        delete_ecs_cluster(resource, ecs_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"ECS {resource['SubType']} deletion not yet supported")


def delete_ecs_task(resource, ecs_client):
    if get_confirmation(resource):
        log.info(f"Deleting ECS Task Definition {resource['Name']} Version {resource['Version']}")
        if not args.dryrun:
            ecs_client.deregister_task_definition(taskDefinition=resource['Arn'])


def delete_ecs_cluster(resource, ecs_client):
    if get_confirmation(resource):
        log.info(f"Deleting ECS Cluster {resource['Name']}")
        if not args.dryrun:
            ecs_client.delete_cluster(cluster=resource['Arn'])


def delete_ec2(resource):
    ec2_client = session.client('ec2')
    resource['SubType'] = resource['Type'].split('/')[0]
    resource['Name'] = "/".join(resource['Type'].split('/')[1:])

    if resource['SubType'] == 'instance':
        delete_ec2_instance(resource, ec2_client)
    elif resource['SubType'] == 'security-group':
        delete_ec2_sg(resource, ec2_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"EC2 {resource['SubType']} deletion not yet supported")


def delete_ec2_instance(resource, ec2_client):
    if get_confirmation(resource):
        log.info(f"Terminating ec2 Instance {resource['Name']}")
        if not args.dryrun:
            ec2_client.terminate_instances(InstanceIds=[resource['Name']], DryRun=False)
        else:
            ec2_client.terminate_instances(InstanceIds=[resource['Name']], DryRun=True)


def delete_ec2_sg(resource, ec2_client):
    if get_confirmation(resource):
        log.info(f"Terminating ec2 Security Group {resource['Name']}")
        if not args.dryrun:
            log.warning(f"This will probably fail because of unremovable attached Network interface ID (ENI-*)")
            ec2_client.delete_security_group(GroupId=resource['Name'], DryRun=False)
        else:
            ec2_client.delete_security_group(GroupId=resource['Name'], DryRun=True)


def delete_cloudwatch(resource):
    cw_client = session.client('cloudwatch')

    # Object Specifics
    resource['SubType'] = resource['Type'].split(':')[0]
    resource['Name'] = resource['Type'].split(':')[1]

    if resource['SubType'] == 'alarm':
        delete_cloudwatch_alarm(resource, cw_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"Cloudwatch {resource['SubType']} deletion not yet supported")


def delete_cloudwatch_alarm(resource, cw_client):
    if get_confirmation(resource):
        log.info(f"Deleting CloudWatch Alarm {resource['Name']}")
        if not args.dryrun:
            cw_client.delete_alarms(AlarmNames=[resource['Name']])


def delete_cloudformation(resource):
    cf_client = session.client('cloudformation')

    # Object Specifics
    resource['SubType'] = resource['Type'].split('/')[0]
    resource['Name'] = resource['Type'].split('/')[1]

    if resource['SubType'] == 'stack':
        delete_cloudformation_stack(resource, cf_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"Cloudformation {resource['SubType']} deletion not yet supported")


def delete_cloudformation_stack(resource, cf_client):
    if get_confirmation(resource):
        log.info(f"Deleting Cloudformation stack {resource['Name']}")
        if not args.dryrun:
            cf_client.delete_stack(StackName=resource['Name'])


def delete_dynamodb(resource):
    db_client = session.client('dynamodb')

    # Object Specifics
    resource['SubType'] = resource['Type'].split('/')[0]
    resource['Name'] = resource['Type'].split('/')[1]

    if resource['SubType'] == 'table':
        delete_dynamodb_table(resource, db_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"DynamoDB {resource['SubType']} deletion not yet supported")


def delete_dynamodb_table(resource, db_client):
    if get_confirmation(resource):
        log.info(f"Deleting DynamoDB Table {resource['Name']}")
        if not args.dryrun:
            db_client.delete_table(TableName=resource['Name'])


def delete_es(resource):
    es_client = session.client('es')

    # Object Specifics
    resource['SubType'] = resource['Type'].split('/')[0]
    resource['Name'] = resource['Type'].split('/')[1]

    if resource['SubType'] == 'domain':
        delete_es_domain(resource, es_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"ElasticSearch {resource['SubType']} deletion not yet supported")


def delete_es_domain(resource, es_client):
    if get_confirmation(resource):
        log.info(f"Deleting ElasticSearch Domain {resource['Name']}")
        if not args.dryrun:
            es_client.delete_elasticsearch_domain(DomainName=resource['Name'])

def delete_kms(resource):
  kms_client = session.client('kms')

  if get_confirmation(resource):
    log.info(f"Scheduling KMS key {resource['Arn']} deletion in 7 days")
    if not args.dryrun:
      try:
        kms_client.schedule_key_deletion(
          KeyId=resource['Arn'],
          PendingWindowInDays=7
        )
      except ClientError as e:
        if 'pending deletion' not in str(e):
          log.warning(f"Could not execute AWS request: {e}")

def delete_logs(resource):
    logs_client = session.client('logs')

    # Object Specifics
    resource['SubType'] = resource['Type'].split(':')[0]
    resource['Name'] = resource['Type'].split(':')[1]

    if resource['SubType'] == 'log-group':
        delete_logs_group(resource, logs_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"CloudWatch Logs {resource['SubType']} deletion not yet supported")


def delete_logs_group(resource, logs_client):
    if get_confirmation(resource):
        log.info(f"Deleting CloudWatch Logs Group {resource['Name']}")
        if not args.dryrun:
            logs_client.delete_log_group(logGroupName=resource['Name'])


def delete_sm(resource):
    sm_client = session.client('secretsmanager')

    # Object Specifics
    resource['SubType'] = resource['Type'].split(':')[0]
    resource['Name'] = resource['Type'].split(':')[1]

    if resource['SubType'] == 'secret':
        delete_sm_secret(resource, sm_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"Secrets Manager {resource['SubType']} deletion not yet supported")


def delete_sm_secret(resource, sm_client):
    if get_confirmation(resource):
        log.info(f"Deleting Secrets Manager Secret {resource['Name']}")
        if not args.dryrun:
            sm_client.delete_secret(SecretId=resource['Arn'], ForceDeleteWithoutRecovery=True)


def delete_state(resource):
    sfn_client = session.client('stepfunctions')

    # Object Specifics
    resource['SubType'] = resource['Type'].split(':')[0]
    resource['Name'] = resource['Type'].split(':')[1]

    if resource['SubType'] == 'stateMachine':
        delete_state_machine(resource, sfn_client)
    elif resource['SubType'] == 'activity':
        delete_state_activity(resource, sfn_client)
    else:
        unsupported_objects.append(resource)
        log.warning(f"State Machine {resource['SubType']} deletion not yet supported")

def delete_state_activity(resource, sfn_client):
    if get_confirmation(resource):
        log.info(f"Deleting State Machine activity {resource['Name']}")
        if not args.dryrun:
            sfn_client.delete_activity(activityArn=resource['Arn'])

def delete_state_machine(resource, sfn_client):
    if get_confirmation(resource):
        log.info(f"Deleting State Machine {resource['Name']}")
        if not args.dryrun:
            sfn_client.delete_state_machine(stateMachineArn=resource['Arn'])


def delete_sns(resource):
    # We only gets Topics!

    if get_confirmation(resource):
        log.info(f"Deleting SNS Topic {resource['Type']}")
        if not args.dryrun:
            sns_client = session.client('sns')
            sns_client.delete_topic(TopicArn=resource['Arn'])


def delete_sqs(resource):
    # We only gets Queues!

    if get_confirmation(resource):
        log.info(f"Deleting SQS Queue {resource['Type']}")
        if not args.dryrun:
            sqs_client = session.client('sqs')
            queue_url = sqs_client.get_queue_url(QueueName=resource['Type'])['QueueUrl']
            sqs_client.delete_queue(QueueUrl=queue_url)


def delete_s3(resource):
    # We should ONLY get buckets here.

    if not get_confirmation(resource):
        return
    if args.dryrun:
        return

    bucket_name = resource['Type']
    bucket = session.resource('s3').Bucket(bucket_name)
    log.info(f"Removing all objects from S3 Bucket {bucket_name}")
    # Purge non-Versioned objects
    bucket.objects.all().delete()
    # Purge Versioned objects
    delete_bucket_completely(bucket_name)
    log.info(f"Removing S3 Bucket {bucket_name}")
    bucket.delete()


def delete_bucket_completely(bucket_name):
    client = session.client('s3')
    response = client.list_object_versions(Bucket=bucket_name)
    for type in ['Versions', 'DeleteMarkers']:
        if not type in response:
            continue
        for version in response[type]:
            log.info(f"Removing s3://{bucket_name}/{version['Key']} Version {version['VersionId']}")
            client.delete_object(Bucket=bucket_name, Key=version['Key'], VersionId=version['VersionId'])


def get_all_versions(bucket, filename):
    s3 = session.client('s3')
    keys = ["Versions", "DeleteMarkers"]
    results = []
    for k in keys:
        log.info(s3.list_object_versions(Bucket=bucket))
        response = s3.list_object_versions(Bucket=bucket)[k]
        to_delete = [r["VersionId"] for r in response if r["Key"] == filename]
    results.extend(to_delete)
    return results


def get_bucket_arn(name, region):
    if region == 'us-east-1':
        return f"arn:aws:s3:::{name}"

    return f"arn:aws:s3:{region}::{name}"


def get_in_region_buckets():
    found_arns = []
    for bucket in session.resource('s3').buckets.all():
        if args.bucket and not bucket.name.startswith(args.bucket):
            continue

        region = session.client("s3").get_bucket_location(Bucket=bucket.name)['LocationConstraint']
        region = 'us-east-1' if not region else region
        if not region == args.region:
            log.info(f"{bucket.name} is in {region} not {args.region}")
            continue

        log.info(f"checking bucket {bucket.name} in region {region} for Tags")
        try:
            tags = session.client('s3').get_bucket_tagging(Bucket=bucket.name)['TagSet']
            for tf in filter_tags:
                this_tag = next((item for item in tags if item['Key'] == tf['Key']), None)
                if this_tag and this_tag['Value'] in tf['Values']:
                    log.info(
                        f"Found Tag {this_tag['Key']}=={this_tag['Value']} Matches filter {tf['Key']}=={tf['Values']}")
                    found_arns.append(get_bucket_arn(bucket.name, region))

        except ClientError:
            continue

    return found_arns


def get_all_tagged_arns(filter_tags):
    tagged_items = rgt_client.get_resources(TagFilters=filter_tags)
    arns = [tagged_item['ResourceARN'] for tagged_item in tagged_items['ResourceTagMappingList']]

    while 'PaginationToken' in tagged_items and tagged_items['PaginationToken']:
        tagged_items = rgt_client.get_resources(TagFilters=filter_tags, PaginationToken=tagged_items['PaginationToken'])
        arns.extend([tagged_item['ResourceARN'] for tagged_item in tagged_items['ResourceTagMappingList']])

    return arns


if args.dryrun:
    log.info("##############################################################################")
    log.info("                      THIS IS ONLY A DRY RUN!!!                               ")
    log.info("##############################################################################")

#########
# JUST remove a specific set of buckets
if args.bucket_list:
    log.warning("Only purging buckets, this **IS NOT** tag filter!")
    for bucket in args.bucket_list:
        try:
            delete_s3({'Class': 's3', 'Type': bucket, 'Arn': get_bucket_arn(bucket, args.region)})
        except ClientError as e:
            log.error(f"Could not remove S3 Bucket {bucket}: {e}")
    exit(0)

#########
# Get tagged resources
arns = get_all_tagged_arns(filter_tags)

# bucket tags need to be fetched differently:
for bucket_arn in get_in_region_buckets():
    if bucket_arn not in arns:
        log.info(f"Adding bucket {bucket_arn} to arns")
        arns.append(bucket_arn)

resources = [{'Class': o[2], 'Type': ':'.join(o[5:]), 'Arn': ":".join(o)} for o in [arn.split(':') for arn in arns]]

if args.do:
    log.info(f"Only processing types: {args.do}")

# reorder resource list to process EC2 resources last, since their deletion
# is usually blocked until after resources are deleted
non_ec2_resources = [resource for resource in resources if resource['Class'] != 'ec2']
ec2_resources = [resource for resource in resources if resource['Class'] == 'ec2']
all_resources = non_ec2_resources + ec2_resources

for resource in all_resources:
    if args.do and resource['Class'] not in args.do:
        continue

    try:
        if resource['Class'] == 'lambda':
            delete_lambda(resource)
        elif resource['Class'] == 'events':
            delete_events(resource)
        elif resource['Class'] == 'ecs':
            delete_ecs(resource)
        elif resource['Class'] == 'ec2':
            delete_ec2(resource)
        elif resource['Class'] == 'apigateway':
            delete_api_gateway(resource)
        elif resource['Class'] == 'cloudwatch':
            delete_cloudwatch(resource)
        elif resource['Class'] == 'cloudformation':
            delete_cloudformation(resource)
        elif resource['Class'] == 'dynamodb':
            delete_dynamodb(resource)
        elif resource['Class'] == 'es':
            delete_es(resource)
        elif resource['Class'] == 's3':
            delete_s3(resource)
        elif resource['Class'] == 'kms':
            delete_kms(resource)
        elif resource['Class'] == 'logs':
            delete_logs(resource)
        elif resource['Class'] == 'secretsmanager':
            delete_sm(resource)
        elif resource['Class'] == 'sns':
            delete_sns(resource)
        elif resource['Class'] == 'sqs':
            delete_sqs(resource)
        elif resource['Class'] == 'states':
            delete_state(resource)
        else:
            unsupported_objects.append(resource)
            log.warning(f"Cannot clean unsupported object type: {resource['Class']}")
    except ClientError as e:
        if 'DryRunOperation' not in str(e):
            log.warning(f"Could not execute AWS request: {e}")

if len(unsupported_objects):
    log.warning("Found these unsupported objects:")
    for resource in unsupported_objects:
        log.warning(f"{resource['Class']:16} {resource['Type']}")
