output "sg_id" {
  value = aws_security_group.main.sg_id
}
 output "sg_id" {
    description = "Security group ID from the SG module"
    value       = module.sg.sg_id
  }
 output "mongodb_sg_id" {
    value = module.sg.sg_id   # this will be the actual SG ID
  }