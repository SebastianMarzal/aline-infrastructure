import boto3
import logging
from datetime import datetime

ec2_client = boto3.client('ec2')
ecs_client = boto3.client('ecs')
eks_client = boto3.client('eks')
elbv2_client = boto3.client('elbv2')
rds_client = boto3.client('rds')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def stop_ec2_instances():
    response = ec2_client.describe_instances()
    instances = response['Reservations'][0]['Instances']
    instance_ids = list()
    for instance in instances:
        instance_id = instance['InstanceId']
        state = instance['State']['Name']
        if state != "stopped":
            logger.info("Stopping EC2 instance {}.".format(instance_id))
            instance_ids.append(instance_id)
    if instance_ids:
        ec2_client.stop_instances(InstanceIds = instance_ids)

def delete_ecs_services():
    response = ecs_client.list_clusters()
    cluster_arns = response['clusterArns']
    for cluster_arn in cluster_arns:
        response = ecs_client.list_services(cluster = cluster_arn)
        service_arns = response['serviceArns']
        for service_arn in service_arns:
            logger.info("Deleting service {} in ECS cluster {}.".format(service_arn, cluster_arn))
            ecs_client.delete_service(cluster = cluster_arn, service = service_arns)

def delete_eks_clusters():
    response = eks_client.list_clusters()
    clusters = response['clusters']

    for cluster in clusters:
        logger.info("Deleting EKS cluster {}.".format(cluster))
        eks_client.delete_cluster(name = cluster)

def delete_load_balancers():
    response = elbv2_client.describe_load_balancers()
    load_balancers = response['LoadBalancers']
    for load_balancer in load_balancers:
        load_balancer_arn = load_balancer['LoadBalancerArn']
        logger.info("Deleting load balancer {}.".format(load_balancer_arn))
        elbv2_client.delete_load_balancer(LoadBalancerArn = load_balancer_arn)

def stop_rds_instances():
    response = rds_client.describe_db_instances()
    db_instances = response['DBInstances']
    for db_instance in db_instances:
        db_instance_identifier = db_instance['DBInstanceIdentifier']
        logger.info("Deleting RDS instance {}.".format(db_instance_identifier))
        rds_client.delete_db_instance(DBInstanceIdentifier = db_instance_identifier)

def lambda_handler(event, context):
    logger.info("Event:" + str(event))
    logger.info("Cleanup process was triggered at {}.".format(datetime.now()))
    stop_ec2_instances()
    delete_ecs_services()
    delete_eks_clusters()
    delete_load_balancers()
    stop_rds_instances()