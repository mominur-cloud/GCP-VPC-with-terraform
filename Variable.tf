variable "project" { }

variable "credentials_file" { }

variable "region" {
  default = "australia-southeast1"
}

variable "name" {
  default = "task1"
}
variable "zone" {
  default="australia-southeast1-a"
}
variable "public_subnet_cidr" {
    default = "10.10.5.0/24"
  }
variable "private_subnet_cidr" {
    default = "10.10.13.0/24"
      }
