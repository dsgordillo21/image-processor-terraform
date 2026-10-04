resource "aws_lambda_function" "crop" {
  filename      = "../lambda/crop/crop-lambda.zip"
  function_name = "${local.name_prefix}-crop"
  role          = aws_iam_role.lambda_crop_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  architectures = ["x86_64"]

  memory_size = 512
  timeout     = 60

  source_code_hash = filebase64sha256("../lambda/crop/crop-lambda.zip")

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.crop_lambda.id
    ]
  }

  tags = {
    Name        = "${local.name_prefix}-crop"
    Environment = local.environment
  }
}

resource "aws_lambda_event_source_mapping" "crop_sqs" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.crop.arn
  batch_size       = 1
  enabled          = true
}
