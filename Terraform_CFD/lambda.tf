resource "aws_lambda_function" "tmp_files_cleaner" {
  filename         = "tmp_files_cleaner.zip"
  function_name    = "tmp_files_cleaner"
  role             = aws_iam_role.tmp_files_cleaner.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("tmp_files_cleaner.zip")

  environment {
    variables = {
      BUCKET_NAME = var.cloudfront_distribution_bucket_name
      TTL         = "172800"  # 48 hours in seconds
    }
  }
}

resource "aws_iam_role" "tmp_files_cleaner" {
  name = "tmp_files_cleaner_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "tmp_files_cleaner" {
  name        = "tmp_files_cleaner_policy"
  policy      = data.aws_iam_policy_document.tmp_files_cleaner.json
}

data "aws_iam_policy_document" "tmp_files_cleaner" {
  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "${aws_s3_bucket.lower_tier_bucket.arn}",
      "${aws_s3_bucket.lower_tier_bucket.arn}/*",
    ]
  }

  statement {
    actions = ["s3:DeleteObject"]
    resources = [
      "${aws_s3_bucket.lower_tier_bucket.arn}/*",
    ]
    condition {
      test     = "DateLessThan"
      variable = "s3:ObjectLastModified"
      values   = ["${aws_lambda_invocation.last_modified.timestamp + var.ttl}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "tmp_files_cleaner" {
  policy_arn = aws_iam_policy.tmp_files_cleaner.arn
  role       = aws_iam_role.tmp_files_cleaner.name
}