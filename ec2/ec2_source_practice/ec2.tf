resource "aws_instance" "practice1" {
    ami = var.ami_id
    instance_type = var.instance_type
    vpc_security_group_ids = var.sg_ids
    tags = {
        Name = "module-practice"
        Project = "roboshop"
    } 
}