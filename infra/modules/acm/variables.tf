variable "domain_name" {
    type = string
    description = ""
}

variable "validation_method" {
    type = string
    default = "DNS"
}

variable "validation_record_fqdns" {
    type = list(string)
    description = ""
}