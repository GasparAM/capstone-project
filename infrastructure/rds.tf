resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.tf.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.tf.id]
  }
}

# resource "aws_secretsmanager_secret" "secrets" {
#   name                           = "/secrets/db"
#   force_overwrite_replica_secret = true
#   recovery_window_in_days        = 0
# }

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = "db"
}

# This could be used in case we want to deploy secrets from our local
# resource "aws_secretsmanager_secret_version" "secrets" {
#   secret_id     = aws_secretsmanager_secret.secrets.id
#   secret_string = file("./secret.json")
# }

# resource "aws_secretsmanager_secret" "url" {
#   name                           = "/secrets/url"
#   force_overwrite_replica_secret = true
#   recovery_window_in_days        = 0

# }

resource "aws_secretsmanager_secret_version" "url" {
  secret_id     = "/secrets/url"
  secret_string = "{\"MYSQL_URL\":\"jdbc:mysql://${aws_db_instance.mysql.endpoint}/${aws_db_instance.mysql.db_name}\"}"
  depends_on    = [aws_db_instance.mysql]
}

resource "aws_db_instance" "mysql" {
  allocated_storage = 10
  db_name           = var.db_name
  engine            = "mysql"
  engine_version    = var.db_version
  instance_class    = var.rds_instance
  username               = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["MYSQL_USER"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["MYSQL_PASS"]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  parameter_group_name   = "default.mysql${var.db_version}"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
}