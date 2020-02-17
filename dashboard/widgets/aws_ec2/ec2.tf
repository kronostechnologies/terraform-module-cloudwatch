# input: a list of EC2 instances-ids
# output: Widget template of CPU/RAM/DISK/NET
data "aws_region" "current" {}

variable "tags" {
  type = "map"
}

variable "width" {
  default = 8
}

variable "height" {
  default = 5
}

data "aws_instances" "tagged" {
  instance_tags = "${var.tags}"
}

data "aws_instance" "selected" {
  count       = "${length(data.aws_instances.tagged.ids)}"
  instance_id = "${element(data.aws_instances.tagged.ids, count.index)}"
}

data "aws_availability_zone" "selected" {
  count = "${length(data.aws_instance.selected.*.id)}"
  name  = "${element(data.aws_instance.selected.*.availability_zone, count.index)}"
}

data "template_file" "tpl" {
  count    = "${length(data.aws_instance.selected.*.id)}"
  template = "${file("${path.module}/ec2_instances.json")}"

  vars = {
    width           = "${var.width}"
    height          = "${var.height}"
    instance_region = "${element(data.aws_availability_zone.selected.*.region, count.index)}"
    instance_id     = "${element(data.aws_instance.selected.*.id, count.index)}"
    instance_name   = "${element(data.aws_instance.selected.*.tags.Name, count.index)}"
    root_volume     = "${element(data.aws_instance.selected.*.root_block_device.0.volume_id, count.index)}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
