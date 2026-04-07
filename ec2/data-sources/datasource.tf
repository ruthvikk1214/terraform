data "aws_ami" "devops_ami" {
 most_recent = true
 owners = [973714476881]
  filter {
    name   = "name"
    values = ["Redhat-9-Devops-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}