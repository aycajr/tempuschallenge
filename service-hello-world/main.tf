resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "hello_world"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "hello_world" {
  family = "hello_world"

  container_definitions = <<EOF
[
  {
    "name": "hello_world",
    "image": "hello-world",
    "cpu": 0,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-2",
        "awslogs-group": "hello_world",
        "awslogs-stream-prefix": "tc-lab"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello_world"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.hello_world.arn}"
  launch_type     = "EC2"
  desired_count   = 1

  #depends_on      = ["aws_iam_role.ecsiamrole"]

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
