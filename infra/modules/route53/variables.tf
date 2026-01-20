variable "domain_name" {
    type = string
    description = "The name of my domain created on AWS Route53"
}

variable "private_zone" {
    type = bool
    description = ""
    default = false
}

variable "domain_validation_options" {
    description = "ACM domain validation options"
    type = list(object({
      domain_name = string
      resource_record_name = string
      resource_record_type = string
      resource_record_value = string 
    }))
}

# DNS Record - alias section 


variable "alb_dns_name" {
    description = ""
    type = string
}

variable "alb_zone_id" {
    description = ""
    type = string
}

variable "evaluate_target_health" {
    description = ""
    type = bool
    default = true 
}

