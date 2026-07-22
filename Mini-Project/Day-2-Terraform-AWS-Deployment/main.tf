resource "aws_instance" "web" {

  ami                    = var.ami
  instance_type          = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = file("userdata.sh")

  tags = {
    Name = "MiniApp-Server"
  }

}