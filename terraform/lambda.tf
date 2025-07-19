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

resource "aws_iam_policy" "lambda_vpc_access" {
  name        = "lambda-vpc-access"
  description = "Permissões para Lambda acessar recursos de rede em VPC"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_vpc_access_attach" {
  name       = "lambda-vpc-access-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
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


resource "aws_lambda_permission" "apigw_invoke_transaction" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transaction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}