variable "web_acl" {
  type = "string"
}

variable "width" {
  default = 6
}

variable "height" {
  default = 5
}

data "template_file" "tpl" {
  template = "${file("${path.module}/waf.json")}"

  vars = {
    width   = "${var.width}"
    height  = "${var.height}"
    web_acl = "${var.web_acl}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
