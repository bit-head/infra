provider "aws" {
    region = "us-west-2"
}

data "aws_ami" "sfgw" {
    most_recent = true
    filter {
        name = "name"
        values = ["sfp-server-example*"]
    }
    owners = ["self"]
}

module "network" {
    source = "modules/network"
    base_name = "${var.host_name}"
}

module "policy" {
    source = "modules/policy"
    base_name = "${var.host_name}"
}

module "dns" {
    source = "modules/dns"
    host_name = "${var.host_name}"
}

resource "aws_vpc" "sfgw_vpc" {
  cidr_block = "192.168.205.0/24"
}

resource "aws_launch_configuration" "sfgw_conf" {
  name_prefix   = "terraform-sfgw-lc"
  image_id      = "${data.aws_ami.sfgw.id}"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "sfgw_asg" {
  name                 = "terraform-sfgw-asg"
  launch_configuration = "${aws_launch_configuration.sfgw.name}"
  min_size             = 1
  max_size             = 2
  load_balancers = "${module.network.sfgw_elb.name}"
  vpc_zone_identifier = ["${module.network.subnet_a}","${module.network.subnet_b}"]
  lifecycle {
    create_before_destroy = true
  }
}