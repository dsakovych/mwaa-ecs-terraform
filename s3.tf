resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.prefix

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(local.tags, {
    Name = var.prefix
  })
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "dags" {
  for_each = fileset("dags/", "*.py")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "dags/${each.value}"
  source   = "dags/${each.value}"
  etag     = filemd5("dags/${each.value}")
}

resource "aws_s3_object" "requirements" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "requirements.txt"
  source = "requirements.txt"
  etag   = filemd5("requirements.txt")
}

resource "aws_s3_object" "plugins" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "plugins.zip"
  source = "plugins.zip"
  etag   = filemd5("plugins.zip")
}
