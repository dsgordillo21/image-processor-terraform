resource "aws_iam_role" "lambda_upload_role" {
  name = "${local.name_prefix}-lambda-upload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role" "lambda_crop_role" {
  name = "${local.name_prefix}-lambda-crop-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "lambda_upload_policy" {
  name = "${local.name_prefix}-lambda-upload-policy"
  role = aws_iam_role.lambda_upload_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.images.arn}/uploads/*"
      },

    ]
  })
}
resource "aws_iam_role_policy" "lambda_crop_policy" {
  name = "${local.name_prefix}-lambda-crop-policy"
  role = aws_iam_role.lambda_crop_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.images.arn}/uploads/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.images.arn}/processed/*"
      },
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]

        Resource = aws_sqs_queue.image_queue.arn
      }


    ]
  })
}
resource "aws_iam_role_policy_attachment" "upload_vpc_access" {
  role       = aws_iam_role.lambda_upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_vpc_access" {
  role       = aws_iam_role.lambda_crop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "upload_basic_execution" {
  role       = aws_iam_role.lambda_upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_basic_execution" {
  role       = aws_iam_role.lambda_crop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}