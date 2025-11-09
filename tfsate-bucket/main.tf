resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.tfstate_bucket 
  acl    = "private"

  versioning {
    enabled = true
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_bucket_encryption" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}