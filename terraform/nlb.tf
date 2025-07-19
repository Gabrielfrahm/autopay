resource "aws_lb" "nlb" {
  name               = "${var.prefix}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private_subnets[*].id

  tags = {
    Name = "${var.prefix}-nlb"
  }
}

resource "aws_lb_target_group" "lambda_tg" {
  name        = "${var.prefix}-lambda-tg"
  target_type = "lambda"
  vpc_id      = aws_vpc.new-vpc.id

  health_check {
    enabled             = true
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.prefix}-lambda-tg"
  }
}

resource "aws_lb_target_group_attachment" "lambda_attachment" {
  target_group_arn = aws_lb_target_group.lambda_tg.arn
  target_id        = aws_lambda_function.transaction.function_name
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}