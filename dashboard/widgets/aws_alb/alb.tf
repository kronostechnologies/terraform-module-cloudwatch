data "aws_region" "current" {}

variable "lb_arns" {
  type = "list"
}

data "aws_lb" "selected" {
  count = length(var.lb_arns)
  arn   = element(var.lb_arns, count.index)
}

data "template_file" "tpl" {
  count    = length(var.lb_arns)
  template = file("${path.module}/alb.json")

  vars = {
    region        = data.aws_region.current.name
    lb_arn_suffix = element(data.aws_lb.selected.*.arn_suffix, count.index)
    lb_name       = element(data.aws_lb.selected.*.tags.Name, count.index)
  }
}

output "output" {
  value = join(",",data.template_file.tpl.*.rendered)
}
