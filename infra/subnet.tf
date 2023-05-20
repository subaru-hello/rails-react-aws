
# public subnet1 for (ecs, alb)
resource "aws_subnet" "public_subnet-1a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

# public subnet2 for (ecs, alb)
resource "aws_subnet" "public_subnet-1c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.20.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "public-subnet-2"
  }
}

# rdsを配置するsubnet1
resource "aws_subnet" "private_subnet-1a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.30.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

# rdsを配置するsubnet2
resource "aws_subnet" "private_subnet-1c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.40.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "private-subnet-2"
  }
}
