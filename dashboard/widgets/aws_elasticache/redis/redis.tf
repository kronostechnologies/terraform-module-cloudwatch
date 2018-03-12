variable "cluster_ids" {
  type = "list"
}

variable "width" {
  default = 4
}

variable "height" {
  default = 4
}

data "aws_elasticache_cluster" "selected" {
  count      = "${length(var.cluster_ids)}"
  cluster_id = "${element(var.cluster_ids, count.index)}"
}

data "aws_availability_zone" "selected" {
  count = "${length(data.aws_elasticache_cluster.selected.*.id)}"
  name  = "${element(data.aws_elasticache_cluster.selected.*.cache_nodes.0.availability_zone, count.index)}"
}

data "template_file" "tpl" {
  count    = "${length(data.aws_elasticache_cluster.selected.*.id)}"
  template = "${file("${path.module}/redis.json")}"

  vars {
    width      = "${var.width}"
    height     = "${var.height}"
    region     = "${element(data.aws_availability_zone.selected.*.region, count.index)}"
    cluster_id = "${element(data.aws_elasticache_cluster.selected.*.id,count.index)}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
