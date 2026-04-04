variable "ami_id" {
  default     = "ami-0220d79f3f480ecf5"
  description = "RHEL9 image ID"
  type        = string
}

variable "instance_type" {
  default = "t3.micro"
  type    = string
}


variable "instance_tags" {
    type = map(string)
    default = {
        Name = "variable-demo"
        Project = "roboshop"
        Terraform = "true"
        environment = "dev"
    }
}