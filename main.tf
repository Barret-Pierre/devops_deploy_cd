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

data "aws_instances" "app_server_instance" {
  instance_tags = {
    Name = "aws_docker_nginx"
  }
}

resource "aws_instance" "app_server" {
  count         = length(data.aws_instances.mongodb_instances.ids) > 0 ? 0 : 1
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  tags = {
    Name = "aws_docker_nginx"
  }
  vpc_security_group_ids = [ var.vpc_security_group_id ]

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
  depends_on = [aws_instance.app_server]

  connection {
    type        = "ssh"
    user        = "ec2-user"  
    private_key = var.private_key
    host        = aws_instance.app_server.public_ip
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

 


