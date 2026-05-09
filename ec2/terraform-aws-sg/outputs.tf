output "sg_id" {
  value = aws_security_group.main.id
}
 output "sg_id" {
    description = "The ID of the security group created by this module"
    value       = aws_security_group.main.id
  }