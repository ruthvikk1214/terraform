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
    
resource "aws_instance" "redis" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.redis_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-redis"
        },
        local.common_tags
    )
}

resource "aws_instance" "rabbitmq" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.rabbitmq_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-rabbitmq"
        },
        local.common_tags
    )
    }

resource "aws_instance" "mysql" {
    ami           =   local.ami_id
    instance_type = "t3.micro"
    subnet_id = local.database_subnet_ids
    vpc_security_group_ids = [local.mysql_sg_id]
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-mysql"
        },
        local.common_tags
    )
    }