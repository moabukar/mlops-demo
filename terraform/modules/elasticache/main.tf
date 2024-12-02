resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  parameter_group_name = "default.redis6.x"
  port                = 6379
  security_group_ids  = [aws_security_group.redis.id]
  subnet_group_name   = aws_elasticache_subnet_group.main.name

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}