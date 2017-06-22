


variable "something" {
  default = "nothing"
}


variable "remote_path" {
  default = "/tmp/git"
}

variable "repo_url" {
  default = "https://github.com/gabreal/refactored-octo-garbanzo.git"
}

data "template_file" "index" {
  template = "${file("www/index.html")}"

  vars {
    # machine_title = "${aws_instance.exp-instance.public_dns}"
    machine_title = "aws_instance.exp-instance.public_dns"
  }
}

# resource "null_resource" "local" {
#   triggers {
#     template = "${data.template_file.indexhtml.rendered}"
#   }
# }




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

  tags {
    Name = "experimental"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'apt-get update && apt-get install -y git lighttpd'",
      "git clone ${var.repo_url} ${var.remote_path}",
      "sudo sh -c 'sed \"s/%HOSTNAME%/${aws_instance.exp-instance.public_dns}/g\" ${var.remote_path}/index.html > /var/www/html/index.html'",
    ]
  }

  # known bug in v0.9.8 https://github.com/hashicorp/terraform/issues/15177
  # provisioner "file" {
  #   content = "${data.template_file.index.rendered}"
  #   destination = "/var/www/html/index.html"
  # }

  provisioner "local-exec" {
    # command = "echo ${aws_instance.exp-instance.public_ip} > ip_address.txt"
    command = "xdg-open http://${aws_instance.exp-instance.public_dns}/"
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

  // lighttpd web server
  ingress {
    from_port = 80
    to_port = 80
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

# output "index_html_template" {
#   value = ["${data.template_file.indexhtml.rendered}"]
# }


