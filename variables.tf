variable "instance_type" {
  description = "Type of the instance"
  type        = string
  default     = "t2.micro" 
}

variable "key_name" {
  description = "Name of the key pair to use for the instance"
  type        = string
}

variable "db_name" {
  description = "WordPress database name"
  default     = "wordpress_db"
}

variable "db_username" {
  description = "Database username"
  default     = "wordpress_user"
}

variable "db_password" {
  description = "Database password"
  default     = "supersecret"
  sensitive   = true
}

variable "private_key_path" {
  type    = string
  default = "C:/Users/likhi/Downloads/private-key-pair.pem"
}








