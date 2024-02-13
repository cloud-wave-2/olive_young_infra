#########################################################################################################
## Create Security Group
#########################################################################################################

# 모든 tcp 허용
resource "aws_security_group" "allow-ssh-sg" {
  name        = "stg-ecommerce-sg01-pub01a"
  description = "allow ssh for stg-ecommerce-ec2-bastion-pub01a"
  vpc_id      = data.aws_vpc.bastion_vpc.id
}

resource "aws_security_group_rule" "allow-ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.allow-ssh-sg.id
  to_port           = 22
  type              = "ingress"
  description       = "ssh"
  cidr_blocks       = ["0.0.0.0/0"]
}

# 모든 http 허용
resource "aws_security_group" "allow-http-sg" {
  name        = "stg-ecommerce-sg02-pub01a"
  description = "allow all ports"
  vpc_id      = data.aws_vpc.bastion_vpc.id
}

resource "aws_security_group_rule" "allow-http-ports" {
  from_port         = 80
  protocol          = "-1"
  security_group_id = aws_security_group.allow-http-sg.id
  to_port           = 80
  type              = "ingress"
  description       = "all ports"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-http-ports-egress" {
  from_port         = 80
  protocol          = "-1"
  security_group_id = aws_security_group.allow-http-sg.id
  to_port           = 80
  type              = "egress"
  description       = "all ports"
  cidr_blocks       = ["0.0.0.0/0"]
}