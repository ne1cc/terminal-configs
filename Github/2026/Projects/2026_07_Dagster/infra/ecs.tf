# --- ECS Cluster ---

resource "aws_ecs_cluster" "dagster" {
  name = "dagster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# --- ECR Repository ---

resource "aws_ecr_repository" "dagster" {
  name                 = "ab-testing-dagster"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- RDS (Dagster run/event storage) ---

resource "aws_db_instance" "dagster" {
  identifier     = "dagster-${var.environment}"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "dagster"
  username = "dagster"
  password = random_password.db.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.dagster.name

  backup_retention_period = 7
  deletion_protection     = var.environment == "production"
  skip_final_snapshot     = var.environment != "production"
}

resource "aws_db_subnet_group" "dagster" {
  name       = "dagster-${var.environment}"
  subnet_ids = var.subnet_ids
}

resource "random_password" "db" {
  length  = 32
  special = false
}

# --- Security Groups ---

resource "aws_security_group" "ecs" {
  name_prefix = "dagster-ecs-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "dagster-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
}

# --- ECS Task Definition ---

resource "aws_ecs_task_definition" "dagster_webserver" {
  family                   = "dagster-webserver-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "dagster-webserver"
    image = var.dagster_image

    essential = true

    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]

    environment = [
      { name = "DAGSTER_HOME", value = "/opt/dagster/dagster_home" },
      { name = "WAREHOUSE", value = "postgres" },
      { name = "PG_HOST", value = aws_db_instance.dagster.address },
      { name = "PG_DBNAME", value = "dagster" },
      { name = "PG_USER", value = "dagster" },
    ]

    secrets = [
      { name = "PG_PASSWORD", valueFrom = aws_secretsmanager_secret.db_password.arn },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.dagster.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "webserver"
      }
    }
  }])
}

# --- ECS Service ---

resource "aws_ecs_service" "dagster_webserver" {
  name            = "dagster-webserver"
  cluster         = aws_ecs_cluster.dagster.id
  task_definition = aws_ecs_task_definition.dagster_webserver.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
}

# --- IAM Roles ---

resource "aws_iam_role" "ecs_execution" {
  name = "dagster-ecs-execution-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "dagster-ecs-task-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# --- Secrets Manager ---

resource "aws_secretsmanager_secret" "db_password" {
  name = "dagster/${var.environment}/db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

# --- CloudWatch Logs ---

resource "aws_cloudwatch_log_group" "dagster" {
  name              = "/ecs/dagster-${var.environment}"
  retention_in_days = 30
}
