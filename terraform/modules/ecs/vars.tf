variable "repository_url" {
  type = string
}

variable "application_container_port" {
  type = number
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}