#!/bin/bash
sudo apt update && sudo apt install -y openjdk-8-jdk tomcat8 awscli
export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${secret_key}
export AWS_DEFAULT_REGION=${region}
aws s3 cp s3://mybucket15.test5.com/hello-1.0.war /tmp/hello-1.0.war
sudo mv /tmp/hello-1.0.war /var/lib/tomcat8/webapps/hello-1.0.war
sudo systemctl restart tomcat8