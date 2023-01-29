resource "aws_iam_role" "iam_role" {
  name = "${var.prefix}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "airflow-env.amazonaws.com",
            "airflow.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = var.prefix
  })
}

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    sid       = ""
    actions   = ["airflow:PublishMetrics"]
    effect    = "Allow"
    resources = ["arn:aws:airflow:${var.region}:${local.account_id}:environment/${var.prefix}"]
  }

  statement {
    actions = ["s3:ListAllMyBuckets"]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

  statement {
    actions   = ["logs:DescribeLogGroups"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:DescribeLogGroups"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.region}:${local.account_id}:log-group:airflow-${var.prefix}*",
                 "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/ecs/hello-world:log-stream:/airflow/*",
                 "arn:aws:logs:${var.region}:${local.account_id}:log-group:/ecs/${var.prefix}-ecs-service:*"]
  }

  statement {
    actions   = ["cloudwatch:PutMetricData"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    effect    = "Allow"
    resources = ["arn:aws:sqs:${var.region}:*:airflow-celery-*"]
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    effect        = "Allow"
    not_resources = ["arn:aws:kms:*:${local.account_id}:key/*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values = [
        "sqs.${var.region}.amazonaws.com"
      ]
    }
  }
  #####
  statement {
    actions = [
      "ecs:RunTask",
      "ecs:DescribeTasks"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = ""
    actions = [
      "iam:PassRole"
    ]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
  statement {
    actions = [
      "ssm:getParameter"
    ]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${var.region}:${local.account_id}:parameter/mwaa/ecs/cluster",
                "arn:aws:ssm:${var.region}:${local.account_id}:parameter/mwaa/ecs/task_definition",
                "arn:aws:ssm:${var.region}:${local.account_id}:parameter/mwaa/vpc/private_subnets",
                "arn:aws:ssm:${var.region}:${local.account_id}:parameter/mwaa/vpc/security_group",
                "arn:aws:ssm:${var.region}:${local.account_id}:parameter/mwaa/cw/log_group",
                "arn:aws:ssm:${var.region}:${local.account_id}:parameter/mwaa/cw/log_stream"]
  }
  statement {
    actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name = "${var.prefix}-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.iam_policy_document.json
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}


# ------------------------------------------- #

#resource "aws_iam_role" "ecs_task_execution_role" {
#  name = "${var.prefix}-ecs-execution-role"
#
#  assume_role_policy = <<EOF
#{
# "Version": "2012-10-17",
# "Statement": [
#   {
#     "Action": "sts:AssumeRole",
#     "Principal": {
#       "Service": "ecs-tasks.amazonaws.com"
#     },
#     "Effect": "Allow",
#     "Sid": ""
#   }
# ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
#  role       = aws_iam_role.ecs_task_execution_role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#}

######

#resource "aws_iam_role" "ecs_task_iam_role" {
#  name = "${var.prefix}-ecs-task-execution-role"
#  description = "Allow ECS tasks to access AWS resources"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "",
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "ecs-tasks.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}
#
#
#resource "aws_iam_policy" "ecs_task_policy" {
#  name = "${var.prefix}-ecs-task-execution-policy"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "ecr:GetAuthorizationToken",
#        "ecr:BatchCheckLayerAvailability",
#        "ecr:GetDownloadUrlForLayer",
#        "ecr:BatchGetImage"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#    },
#    {
#      "Action": [
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy_attachment" "attach_policy" {
#  role       = aws_iam_role.ecs_task_iam_role.name
#  policy_arn = aws_iam_policy.ecs_task_policy.arn
#}
