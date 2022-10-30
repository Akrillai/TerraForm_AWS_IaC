terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.36.1"
    }
  }
}



variable "access_key" {
   default = "<PUT IN YOUR AWS ACCESS KEY or use 'export TF_VAR_access_key='>"
}

variable "secret_key" {
   default = "<PUT IN YOUR AWS SECRET KEY or use 'export TF_VAR_secret_key='>"
}


# provider "aws" {
#   access_key = var.access_key
#   secret_key = var.secret_key
#   region = "eu-west-2"
# }


locals {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "eu-west-2"
}


# variable "subnet_id" {
#   default = "subnet-e96ebeb6"
# }

# variable "vpc_id" {
#   default = "vpc-7a2ccf07"
# }

variable "image_id" {
  default = "ami-0f540e9f488cfa27d"
}

# resource "aws_key_pair" "amazon" {
#   key_name   = "amazon"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCaHrKnfYR+2Z6pTG5ZifZh6ee+JVfqb4iEayYnoea9MuCeUyER9+V62HENR1zbr1ww1laGGxI3oTrAYe+Freh3LVM+g7RQrtJr1WM25xZ78IPuncGJmtbh1qnuE4DWLSwxik1cWYhkKJu7hIZ0M+6TkHmQmr0zmX/itMk9s5tGbc/I0yfEXK4Eyldr5psLSiyQbjEPdYDeLzUmF5TVkyh07Gt0p5QWNg3yM7mnk39RZ1xILtPC1/189Drm3xjjs6E0XVvBwK17JzmTGfqAv6WQeYzxILfDwPTgd6dC+yyOm867sWcOXmzje49SGTAW1mlE9Ac7Y0+XwlYBzxx1HtX"
# }

resource "aws_security_group" "allow_app_traffic" {
  name        = "allow_traffic"
  # vpc_id      = "${var.vpc_id}"

  ingress {
    description = "app from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks = ["176.59.47.44/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "build_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  # key_name = "${aws_key_pair.amazon.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_app_traffic.id}"]

  # tags = {
  #   Name = AppBuilder
  # }

  # subnet_id = "${var.subnet_id}"
  user_data     = templatefile("./app_builder.sh", {
    access_key = local.access_key
    secret_key = local.secret_key
    region = "eu-west-2"
  })
}

resource "aws_instance" "prod_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  # key_name = "${aws_key_pair.amazon.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_app_traffic.id}"]

  # tags = {
  #   Name = WebServer
  # }

  # subnet_id = "${var.subnet_id}"
  user_data     = templatefile("./tomcat_deployer.sh", {
    access_key = local.access_key
    secret_key = local.secret_key
    region = "eu-west-2"
  })
}




#   user_data = <<EOF
# #!/bin/bash
# sudo apt update && sudo apt install -y openjdk-8-jdk tomcat8 awscli
# export AWS_ACCESS_KEY_ID=${access_key}
# export AWS_SECRET_ACCESS_KEY=${secret_key}
# export AWS_DEFAULT_REGION=${region}
# aws s3 cp s3://mybucket15.test5.com/hello-1.0.war /tmp/hello-1.0.war
# sudo mv /tmp/hello-1.0.war /var/lib/tomcat8/webapps/hello-1.0.war
# sudo systemctl restart tomcat8
# EOF



# user_data = <<EOF
# #!/bin/bash
# sudo apt update && sudo apt install -y openjdk-8-jdk maven awscli
# git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
# cd boxfuse-sample-java-war-hello && mvn package
# export AWS_ACCESS_KEY_ID=${access_key}
# export AWS_SECRET_ACCESS_KEY=${secret_key}
# export AWS_DEFAULT_REGION=${region}
# aws s3 cp target/hello-1.0.war s3://mybucket15.test5.com
# EOF