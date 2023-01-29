resource "aws_mwaa_environment" "mwaa_environment" {
  source_bucket_arn     = aws_s3_bucket.s3_bucket.arn
  dag_s3_path           = "dags"
  requirements_s3_path  = "requirements.txt"
  plugins_s3_path       = "plugins.zip"
  execution_role_arn    = aws_iam_role.iam_role.arn
  name                  = var.prefix
  max_workers           = var.mwaa_max_workers
  airflow_version       = "2.2.2"
  webserver_access_mode = "PUBLIC_ONLY"

  depends_on = [aws_s3_bucket.s3_bucket, aws_vpc.vpc]

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = aws_subnet.private_subnets.*.id
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }
}
