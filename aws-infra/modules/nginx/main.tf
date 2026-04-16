resource "aws_instance" "nginx" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = "dev-key-bastion"
  subnet_id                   = var.dev_private_subnet_id_1a
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.nginx_sg_id]

  user_data = <<-EOF
#!/bin/bash
set -e

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

JENKINS_PRIVATE_IP="${var.jenkins_private_ip}"
if [ -z "$JENKINS_PRIVATE_IP" ]; then
  JENKINS_PRIVATE_IP="127.0.0.1"
fi

cat <<'NGINXCONF' > /etc/nginx/sites-available/jenkins.conf
server {
    listen 80;
    server_name _;

    location = / {
        return 200 "OK";
        add_header Content-Type text/plain;
    }

    location = /health {
        access_log off;
        return 200 "healthy";
        add_header Content-Type text/plain;
    }

    location /jenkins/ {
        proxy_pass          http://__JENKINS_PRIVATE_IP__:8080/jenkins/;
        proxy_set_header    Host $host:$server_port;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;
        proxy_redirect      http://__JENKINS_PRIVATE_IP__:8080/jenkins/ /jenkins/;
    }
}
NGINXCONF

sed -i "s/__JENKINS_PRIVATE_IP__/$JENKINS_PRIVATE_IP/g" /etc/nginx/sites-available/jenkins.conf

ln -sf /etc/nginx/sites-available/jenkins.conf /etc/nginx/sites-enabled/jenkins.conf
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx
EOF

  tags = merge(
    var.common_tags,
    {
      Name = "dev-nginx-ec2"
    }
  )

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }
}
