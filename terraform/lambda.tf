resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "transaction" {
  function_name = "transaction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"

  filename         = "${path.module}/lambda_zips/transaction.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_zips/transaction.zip")

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "transaction-lambda"
  }
 
}

resource "aws_lambda_function" "autopay" {
  function_name = "autopay"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"

  filename         = "${path.module}/lambda_zips/autopay.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_zips/autopay.zip")

  vpc_config {
    subnet_ids         = aws_subnet.private_subnets[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "autopay-lambda"
  }
}

