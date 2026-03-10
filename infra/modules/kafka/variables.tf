variable "private_sub_id" {
    type = string
}

variable "instance_type" {
  type = string 
  default = "t3.small"
}

variable "public_ip" {
    type = bool
    default = false
}

variable "kafka_assets_s3_bucket" {
    type = string
}

variable "security_group_ids" {
    type = list(string)
  
}