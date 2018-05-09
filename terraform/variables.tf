variable "access_key" {}
variable "secret_key" {}
variable "deployer_key" {}
variable "deployer_private_key_path" {
  default = "/your/username/.ssh/id_rsa"
}
variable "region" {
  default = "eu-west-1"
}
variable "ami" {
  default = "ami-f90a4880"
}
variable "instance_type" {
  default = "t2.micro"
}
