module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = var.identifier

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "mlapp"
  username = var.db_username
  port     = 5432

  multi_az               = false
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}