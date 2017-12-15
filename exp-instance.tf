
variable "remote_user" {
  default = "admin"
}

variable "remote_path" {
  # default = "${var.remote_user}/git"
  default = "/home/admin/git"
}

variable "repo_url" {
  default = "https://github.com/gabreal/refactored-octo-garbanzo.git"
}
    
variable "repo_key" {
  default = "/home/admin/.exp-instance.key"
}

# variable "environment" {}
variable "environment" {
  default = "experiment"
}

variable "consul_master_token" {
  default = "fake-unknown-token"
}

variable "consul_service_token" {
  default = "abcdefg-hijklmnop-qrstuvw-xyz"
}

variable "consul_service_permissions" {
  default = "key \\\"\\\" { policy = \\\"read\\\" }, operator = \\\"read\\\""
}

variable "domain" {
  default = "rlr-euc1-dev"
}

# variable "testvar" {
#   default = "${length(var.domain)}"
# }

# these are defined in the secret file
# variable "repo_keyfile" {}
# variable "passphrase" {}


# data "template_file" "index" {
#   template = "${file("www/index.html")}"
# 
#   vars {
#     machine_title = "${aws_instance.exp-instance.public_dns}"
#   }
# }



resource "aws_instance" "exp-instance" {
  # "Name": "debian-stretch-hvm-x86_64-gp2-2017-04-20-82073"
  ami           = "ami-bf31ecd0"
  instance_type = "t2.micro"
  security_groups = ["ssh-only", "rsyslog"]

  key_name = "gabriel.klawitter+aws@relayr.io"

  connection {
    type = "ssh"
    host = "${aws_instance.exp-instance.public_ip}"
    user = "${var.remote_user}"
    private_key = "${file("~/.ssh/id_aws")}"
  }

  tags {
    Name = "experimental"
    Environment = "${var.environment}"
    SomeTag = "useless"
  }


  provisioner "file" {
    source = "${var.repo_keyfile}"
    destination = "${var.repo_key}"
  }

  provisioner "file" {
    source = "xvfb.service"
    destination = "/tmp/xvfb.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'apt-get update && apt-get install -y git git-crypt lighttpd jq'",
      "sudo sh -c 'apt-get update && apt-get install -y zsh screen since xvfb x11vnc'",
      "sudo sh -c 'wget -O /etc/zsh/zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc'",
      "wget -O .zshrc https://git.grml.org/f/grml-etc-core/etc/skel/.zshrc",
      "sudo cp -v /home/admin/.zshrc /root/.zshrc",
      "sudo chsh -s /bin/zsh admin",
      "sudo chsh -s /bin/zsh root",
      "git clone ${var.repo_url} ${var.remote_path}",
      "cd ${var.remote_path} && git-crypt unlock ${var.repo_key}",
      "sudo sh -c 'sed \"s/%HOSTNAME%/${aws_instance.exp-instance.public_dns}/g\" ${var.remote_path}/www/index.html > /var/www/html/index.html'",
      "chmod 600 ${var.repo_key}",
      "sudo mv /tmp/xvfb.service /etc/systemd/system/xvfb.service",
      "systemctl enable --now /etc/systemd/system/xvfb.service",
    ]
  }

  # Xvfb :0 -screen 0 1024x768x24 (as a service)
  # ssh -L 5900:localhost:5900 ec2 'x11vnc -localhost -display :99 -many'
  # xtightvncviewer localhost:5900
  
  # known bug in v0.9.8 https://github.com/hashicorp/terraform/issues/15177
  # provisioner "file" {
  #   content = "${data.template_file.index.rendered}"
  #   destination = "/var/www/html/index.html"
  # }

  provisioner "local-exec" {
    # command = "echo ${aws_instance.exp-instance.public_ip} > ip_address.txt"
#     command = <<EOT
# EOT
    command = "xdg-open http://${aws_instance.exp-instance.public_dns}/"
  }

  provisioner "local-exec" {
    command = "sed -i -r '/Host ec2/,+3 s/^  HostName.*compute.amazonaws.com/  HostName      ${aws_instance.exp-instance.public_dns}/' ~/.ssh/config.static ~/.ssh/config"
  }

  provisioner "local-exec" {
    # add the service token to consul
    command = "curl --retry-max-time 180 --retry-delay 10 --retry 20 --retry-connrefused -s --header \"X-Consul-Token: ${var.consul_master_token}\" -X PUT --data '{ \"ID\": \"${var.consul_service_token}\", \"Name\": \"service token\", \"Type\": \"client\", \"Rules\": \"${var.consul_service_permissions}\" }' http://consul.${var.domain}/v1/acl/update"
  }
}


# output "index_html_template" {
#   value = ["${data.template_file.indexhtml.rendered}"]
# }


