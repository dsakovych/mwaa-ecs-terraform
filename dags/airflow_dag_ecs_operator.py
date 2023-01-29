from datetime import timedelta

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.contrib.operators.ecs_operator import ECSOperator

import boto3

ssm = boto3.client('ssm')

dag = DAG(
    "example_ecs_operator",
    description="Sample of ECS operator in Amazon MWAA (https://medium.com/@sohflp)",
    default_args={
        "start_date": days_ago(2),
        "owner": "Dima S.",
        'email': ['airflow@example.com'],
        'email_on_failure': False,
        'email_on_retry': False,
    },
    max_active_runs=1,
    dagrun_timeout=timedelta(minutes=120)
)

# Get ECS configuration from SSM parameters
ecs_cluster               = str(ssm.get_parameter(Name='/mwaa/ecs/cluster', WithDecryption=True)['Parameter']['Value'])
ecs_task_definition       = str(ssm.get_parameter(Name='/mwaa/ecs/task_definition', WithDecryption=True)['Parameter']['Value'])
ecs_subnets               = str(ssm.get_parameter(Name='/mwaa/vpc/private_subnets', WithDecryption=True)['Parameter']['Value'])
ecs_security_group        = str(ssm.get_parameter(Name='/mwaa/vpc/security_group', WithDecryption=True)['Parameter']['Value'])
ecs_awslogs_group         = str(ssm.get_parameter(Name='/mwaa/cw/log_group', WithDecryption=True)['Parameter']['Value'])
ecs_awslogs_stream_prefix = str(ssm.get_parameter(Name='/mwaa/cw/log_stream', WithDecryption=True)['Parameter']['Value'])

# Run Docker container via ECS operator
task_ecs_operator = ECSOperator(
    task_id="ecs_operator",
    dag=dag,
    aws_conn_id="aws_ecs",
    cluster=ecs_cluster,
    task_definition=ecs_task_definition,
    launch_type="FARGATE",
    overrides={
        "containerOverrides": [
            {
                "name": "hello-world",
                "command": ["/hello"],
            },
        ],
    },
    network_configuration={
        "awsvpcConfiguration": {
            "securityGroups": [ecs_security_group],
            "subnets": ecs_subnets.split(",") ,
        },
    },
    awslogs_group=ecs_awslogs_group,
    awslogs_stream_prefix=ecs_awslogs_stream_prefix
)

task_ecs_operator