data "aws_availability_zones" "available" {
    state = "available"
}
# use 'zone' for single AZ
# use 'zones' for list of all available AZs in a region

# VPC Endpoint (INF) - local variables

locals {
  interface_services = [
    "com.amazonaws.${var.region}.ecr.api",
    "com.amazonaws.${var.region}.ecr.dkr",
    "com.amazonaws.${var.region}.logs",
    "com.amazonaws.${var.region}.sts",
    "com.amazonaws.${var.region}.ecs",
    "com.amazonaws.${var.region}.ecs-agent",
    "com.amazonaws.${var.region}.ecs-telemetry"
  ]
  setup_name = "url-shortener"
}

# Local variable as using the same name multiple times
# Terraform allows one per file so merge locals block 


# VPC

resource "aws_vpc" "main" {
    cidr_block = var.cidr
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = {
      Name = "${local.setup_name}-vpc"
    }
}

# Public Subnet 

resource "aws_subnet" "public_subnet" {
    count = length(var.public_subnets_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnets_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names [count.index]
    map_public_ip_on_launch = true
    tags = {
      Name = "${local.setup_name}-pb-sub-${count.index +1}"
    }
}

# Private Subnet

resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnets_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnets_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names [count.index]
    map_public_ip_on_launch = false
    tags = {
      Name = "${local.setup_name}-pr-sub-${count.index +1}"
    } 
}

# IGW 

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "${local.setup_name}-igw"
    }
}

# Route Table - Public Sub 

resource "aws_route_table" "pb_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  tags = {
    Name = "${local.setup_name}-pb-rt"
  }
}

# Route Table Association - Pb Sub

resource "aws_route_table_association" "pb_rt_as" {
    count = length(aws_subnet.public_subnet)
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.pb_rt.id
}

# Route Table - Private Sub

resource "aws_route_table" "pr_rt" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "${local.setup_name}-pr-rt"
    }
}

# Route Table Association - Pr Sub

resource "aws_route_table_association" "pr_rt_as" {
    count = length(aws_subnet.private_subnet)
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.pr_rt.id
}

# VPC Endpoint (GW)

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${var.region}.s3"
    # API req to reach S3
    route_table_ids = [aws_route_table.pr_rt.id]
    vpc_endpoint_type = "Gateway"
    tags = {
        Name = "${local.setup_name}-s3-vpce"
    }
}

resource "aws_vpc_endpoint" "dynamodb" {
    vpc_id = aws_vpc.main.id 
    service_name = "com.amazonaws.${var.region}.dynamodb"
    route_table_ids = [aws_route_table.pr_rt.id]
    vpc_endpoint_type = "Gateway"
    tags = {
      Name = "${local.setup_name}-dynamodb-vpce"
    }
}

# VPC Endpoint (INF)

resource "aws_vpc_endpoint" "interface" {
    for_each = toset(local.interface_services)
    vpc_id = aws_vpc.main.id
    service_name = each.value
    vpc_endpoint_type = "Interface"

    security_group_ids = [aws_security_group.vpce_sg.id]

    subnet_ids = aws_subnet.private_subnet[*].id

    private_dns_enabled = var.private_dns_enabled
    tags = {
        Name = replace(each.value, "com.amazonaws.${var.region}.", "")
    }
}

# Security Group for Interface endpoints (allow vpce talk to endpoints on 443)

resource "aws_security_group" "vpce_sg" {
    name = "vpce-sg"
    description = "Allow HTTPS inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.main.id 

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.cidr] # allow from vpc
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.cidr] # aws recommends restricting egress to VPC CIDR
    }
  tags = {
    Name = "vpce_sg"
  }
}

# Security Group for ALB 

resource "aws_security_group" "alb_sg" {
    name = "alb-sg"
    description = "Allow inbound traffic from internet on port 443 and outbound traffic (stateful)"
    vpc_id = aws_vpc.main.id 
    # prod listener - HTTPS open to world
    ingress { # ALB SG allows 443 from 0.0.0.0/0
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # Test listener - internal only
    ingress { 
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = [var.cidr]
    }
    # Allow ALB to reach ECS tasks 
    egress { # as ALB doesn't have a stable/predictable destination so can't restrict outbound tr tightly 
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "alb_sg"
  }
}

# Security Group for ECS 

resource "aws_security_group" "ecs_sg" {
    name = var.ecs_sg_name
    description = "Security group for ECS"
    vpc_id = aws_vpc.main.id

    ingress { # ECS SG allows 8080 from ALB 
        from_port = var.ecs_container_port # same as port for ECS Task Def
        to_port = var.ecs_container_port # exact door app is listening on
        protocol = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    } # SG ref only allows inbound tr only from ALB as ECS not public
    # if request doesn't come from ALB - won't answer

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    } # response & dependencies exist e.g. pull images ECR, talk to CloudWatch/DDB, respond back to ALB etc...
    # egress restricted = Health check fails, DNS wouldn't work, img pulls fail etc...
    # SG  = Stateful if ingress allowed, egress automatically allowed
    tags = {
      Name = "ecs_sg"
    }
}