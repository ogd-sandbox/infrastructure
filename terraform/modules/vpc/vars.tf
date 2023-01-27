variable "vpc_cidr_block" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidr_block" {
  type = list(string)
}

variable "private_subnet_cidr_block" {
  type = list(string)
}