resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.16/28"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
}

resource "aws_route_table_association" "private-rta" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_instance" "my_backserver" {
  private_ip             = "10.0.0.20"
  ami                    = "ami-05f7491af5eef733a"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.my_frontserver.id]
  key_name               = "mykeypair-key"
  tags = {
    Name = "private-instance"
  }
}

/*
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "echo '${file(var.docker_file)}' > Dockerfile && echo '${file(var.html_file)}' > index.html",
      "sudo apt-get install docker.io -y",
      "docker build -t webserver .",
      "docker run -it --rm -d -p 80:80 --name web webserver"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.path_private_key)
      host        = aws_instance.my_backserver.private_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${aws_instance.my_backserver.private_ip},' --private-key ${var.path_private_key} ${var.path_playbook_1}"
  }*/
