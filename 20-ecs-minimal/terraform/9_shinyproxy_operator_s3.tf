resource "random_string" "bucket-suffix" {
  # required to make bucket name unique
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "shinyproxy-operator-bucket" {
  bucket = "${var.cluster_name}-${random_string.bucket-suffix.result}"

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "secure" {
  bucket = aws_s3_bucket.shinyproxy-operator-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "secure" {
  bucket = aws_s3_bucket.shinyproxy-operator-bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure" {
  bucket = aws_s3_bucket.shinyproxy-operator-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

data "aws_iam_policy_document" "secure_tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.shinyproxy-operator-bucket.arn,
      "${aws_s3_bucket.shinyproxy-operator-bucket.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "secure" {
  bucket = aws_s3_bucket.shinyproxy-operator-bucket.id
  policy = data.aws_iam_policy_document.secure_tls_only.json

  depends_on = [aws_s3_bucket_public_access_block.secure]
}
