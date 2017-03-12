variable "access_key" {}
variable "secret_key" {}
variable "main_ami" {}
variable "ec2_size" {}
variable "terraform-ssh-key"{}
variable "ec2_region" { default = "eu-west-1" }
variable "security_group_id" {}
variable "num_of_servers" {
  description = "The number of servers in the Consul cluster"
  default     = "3"
}
