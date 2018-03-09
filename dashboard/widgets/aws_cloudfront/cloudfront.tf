variable "distribution_id" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "width" {
  default = 12
}

variable "height" {
  default = 5
}

data "template_file" "tpl" {
  template = "${file("${path.module}/cloudfront.json")}"

  vars {
    width           = "${var.width}"
    height          = "${var.height}"
    distribution_id = "${var.distribution_id}"
    domain          = "${var.domain}"
  }
}

output "output" {
  value = "${join(",",data.template_file.tpl.*.rendered)}"
}
