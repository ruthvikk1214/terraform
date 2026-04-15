module "practice" {
  source = "../ec2_source_practice"
  ami_id = var.aws_ami.id
    instance_type = "t2.micro"
    sg_ids = ["sg-0eec592803ede7730"]
}