# header_widget
variable "name" {
  type = "string"
}

data "template_file" "header_widget" {
  template = "${file("${path.module}/header.json")}"

  vars {
    header = "${var.name}"
  }
}

output "output" {
  value = "${join(",",data.template_file.header_widget.*.rendered)}"
}
