// Data
data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_ami" "amazon" {
  filter {
    name = "description"
    values = ["Amazon Linux 2 Kernel 5.10 AMI 2.0.20230320.0 x86_64 HVM gp2"]
  }

  most_recent = true
  owners = ["amazon"]
}

data "aws_ami" "ubuntu" {
  filter {
    name = "description"
    values = ["Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-02-08"]
  }

  most_recent = true
  owners = ["amazon"]
}

data "aws_ami" "debian" {
  filter {
    name = "description"
    values = ["Debian 11 (20230124-1270)"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  most_recent = true
  owners = ["amazon"]
}

// Locals

locals {
  amis = [
    data.aws_ami.amazon.id,
    data.aws_ami.ubuntu.id,
    data.aws_ami.debian.id
  ]
  user = {
    "${local.amis[0]}" : "ec2-user",
    "${local.amis[1]}" : "ubuntu",
    "${local.amis[2]}" : "admin"
  }
  system = {
    "${local.amis[0]}" : "Amazon",
    "${local.amis[1]}" : "Ubuntu",
    "${local.amis[2]}" : "Debian"
  }
}

// Resources

resource "aws_key_pair" "this" {
  key_name   = "ansible"
  public_key = file("~/.ssh/ansible.pub")
}

resource "aws_security_group" "this" {
  name        = "SSH"
  description = "Allow inbound SSH traffic."
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "awx" {
  ami                    = "ami-0568936c8d2b91c4e" # east-2 Ubuntu 20.04
  instance_type          = "t2.xlarge"             # Need at least 2 cores
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]
  root_block_device {
    volume_size = 30
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_dns
    private_key = file("~/.ssh/ansible")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade -y",
      "curl -sfL https://get.k3s.io | sh -",
      "sudo chown ubuntu:ubuntu /etc/rancher/k3s/k3s.yaml",
      "curl -s \"https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh\"  | bash",
      "sudo mv kustomize /usr/local/bin"
    ]
  }
  
  provisioner "file" {
    source      = "~/.ssh/ansible"
    destination = ".ssh/ansible"
  }

  provisioner "file" {
    source      = "kustomization.yaml"
    destination = "kustomization.yaml"
  }

  provisioner "remote-exec" {
    inline = ["kustomize build . | kubectl apply -f -"]
  }

  provisioner "file" {
    source = "awx.yaml"
    destination = "awx.yaml"
  }

  provisioner "file" {
    source = "kustomization-2.yaml"
    destination = "kustomization.yaml"
  }

  provisioner "remote-exec" {
    inline = ["kustomize build . | kubectl apply -f -"]
  }
  
  # To get password
  # `kubectl get secret awx-admin-password -o jsonpath="{.data.password}" --namespace awx | base64 --decode`

  tags = {
    "Name" = "AWX Host (SM)"
  }
}

resource "aws_instance" "workers" {
  count = 3

  ami                    = local.amis[count.index]
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    "Name" = "Worker-${local.system[local.amis[count.index]]} (SM)",
    "User" = local.user[local.amis[count.index]]
    "System" = local.system[local.amis[count.index]]
  }
}

resource "aws_eip" "awx" {
  instance = aws_instance.awx.id
  vpc = true
}

resource "aws_eip" "workers" {
  count = 3

  instance = aws_instance.workers[count.index].id
  vpc = true
}