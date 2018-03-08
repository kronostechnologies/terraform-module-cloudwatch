variable "vpc_id" {}

variable "tags" {
  type = "map"
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${var.vpc_id}"
  tags   = "${var.tags}"
}

data "aws_nat_gateway" "selected" {
  count     = "${length(data.aws_subnet_ids.selected.ids)}"
  subnet_id = "${element(data.aws_subnet_ids.selected.ids, count.index)}"
}

data "aws_subnet" "selected" {
  count = "${length(data.aws_subnet_ids.selected.ids)}"
  id    = "${element(data.aws_subnet_ids.selected.ids, count.index)}"
}

data "aws_availability_zone" "selected" {
  count = "${length(data.aws_subnet.selected.*.id)}"
  name  = "${element(data.aws_subnet.selected.*.availability_zone, count.index)}"
}

data "template_file" "tpl" {
  count    = "${length(data.aws_nat_gateway.selected.*.id)}"
  template = "${file("${path.module}/nat_gateway.json")}"

  vars {
    nat_region      = "${element(data.aws_availability_zone.selected.*.region, count.index)}"
    nat_gateway_id  = "${element(data.aws_nat_gateway.selected.*.id, count.index)}"
    nat_public_ip   = "${element(data.aws_nat_gateway.selected.*.public_ip, count.index)}"
    nat_subnet_name = "${element(data.aws_subnet.selected.*.tags.Name, count.index)}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
