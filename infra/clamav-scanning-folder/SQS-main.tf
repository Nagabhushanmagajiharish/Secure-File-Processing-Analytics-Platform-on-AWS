# This Create SQS Resource
resource "aws_sqs_queue" "scan_queue" {
  name                       = "clamav-scan-queue"
  visibility_timeout_seconds = 180
}

# This Will sent Notification to SQS
data "aws_iam_policy_document" "scan_queue_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.scan_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.upload-bucket.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "scan_queue_policy" {
  queue_url = aws_sqs_queue.scan_queue.id
  policy    = data.aws_iam_policy_document.scan_queue_policy.json
}

#Connect the incoming bucket to the queue
resource "aws_s3_bucket_notification" "incoming_notifications" {
  bucket = aws_s3_bucket.upload-bucket.id

  queue {
    queue_arn = aws_sqs_queue.scan_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue_policy.scan_queue_policy]
}

# Connect SQS to Lambda
resource "aws_lambda_event_source_mapping" "scan_queue_mapping" {
  event_source_arn = aws_sqs_queue.scan_queue.arn
  function_name    = aws_lambda_function.clamav_scanner.arn
  batch_size       = 1
  enabled          = true
}