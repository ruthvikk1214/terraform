module "practice" {
  source = "../ec2_source_practice"
  ami_id = "ami-0220d79f3f480ecf5"
    instance_type = "t3.micro"
    sg_ids = ["sg-0eec592803ede7730"]
}