output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.main.id
}

output "s3_bucket_name" {
  description = "S3 Bucket name"
  value       = aws_s3_bucket.main.bucket
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}