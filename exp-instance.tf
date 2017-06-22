
variable "something" {
  default = "nothing"
}

resource "aws_instance" "exp-instance" {
  # "Name": "debian-stretch-hvm-x86_64-gp2-2017-04-20-82073"
  ami           = "ami-bf31ecd0"
  instance_type = "t2.micro"
  security_groups = ["ssh-only"]

  key_name = "gabriel.klawitter+aws@relayr.io"

  connection {
    type = "ssh"
    host = "${aws_instance.exp-instance.public_ip}"
    user = "admin"
    private_key = "${file("~/.ssh/id_aws")}"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.exp-instance.public_ip} > ip_address.txt"
  }
  provisioner "file" {
    source      = "ip_address.txt"
    destination = "/tmp/ip_address.txt"
  }
  provisioner "remote-exec" {
    inline = [
      "echo ${var.something} > /tmp/remote-exec.out",
    ]
  }

  tags {
    Name = "experimental"
  }
}


resource "aws_security_group" "ssh-only" {
  name = "ssh-only"
  description = "Allow ssh access from anywhere."
  
  // These are for internal traffic
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    self = true
  }
  
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    self = true
  }
  
  // These are for maintenance
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // This is for outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


