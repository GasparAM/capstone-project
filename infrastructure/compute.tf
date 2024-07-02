resource "aws_launch_template" "launch" {
  name_prefix            = "Terraform-ec"
  image_id               = var.ami
  instance_type          = var.compute_instance
  key_name               = "xosqi"
  vpc_security_group_ids = [aws_security_group.tf.id]
  iam_instance_profile {
    name = var.iam_name
  }

  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }

}

resource "aws_autoscaling_group" "autoscale" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_capacity
  min_size            = var.asg_min_capacity
  vpc_zone_identifier = [for subnet in aws_subnet.public : subnet.id]

  launch_template {
    id      = aws_launch_template.launch.id
    version = "$Latest"
  }
}


resource "aws_eip" "lb" {
  vpc = true
}

resource "aws_lb" "load_balancer" {
  name               = "test-lb-tf"
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

resource "aws_lb_target_group" "test" {
  name     = "terraform-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_autoscaling_attachment" "attach_tg_asg" {
  autoscaling_group_name = aws_autoscaling_group.autoscale.id
  lb_target_group_arn    = aws_lb_target_group.test.arn
}

