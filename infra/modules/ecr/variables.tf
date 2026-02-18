# Lifecycle Policy
 variable "untagged_count_num" {
    type = number
 }

 variable "latest_img" {
    type = number
 }

 # ECR Repo

 variable "repo_name" {
   type = string
   default = "url_shortener_app"
 }