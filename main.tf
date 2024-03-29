terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

data "aws_instances" "existing_app_server" {
  instance_tags = {
    Name = "aws_docker_nginx"
  }
}

resource "aws_instance" "app_server" {
  count         = length(data.aws_instances.existing_app_server.ids) > 0 ? 0 : 1
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = "tp_devops"
  tags = {
    Name = "aws_docker_nginx"
  }
  vpc_security_group_ids = [ "sg-0b382662fbf5c3b45" ]

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Faire attention, change en fonction des AIM
    private_key = var.private_key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./install_docker.sh"  # Chemin de la source
    destination = "/tmp/install_docker.sh"  # Le chemin sur l'instance EC2 où copier le fichier
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh", # Assure que le scrypt soit executable
      "/tmp/install_docker.sh" # Exécute le script shell
    ]
  }
}

resource "null_resource" "deploy_nginx" {
  count         = length(data.aws_instances.existing_app_server.ids) > 0 ? 0 : 1
  depends_on = [aws_instance.app_server]

  connection {
    type        = "ssh"
    user        = "ec2-user"  
    private_key = var.private_key
    host        = aws_instance.app_server[0].public_ip
  }

  provisioner "file" {
    source      = "./docker-compose.yml" 
    destination = "/home/ec2-user/docker-compose.yml" 
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker-compose -f /home/ec2-user/docker-compose.yml up --build -d"
    ]
  }
}

resource "null_resource" "update_nginx" {
  count         = length(data.aws_instances.existing_app_server.ids) > 0 ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"  
    private_key = var.private_key
    host        = data.aws_instances.existing_app_server.public_ips[0]
  }

  provisioner "file" {
    source      = "./docker-compose.yml" 
    destination = "/home/ec2-user/docker-compose.yml" 
  }

  provisioner "file" {
    source      = "./test.txt" 
    destination = "/home/ec2-user/test.txt" 
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker-compose -f /home/ec2-user/docker-compose.yml stop",
      "sudo docker-compose -f /home/ec2-user/docker-compose.yml up --build -d"
    ]
  }
}

 


