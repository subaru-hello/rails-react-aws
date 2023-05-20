resource "aws_db_instance" "blog_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "blog_api_production"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.blog_db_subnet_group.name
}

resource "aws_db_subnet_group" "blog_db_subnet_group" {
  name       = "blog_db_subnet_group"
  subnet_ids = [aws_subnet.private_subnet-1a.id, aws_subnet.private_subnet-1c.id]
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow inbound traffic to RDS MySQL instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
