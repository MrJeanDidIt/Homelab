variable "pm_endpoint" {
  type = string
}

variable "pm_api_token" {
  type      = string
  sensitive = true
}

variable "node_name" {
  type    = string
  default = "pve"
}

variable "template_id" {
  type    = number
  default = 9000
}

variable "gateway" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "k3s_nodes" {
  type = map(object({
    vm_id  = number
    ip     = string
    cores  = number
    memory = number
  }))
}
