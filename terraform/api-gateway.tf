resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.prefix}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.prefix}-vpc-link"
  subnet_ids         = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.lambda_sg.id]
}

resource "aws_apigatewayv2_integration" "nlb_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = aws_lb_listener.nlb_listener.arn
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpc_link.id
  payload_format_version = "1.0"
}