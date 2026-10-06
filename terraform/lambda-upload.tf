resource "aws_lambda_function" "upload" {
  filename      = "../lambda/upload/upload-lambda.zip"
  function_name = "${local.name_prefix}-upload"
  role          = aws_iam_role.lambda_upload_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  architectures = ["x86_64"]

  memory_size = 256
  timeout     = 30

  source_code_hash = filebase64sha256("../lambda/upload/upload-lambda.zip")

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX = "uploads/"
    }
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.upload_lambda.id
    ]
  }

  tags = {
    Name        = "${local.name_prefix}-upload"
    Environment = local.environment
  }
}