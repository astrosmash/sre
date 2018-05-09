provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_key_pair" "deployer" {
  key_name = "deploy"
  public_key = "${var.deployer_key}"
}

resource "aws_security_group" "test" {
  name = "sre-challenge-sg"
  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
}

resource "aws_instance" "sre-challenge" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.deployer.key_name}"
  security_groups = ["${aws_security_group.test.name}"]
  connection {
    user = "ubuntu"
    private_key = "${file("${var.deployer_private_key_path}")}"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https ca-certificates docker-ce -y",
      /* sed'ness needed for awslogs */
      "sudo sed -i '/\\[Service\\]/a Environment=\"AWS_REGION=eu-west-1\"\\nEnvironment=\"AWS_ACCESS_KEY_ID=${var.access_key}\"\\nEnvironment=\"AWS_SECRET_ACCESS_KEY=${var.secret_key}\"' /lib/systemd/system/docker.service",
      "sudo systemctl daemon-reload && sudo systemctl restart docker.service",
      "sudo docker run --log-driver=awslogs --log-opt awslogs-group=docker-logs --log-opt awslogs-create-group=true --log-opt awslogs-region=eu-west-1 --log-opt awslogs-stream=sre-challenge -d --rm --init --network=host astrosmash/sre-challenge"
    ]
  }
  tags = { 
    Name = "sre-challenge"
  }
}
