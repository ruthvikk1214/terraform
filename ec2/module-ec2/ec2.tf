module "ec2" {
    source = "../ec2instance-module"
    sg_ids = [sg-0eec592803ede7730]
    ami_id = "ami-0220d79f3f480ecf5"
    project = "roboshop"
    environment = "dev"
}