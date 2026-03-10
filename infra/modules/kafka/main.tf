# Amazon Linux 2023 AMI

data "aws_ami" "amazon_linux_2023" {
    most_recent = true 
    owners = ["137112412989"]

    filter {
      name = "name"
      values = ["amazon-linux-2023-ami-*-x86_64-gp3"]
    }
  
}

# EC2 Instance 

resource "aws_instance" "kafka_broker" {
    ami = data.aws_ami.amazon_linux_2023.id
    instance_type = var.instance_type
    subnet_id = var.private_sub_id
    vpc_security_group_ids = [aws_security_group.kafka_sg.id]
    iam_instance_profile = aws_iam_instance_profile.kafka_profile.name
    associate_public_ip_address = var.public_ip

    user_data = templatefile("${path.module}/user_data.sh.tpl", {kafka_bucket = var.kafka_assets_s3_bucket})
# terraform injects var before EC2 launches
    tags = {
      Name = "kafka-broker"
    }  
}

# IAM Role for EC2

resource "aws_iam_role" "kafka_role" {
    name = "kafka-ec2-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.kafka_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "s3_policy" {
    name = "kafka-s3-access-dev"
    role = aws_iam_role.kafka_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "s3:GetObject"
            ]
            Resource = "${var.kafka_assets_s3_bucket}/*"
        }]
    })
  
}

resource "aws_iam_instance_profile" "kafka_profile" {
    name = "kafka-profile"
    role = aws_iam_role.kafka_role.name
}