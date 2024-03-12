#!/bin/bash

# Mettre à jour le système
sudo yum update -y

# Installer Docker
sudo yum install -y docker

# Démarrer le service Docker
sudo service docker start

# Ajouter l'utilisateur ec2-user au groupe docker
sudo usermod -a -G docker ec2-user

# Installer git
sudo yum install -y git

# Cloner Docker Compose depuis GitHub vers /tmp/docker-compose
git clone https://github.com/docker/compose.git /tmp/docker-compose

# Copier Docker Compose dans /usr/local/bin
sudo cp /tmp/docker-compose/bin/docker-compose /usr/local/bin/docker-compose

# Donner les permissions d'exécution à Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

# Créer le répertoire pour les fichiers de configuration Docker Compose
sudo mkdir -p /opt/docker-compose

# Donner les permissions à l'utilisateur ec2-user sur le répertoire
sudo chown -R ec2-user:ec2-user /opt/docker-compose

# Donner les permissions appropriées au répertoire
sudo chmod -R 775 /opt/docker-compose

# Install docker compose
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null

sudo chmod +x /usr/local/bin/docker-compose

ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

docker-compose --version 

# Sortir du script
exit
