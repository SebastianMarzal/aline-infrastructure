// Data section: getting ID of default VPC in region; AMIs for Amazon, Ubuntu, and Linux; setting up local variables
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

// Resource creation starts, ansible ssh key needs to be created in host

resource "aws_key_pair" "this" {
  key_name   = "ansible"
  public_key = file("~/.ssh/ansible.pub")
}

resource "aws_security_group" "this" {
  name        = "SSH"
  description = "Allow inbound SSH traffic."
  vpc_id      = data.aws_vpc.this.id

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

resource "aws_instance" "control" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_dns
    private_key = file("~/.ssh/ansible")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install ansible -y"
    ]
  }

  provisioner "file" {
    source      = "~/.ssh/ansible"
    destination = ".ssh/ansible"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/ansible"
    ]
  }

  provisioner "file" {
    source      = "../../../Ansible/playbooks_demo"
    destination = "playbooks_demo"
  }

  provisioner "file" {
    content     = <<EOT
%{for worker in aws_instance.workers~}
[${worker.tags["System"]}]
${worker.public_dns} ansible_ssh_user=${worker.tags["User"]}

%{endfor~}
EOT
    destination = "playbooks_demo/inventory"
  }

  tags = {
    "Name" = "Control"
  }
}

resource "aws_instance" "workers" {
  count = 3

  ami                    = local.amis[count.index]
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    "Name" = "Worker-${local.system[local.amis[count.index]]}",
    "User" = local.user[local.amis[count.index]]
    "System" = local.system[local.amis[count.index]]
  }
}