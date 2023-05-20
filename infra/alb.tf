
# ALBの作成
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet-1a.id, aws_subnet.public_subnet-1c.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# ALBリスナーの作成
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # SSL policy
  certificate_arn   = data.aws_acm_certificate.api_cert.arn # SSL certificate

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

# ALBターゲットグループの作成
resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  target_type = "ip"
}

# ALB用のセキュリティグループの作成
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc.id
  name        = "https_for_alb_sg"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
