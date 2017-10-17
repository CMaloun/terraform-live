variable "resource_group_name" {}
variable "prefix" {}
variable "location" {}
variable "address_space" { }
variable "dns_servers" {type = "list"}
variable "subnet_prefixes" {type = "list"}
variable "subnet_names" {type = "list"}
variable "tags" { type = "map"}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resource_group_name}"
  dns_servers         = "${var.dns_servers}"
  tags                = "${var.tags}"

}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_names[count.index]}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${var.resource_group_name}"
  address_prefix       = "${var.subnet_prefixes[count.index]}"
  count                =  "${length(var.subnet_names)}"
}

output "vnet_name" { value = "${azurerm_virtual_network.vnet.name}" }
output "vnet_id" {value = "${azurerm_virtual_network.vnet.id}"}
output "nsg_subnets" { value = "${azurerm_subnet.subnet.*.id}" }
