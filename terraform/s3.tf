resource "aws_s3_bucket" "artifact" {
  bucket = "${var.system}-${var.env}-artifact-bucket"

  tags = {
    Name        = "${var.system}-${var.env}-artifact-bucket"
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "versioning_" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "artifact_policy" {
  bucket = aws_s3_bucket.artifact.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "codepipeline.amazonaws.com",
            "codedeploy.amazonaws.com"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.artifact.arn}/*"
      }
    ]
  })
}