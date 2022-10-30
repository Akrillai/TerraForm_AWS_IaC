terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.36.1"
    }
  }
}

variable "image_id" {
  default = "ami-0f540e9f488cfa27d"
}

resource "aws_security_group" "allow_app_traffic" {
  name        = "easy_access"
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
    cidr_blocks = ["0.0.0.0/0"]
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
  vpc_security_group_ids = ["${aws_security_group.allow_app_traffic.id}"]

  tags = {
    Name = "AppBuilder"
  }

  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk maven awscli
git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd boxfuse-sample-java-war-hello && mvn package
export AWS_ACCESS_KEY_ID=<>
export AWS_SECRET_ACCESS_KEY=<>
export AWS_DEFAULT_REGION=eu-west-2
aws s3 cp target/hello-1.0.war s3://mybucket15.test5.com
EOF
}

resource "aws_instance" "prod_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_app_traffic.id}"]

  tags = {
    Name = "WebServer"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk tomcat9 awscli
export AWS_ACCESS_KEY_ID=<>
export AWS_SECRET_ACCESS_KEY=<>
export AWS_DEFAULT_REGION=eu-west-2
aws s3 cp s3://mybucket15.test5.com/hello-1.0.war /tmp/hello-1.0.war
sudo mv /tmp/hello-1.0.war /var/lib/tomcat9/webapps/hello-1.0.war
EOF
}