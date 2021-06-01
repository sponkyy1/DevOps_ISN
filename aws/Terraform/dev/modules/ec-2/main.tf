#Екземпляри всередині одного VPC можуть підключатись один до одного через їх приватні IP-адреси
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/27"
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = "true" // Public
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
}

resource "aws_route_table_association" "public-rta" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id
  depends_on    = [aws_internet_gateway.internet-gw]
}

resource "aws_security_group" "my_frontserver" {
  name = "WebServer Security Group"

  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = ["80", "8080", "9090", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_frontserver" {
  ami                    = "ami-05f7491af5eef733a"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_frontserver.id]
  subnet_id              = aws_subnet.public-subnet.id
  key_name               = "mykeypair-key"
  tags = {
    Name = "bastion-instance"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "echo '${file(var.private_key)}' > terraform",
      "sudo chmod 0600 terraform",
      "sudo mv terraform .ssh/"
      ### "sudo chmod 666 /var/run/docker.sock" ###
      ### Install docker Pipeline and Ansible and configure ssh connection and dockerhub connection ### 
      /*"echo '${file(var.docker_file)}' > Dockerfile && echo '${file(var.html_file)}' > index.html",
      "sudo apt-get install docker.io -y",
      "docker build -t webserver .",
      "docker run -it --rm -d -p 80:80 --name web webserver"*/
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key)
      host        = aws_instance.my_frontserver.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${aws_instance.my_frontserver.public_ip},' --private-key ${var.private_key} ${var.path_playbook}"
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair-key"
  public_key = var.public_key
}


/*
  - name: Set up Jenkins
    lineinfile:
      dest: /etc/default/jenkins
      regexp: 'JENKINS_USER='
      line: 'JENKINS_USER="root"#'
  - name: Configure_1 jenkins
    action: shell sudo chown -R root:root /var/lib/jenkins/
  - name: Configure_2 jenkins
    action: shell sudo chown -R root:root /var/cache/jenkins/
  - name: Configure_3 jenkins
    action: shell sudo chown -R root:root /var/log/jenkins/
  - name: Configure_4 jenkins
    action: shell sudo service jenkins restart ps -ef | grep jenkins
*/