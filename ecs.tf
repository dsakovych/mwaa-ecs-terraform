resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.prefix}-ecs-cluster"
}


resource "aws_ecs_task_definition" "ecs_task" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.iam_role.arn
  task_role_arn            = aws_iam_role.iam_role.arn
  family                   = "service"
  container_definitions    = jsonencode([{
   name        = "${var.prefix}-ecs-service"
   image       = "hello-world:latest"
   essential   = true
   portMappings = [{
     protocol      = "tcp"
     containerPort = 80
     hostPort      = 80
   }]
}])
}


resource "aws_ecs_service" "main" {
 name                               = "${var.prefix}-ecs-service"
 cluster                            = aws_ecs_cluster.ecs_cluster.id
 task_definition                    = aws_ecs_task_definition.ecs_task.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"

 network_configuration {
   security_groups  = aws_security_group.mwaa.*.id
   subnets          = aws_subnet.public_subnets.*.id
   assign_public_ip = false
 }

 load_balancer {
   target_group_arn = aws_alb_target_group.alb_tg.arn
   container_name   = "${var.prefix}-ecs-service"
   container_port   = 80
 }

 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }

   target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }

   target_value       = 60
  }
}