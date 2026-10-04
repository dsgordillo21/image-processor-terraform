

resource "aws_sqs_queue" "image_dlq" {
  name = "${local.name_prefix}-image-dlq"

 
  message_retention_seconds = 1209600

  tags = {
    Name        = "${local.name_prefix}-image-dlq"
    Environment = local.environment
  }
}


resource "aws_sqs_queue" "image_queue" {
  name = "${local.name_prefix}-image-queue"


  visibility_timeout_seconds = 360


  message_retention_seconds = 86400


  receive_wait_time_seconds = 20


  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${local.name_prefix}-image-queue"
    Environment = local.environment
  }
}