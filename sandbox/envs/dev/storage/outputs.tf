output "s3_bucket_name" {
  value = aws_s3_bucket.assets.id
}

output "s3_object_name" {
  value = aws_s3_object.sample_conf.id
}
