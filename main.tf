# setup le provider
provider "aws" {
    region = var.AWS_REGION
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
  
}
# setup key-pair
resource "aws_key_pair" "MonSrv" {
    key_name = "terraform-key"
    public_key = file("./terraform-key.pub")
  
}

# création de l'instance
resource "aws_instance" "MonSrv" {
    key_name = aws_key_pair.MonSrv.key_name
    ami = var.AWS_AMI
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("./terraform-key")
      host = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
          "sudo yum -f -y update",
          "sudo yum install httpd -y",
          "sudo firewall-cmd --permanent --add-service=http",
          "sudo systemctl start httpd.service",
          "sudo systemctl enable httpd.service",
          "sudo sh -c 'echo \"<h1>Hello famille DevOps</h1>\" > /var/www/html/index.html'",
        ]
    }
    #user_data = <<-EOF
        #!/bin/bash
    #    sudo yum update
     #   sudo yum install -y httpd
      #  sudo firewall-cmd --permanent --add-service=http
      #  sudo firewall-cmd --reload
      #  sudo systemctl start httpd.service
      #  sudo systemctl enable httpd.service
      #  sudo echo "<html><h1>Hello famille devops</h1></html>" > /var/www/html/index.html
    #EOF
    tags = {
      Name = "terraform-test"
    }
  
}

# création de SG pour autoriser les traffics E/S
resource "aws_security_group" "instance_sg" {
    name = "terraform-test-sg"

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
output "Ip_pub" {
    value = aws_instance.MonSrv.public_ip
  
}
