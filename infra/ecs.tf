

# ecs用るsecurity group
resource "aws_security_group" "ecs_sg" {
  vpc_id     = aws_vpc.vpc.id 
  name        = "https_for_ecs_sg"
  description = "Allow HTTPS inbound traffic"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

# ECSクラスタの作成
resource "aws_ecs_cluster" "cluster" {
  name = "app-cluster"
}

# ECSタスク定義の作成
resource "aws_ecs_task_definition" "blog_task" {
  family                   = "blog_task" # タスク定義名を変更
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5GB memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # タスク実行ロールを指定

  container_definitions = <<DEFINITION
  [
    {
      "name": "blog_nginx",
      "image": "061293269148.dkr.ecr.ap-northeast-1.amazonaws.com/api_nginx",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
       "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/blog_task",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "api_nginx"
        }
      }
    },
    {
      "name": "api",
      "image": "061293269148.dkr.ecr.ap-northeast-1.amazonaws.com/api",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment" : [
        {"name" : "DB_PASSWORD", "value" : "${var.db_password}"},
        {"name" : "DB_USERNAME", "value" : "${var.db_username}"},
        {"name" : "DB_HOST", "value" : "${aws_db_instance.blog_db.endpoint}"},
        {"name" : "DB_NAME", "value" : "blog_api_production"},
        {"name" : "RAILS_ENV", "value" : "production"}
      ],
      "dependsOn" : [
        {
          "containerName" : "blog_nginx",
          "condition" : "START"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/blog_task",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "api"
        }
      }
    }
  ]
  DEFINITION
}

# ECSサービスの作成
resource "aws_ecs_service" "service" {
  name            = "blog" # サービス名を変更
  cluster         = aws_ecs_cluster.cluster.id # 先ほど作成したクラスタを選択
  task_definition = aws_ecs_task_definition.blog_task.arn # 先ほど作成したタスク定義を選択
  launch_type     = "FARGATE" # 起動タイプを指定
  desired_count   = 2 # タスクの数を指定

  network_configuration {
    subnets          = [aws_subnet.public_subnet-1a.id, aws_subnet.public_subnet-1c.id] # サブネットを指定
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id] # セキュリティグループを指定
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.front_end.arn
    container_name   = "blog_nginx" # ロードバランサ用のコンテナを指定
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sd.arn
  }

  depends_on = [aws_lb_listener.front_end]
}

# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "sd_ns" {
  name = "svc.local"
  vpc  = aws_vpc.vpc.id
}

resource "aws_service_discovery_service" "sd" {
  name = "blog"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sd_ns.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

# IAMロールの作成
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr_policy"
  description = "Policy to allow ECS tasks to authenticate with ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["ecr:GetAuthorizationToken"],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "ecs_logging" {
  name        = "ecs_logging"
  description = "Allows ECS tasks to call AWS services on your behalf."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_logging_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_logging.arn
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ecr_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
