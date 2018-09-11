resource "aws_iam_role" "ecsiamrole1" {
  name = "TC_ecs_instancerole"
  path = "/modules/aws-asg/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

#ecsiprof = Elastic Container Service Instance Profile
resource "aws_iam_instance_profile" "ecsprof" {
  name = "${var.name}_ecs_instance_profile"
  role = "${aws_iam_role.ecsiamrole1.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.ecsiamrole1.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.ecsiamrole1.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
