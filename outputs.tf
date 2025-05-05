output "sample_bucket_name" {
  description = "Name of the created sample S3 bucket"
  value       = aws_s3_bucket.example.id
}