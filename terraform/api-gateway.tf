resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "${var.prefix}-vpc-link"
  target_arns = [aws_lb.nlb.arn]
}

resource "aws_apigatewayv2_integration" "nlb_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = aws_lb_listener.nlb_listener.arn
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigateway_vpc_link.vpc_link.id
  payload_format_version = "1.0"
}