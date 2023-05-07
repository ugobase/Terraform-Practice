provider "aws" {
  region = var.region

}

resource "aws_default_vpc" "default" {
}


resource "aws_security_group" "Nexus" {
  name   = "Nexus"
  vpc_id = aws_default_vpc.default.id
  dynamic "ingress" {
    for_each = [22, 8081]
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }



  #dynamic "ingress" {
  #for_each = local.base
  #content{
  #from_port = ingress.value.port
  #to_port = ingress.value.port
  #protocol = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  #}
  #}

}


resource "aws_security_group" "Sonarqube" {
  name   = "Sonarqube"
  vpc_id = aws_default_vpc.default.id


  ingress {
    from_port   = "9000"
    to_port     = "9000"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "Maven" {
  name   = "Maven"
  vpc_id = aws_default_vpc.default.id


  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }



}



resource "aws_instance" "Maven" {
  ami                    = data.aws_ami.linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Maven.id]
  key_name               = var.key_name

  tags = {
    Name = "${local.name3}-server"
  }



  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = var.user
    private_key = file(var.private_key)
  }


}


resource "aws_instance" "Nexus" {
  ami                    = data.aws_ami.linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Nexus.id]
  user_data              = file("nexus_userdata.tpl")
  key_name               = var.key_name
  tags = {
    Name = "${local.name2}-server"

  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = var.user
    private_key = file(var.private_key)
  }

}

resource "aws_instance" "Sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Sonarqube.id]
  user_data              = file("sonarqube_userdata.tpl")
  tags = {
    Name = "${local.name1}-server"

  }

}

