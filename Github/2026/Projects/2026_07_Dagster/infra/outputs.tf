output "ecr_repository_url" {
  description = "ECR repository URL for pushing Dagster images"
  value       = aws_ecr_repository.dagster.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.dagster.name
}

output "rds_endpoint" {
  description = "RDS Postgres endpoint for Dagster storage"
  value       = aws_db_instance.dagster.endpoint
}

output "webserver_service_name" {
  description = "ECS service name for the Dagster webserver"
  value       = aws_ecs_service.dagster_webserver.name
}
