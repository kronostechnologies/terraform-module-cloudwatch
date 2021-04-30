variable "name" {
  type = string
}

variable "widgets" {
  type = list
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.name
  dashboard_body = indent(2, data.template_file.dashboard_body.rendered)
}

data "template_file" "dashboard_body" {
  template = <<TPL
{
  "widgets": [
    $${widgets}
  ]
}
TPL

  vars = {
    widgets = indent(2,join(",", data.template_file.widget_list.*.rendered))
  }
}

data "template_file" "widget_list" {
  count = length(var.widgets)

  template = <<TPL
$${widget}
TPL

  vars = {
    widget = element(var.widgets, count.index)
  }
}

# # dev
# output "template" {
#   value = <<EOF
#      "${indent(2,join(",",data.template_file.dashboard_body.*.rendered))}"
# EOF
# }

