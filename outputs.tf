output "alb_dns" {
  value = aws_lb.wordpress_alb-likky.dns_name
}


output "rds_endpoint" {
  description = "The endpoint for the RDS instance"
  value       = aws_db_instance.wordpress_rds_likky.endpoint
}

