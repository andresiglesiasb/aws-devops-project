#!/bin/bash
sudo apt-get update -y


sudo apt install fontconfig openjdk-21-jre


sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
 https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
 https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
 /etc/apt/sources.list.d/jenkins.list > /dev/null
 
sudo apt-get update -y
sudo apt-get install jenkins -y


sudo systemctl enable jenkins
sudo systemctl start jenkins
