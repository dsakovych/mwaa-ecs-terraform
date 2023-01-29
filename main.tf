data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  tags = {
    Author = "Dima S."
  }
}


resource "aws_ssm_parameter" "cluster_name" {
  name        = "/mwaa/ecs/cluster"
  description = "ECS cluster name"
  type        = "String"
  value       = "${var.prefix}-ecs-cluster"
  overwrite = true
}

resource "aws_ssm_parameter" "task_definition" {
  name        = "/mwaa/ecs/task_definition"
  description = "ECS task definition"
  type        = "String"
  value       = "${var.prefix}-ecs-service"
  overwrite = true
}

resource "aws_ssm_parameter" "private_subnets" {
  name        = "/mwaa/vpc/private_subnets"
  description = "Private subnets for mwaa"
  type        = "String"
  value       = join(",", aws_subnet.private_subnets.*.id)
  overwrite = true
}

resource "aws_ssm_parameter" "security_group" {
  name        = "/mwaa/vpc/security_group"
  description = "Security group ID for mwaa"
  type        = "String"
  value       = aws_security_group.mwaa.id
}

resource "aws_ssm_parameter" "log_group" {
  name        = "/mwaa/cw/log_group"
  description = "CW log_group for mwaa"
  type        = "String"
  value       = "/ecs/"
}

resource "aws_ssm_parameter" "log_stream" {
  name        = "/mwaa/cw/log_stream"
  description = "CW log_stream for mwaa"
  type        = "String"
  value       = "/ecs/${var.prefix}-ecs-service"
}
