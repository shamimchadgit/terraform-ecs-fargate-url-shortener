# Print VPC ID
output "vpc_id" {
    value = aws_vpc.main.id
}

#List of all pub sub IDs

output "public_subnet_ids" {
    value = [ for subnet in aws_subnet.public_subnet : subnet.id ]
}

# List of all Pr sub IDs

output "private_subnet_ids" {
    value = [ for subnet in aws_subnet.private_subnet : subnet.id ]
}

# Print Private route table IDs

output "private_route_table_ids" {
    value = aws_route_table.pr_rt.id
}

#print VPC (INF) IDs

output "vpce_interface_ids" {
    value = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
    value = aws_security_group.ecs_sg.id
}