# This Create ecr
resource "aws_ecr_repository" "clamav" {
  name = "clamav-scanner"
}

resource "aws_iam_role" "scanner_lambda_role" {
  name = "clamav-scanner-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "scanner_lambda_policy" {
  name = "clamav-scanner-policy"
  role = aws_iam_role.scanner_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:PutObjectTagging"
        ]
        Resource = [
          "${aws_s3_bucket.upload-bucket.arn}/*",
          "${aws_s3_bucket.clean-bucket.arn}/*",
          "${aws_s3_bucket.quarantine-bucket.arn}/*",
          "${aws_s3_bucket.scan-results-bucket.arn}/*"
        ]
      }
       {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.scan_queue.arn
      }
    ]
  })
}

resource "aws_lambda_function" "clamav_scanner" {
  function_name = "clamav-scanner"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.clamav.repository_url}:latest"
  role          = aws_iam_role.scanner_lambda_role.arn
  timeout       = 30
  memory_size   = 2048

  architectures = ["x86_64"]
  
  environment {
    variables = {
      CLEAN_BUCKET        = aws_s3_bucket.clean-bucket.bucket
      QUARANTINE_BUCKET   = aws_s3_bucket.quarantine-bucket.bucket
      SCAN_RESULTS_BUCKET = aws_s3_bucket.scan-results-bucket.bucket
    }
  }
}

