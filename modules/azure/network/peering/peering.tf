variable "resource_group_name_1" {}
variable "virtual_network_name_1" {}
variable "virtual_network_id_1" {}

variable "resource_group_name_2" {}
variable "virtual_network_name_2" {}
variable "virtual_network_id_2" {}


resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "peer1to2"
  resource_group_name       = "${var.resource_group_name_1}"
  virtual_network_name      = "${var."virtual_network_name_1}"
  remote_virtual_network_id = "${var.virtual_network_id_2}"
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peer2to1"
  resource_group_name       = "${var.resource_group_name_2}"
  virtual_network_name      = "${var."virtual_network_name_2}"
  remote_virtual_network_id = "${var.virtual_network_id_1}"
}
