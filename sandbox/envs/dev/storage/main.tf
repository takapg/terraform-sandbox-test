resource "aws_s3_bucket" "assets" {
  bucket = "${var.product}-${var.env}-assets"
}

resource "aws_s3_bucket_acl" "assets" {
  bucket = aws_s3_bucket.assets.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "name" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "sample_conf" {
  bucket  = aws_s3_bucket.assets.id
  key     = "sample_conf.yaml"
  content = <<EOF
sample_key: sample_value
EOF
}
