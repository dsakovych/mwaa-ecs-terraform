### Terraform setup for MWAA with ECS executor

Variables example:
```
access_key = "<ACCESS_KEY>"
secret_key = "<SECRET_KEY>"
region     = "eu-central-1"


prefix   = "yp-mwaa"
vpc_cidr = "10.178.0.0/16"
public_subnet_cidrs = [
  "10.178.10.0/24",
  "10.178.11.0/24"
]
private_subnet_cidrs = [
  "10.178.20.0/24",
  "10.178.21.0/24"
]
```

#### TODO:
- Problem with ecs execution access role:  
```botocore.exceptions.ClientError: An error occurred (AccessDenied) when calling the AssumeRole operation: User: arn:aws:iam::107304754613:user/terraform is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::107304754613:role/yp-mwaa-role```