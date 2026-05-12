resource "aws_instance" "mongodb" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.mongodb_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-mongodb"
        },
        local.common_tags
    )
    }