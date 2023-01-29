output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID of the VPC."
}

output "public_subnets_ids" {
  value       = aws_subnet.public_subnets.*.id
  description = "List with the IDs of the public subnets."
}

output "private_subnets_ids" {
  value       = aws_subnet.private_subnets.*.id
  description = "List with the IDs of the private subnets."
}

output "security_group_id" {
  value       = aws_security_group.mwaa.id
  description = "ID of the Security Group"
}

output "s3_bucket_id" {
  value       = aws_s3_bucket.s3_bucket.id
  description = "ID of S3 bucket."
}

output "mwaa_environment_arn" {
  value       = aws_mwaa_environment.mwaa_environment.arn
  description = "ARN of MWAA environment."
}

output "iam_role_arn" {
  value       = aws_iam_role.iam_role.arn
  description = "ARN of MWAA environment."
}