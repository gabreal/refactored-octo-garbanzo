
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

  ingress {
    from_port = 8080
    to_port = 8080
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


resource "aws_security_group" "rsyslog" {
  name = "rsyslog"
  description = "accept remote logs"

  # ingress {
  #   from_port = 514
  #   to_port = 514
  #   protocol = "udp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    from_port = 514
    to_port = 514
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

