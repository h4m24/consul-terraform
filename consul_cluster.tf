# aws config
provider "aws" {
 access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.ec2_region}"
}


# create consul machines
resource "aws_instance" "consul-machine" {
  ami           = "${var.main_ami}"
  instance_type = "${var.ec2_size}"
  count         = "${var.num_of_servers}"
  key_name      = "${var.terraform-ssh-key}"

  vpc_security_group_ids  =  ["${var.security_group_id}"]
  tags { Name = "consul-machine-00${count.index}" }

connection {
  user = "ubuntu"
}



provisioner "remote-exec" {
    inline = [
    # install salt-minion
    "export LC_ALL=C",
    "wget -O  - http://bootstrap.saltstack.org | sudo sh"
    ]
}
provisioner "remote-exec" {
    inline = [
         # tell salt-minion to look for the state tree in
         # the local file system, with the --local flag.
        "sudo salt-call --local state.highstate"
    ]
}

}

# Create a load balancer
resource "aws_elb" "consul-cluster" {

  name = "consul-cluster-elb"

  availability_zones = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]

  listener {
    instance_port = 8080
    instance_protocol = "http"

    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "tcp:8080"
    interval = 30
  }

  instances = [ "${aws_instance.consul-machine.*.id}" ]

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "consul-cluster-elb"
  }
}

output "address" {
  value = "${aws_elb.consul-cluster.dns_name}"
  value = "${join(" , ", aws_instance.consul-machine.*.public_ip)}"
  }
