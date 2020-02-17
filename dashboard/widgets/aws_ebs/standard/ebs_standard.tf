variable "volumes" {
  type        = "list"
  description = "{instance-id, name-tag}"
}

variable "width" {
  default = 6
}

variable "height" {
  default = 5
}

data "aws_ebs_volume" "selected" {
  count = "${length(var.volumes)}"

  filter {
    name   = "attachment.instance-id"
    values = ["${lookup(var.volumes[count.index], "instance-id")}"]
  }

  filter {
    name   = "tag:Name"
    values = ["${lookup(var.volumes[count.index], "name-tag")}"]
  }
}

data "aws_instance" "selected" {
  count = "${length(var.volumes)}"

  filter {
    name   = "block-device-mapping.volume-id"
    values = ["${element(data.aws_ebs_volume.selected.*.id, count.index)}"]
  }
}

data "aws_availability_zone" "selected" {
  count = "${length(data.aws_ebs_volume.selected.*.id)}"
  name  = "${element(data.aws_ebs_volume.selected.*.availability_zone, count.index)}"
}

data "template_file" "tpl" {
  count    = "${length(var.volumes)}"
  template = "${file("${path.module}/ebs_standard.json")}"

  vars {
    width             = "${var.width}"
    height            = "${var.height}"
    instance_id       = "${element(data.aws_instance.selected.*.id, count.index)}"
    volume_name_tag   = "${lookup(var.volumes[count.index], "name-tag")}"
    volume_id         = "${element(data.aws_ebs_volume.selected.*.id, count.index)}"
    volume_region     = "${element(data.aws_availability_zone.selected.*.region, count.index)}"
    volume_filesystem = "${element(data.aws_ebs_volume.selected.*.tags.Volume_Filesystem, count.index)}"
    volume_mountpath  = "${element(data.aws_ebs_volume.selected.*.tags.Volume_MountPath, count.index)}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
