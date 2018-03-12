variable "cluster_identifiers" {
  type = "list"
}

variable "width" {
  default = 8
}

variable "height" {
  default = 6
}

data "aws_rds_cluster" "selected" {
  count              = "${length(var.cluster_identifiers)}"
  cluster_identifier = "${element(var.cluster_identifiers, count.index)}"
}

data "aws_availability_zone" "selected" {
  count = "${length(data.aws_rds_cluster.selected.*.id)}"
  name  = "${element(data.aws_rds_cluster.selected.*.availability_zones[0], count.index)}"
}

data "template_file" "tpl" {
  count    = "${length(data.aws_rds_cluster.selected.*.id)}"
  template = "${file("${path.module}/aurora.json")}"

  vars {
    width              = "${var.width}"
    height             = "${var.height}"
    region             = "${element(data.aws_availability_zone.selected.*.region, count.index)}"
    cluster_identifier = "${element(data.aws_rds_cluster.selected.*.id,count.index)}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
