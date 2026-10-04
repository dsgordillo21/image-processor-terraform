# ==========================================
# S3 Bucket
# ==========================================

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "images" {
  bucket = "${local.name_prefix}-images-${data.aws_caller_identity.current.account_id}"

  # Permite eliminar el bucket con terraform destroy
  # aunque contenga archivos de las pruebas.
  force_destroy = true

  tags = {
    Name        = "${local.name_prefix}-images"
    Environment = local.environment
  }
}

# S3 Versioning


resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ==========================================
# S3 Encryption
# ==========================================

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==========================================
# S3 Lifecycle
# ==========================================

resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    id     = "expire-uploads"
    status = "Enabled"

    filter {
      prefix = "uploads/"
    }

    expiration {
      days = 30
    }
  }

  rule {
    id     = "expire-processed"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    expiration {
      days = 90
    }
  }
}