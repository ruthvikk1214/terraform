output "az_info" {
 value = module.vpc.aws_availability_zones.available.names 
}