variable "resource_group_name" {}
variable "location" {}
variable "network_security_group_name" {}
variable "virtual_network_name" {}
variable "subnet_prefix" {}
variable "allow-web-traffic-from-external" {type = "map"}
variable "allow-web-traffic-from-vnet" {type = "map"}
variable "allow-mgmt-rdp" {type = "map"}
variable "deny-other-traffic_rule" {type = "map"}

resource "azurerm_network_security_group" "security_group" {
  name                  = "${var.network_security_group_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "web"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.resource_group_name}"
  address_prefix       = "${var.subnet_prefix}"
  network_security_group_id = "${azurerm_network_security_group.security_group.id}"
}

resource "azurerm_network_security_rule" "allow-mgmt-rdp" {
  name                     = "${var.allow-mgmt-rdp["name"]}"
  priority                     = "${var.allow-mgmt-rdp["priority"]}"
  direction                   = "${var.allow-mgmt-rdp["direction"]}"
  access                      = "${var.allow-mgmt-rdp["access"]}"
  protocol                    = "${var.allow-mgmt-rdp["protocol"]}"
  source_port_range           = "${var.allow-mgmt-rdp["sourcePortRange"]}"
  destination_port_range      = "${var.allow-mgmt-rdp["destinationPortRange"]}"
  source_address_prefix       = "${var.allow-mgmt-rdp["sourceAddressPrefix"]}"
  destination_address_prefix  = "${var.allow-mgmt-rdp["destinationAddressPrefix"]}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.security_group.name}"
}

resource "azurerm_network_security_rule" "allow-web-traffic-from-vnet" {
  name                     = "${var.allow-web-traffic-from-vnet["name"]}"
  priority                     = "${var.allow-web-traffic-from-vnet["priority"]}"
  direction                   = "${var.allow-web-traffic-from-vnet["direction"]}"
  access                      = "${var.allow-web-traffic-from-vnet["access"]}"
  protocol                    = "${var.allow-web-traffic-from-vnet["protocol"]}"
  source_port_range           = "${var.allow-web-traffic-from-vnet["sourcePortRange"]}"
  destination_port_range      = "${var.allow-web-traffic-from-vnet["destinationPortRange"]}"
  source_address_prefix       = "${var.allow-web-traffic-from-vnet["sourceAddressPrefix"]}"
  destination_address_prefix  = "${var.allow-web-traffic-from-vnet["destinationAddressPrefix"]}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.security_group.name}"
}

resource "azurerm_network_security_rule" "allow-web-traffic-from-external" {
  name                     = "${var.allow-web-traffic-from-external["name"]}"
  priority                     = "${var.allow-web-traffic-from-external["priority"]}"
  direction                   = "${var.allow-web-traffic-from-external["direction"]}"
  access                      = "${var.allow-web-traffic-from-external["access"]}"
  protocol                    = "${var.allow-web-traffic-from-external["protocol"]}"
  source_port_range           = "${var.allow-web-traffic-from-external["sourcePortRange"]}"
  destination_port_range      = "${var.allow-web-traffic-from-external["destinationPortRange"]}"
  source_address_prefix       = "${var.allow-web-traffic-from-external["sourceAddressPrefix"]}"
  destination_address_prefix  = "${var.allow-web-traffic-from-external["destinationAddressPrefix"]}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.security_group.name}"
}

resource "azurerm_network_security_rule" "deny-other-traffic_rule" {
  name                     = "${var.deny-other-traffic_rule["name"]}"
  priority                     = "${var.deny-other-traffic_rule["priority"]}"
  direction                   = "${var.deny-other-traffic_rule["direction"]}"
  access                      = "${var.deny-other-traffic_rule["access"]}"
  protocol                    = "${var.deny-other-traffic_rule["protocol"]}"
  source_port_range           = "${var.deny-other-traffic_rule["sourcePortRange"]}"
  destination_port_range      = "${var.deny-other-traffic_rule["destinationPortRange"]}"
  source_address_prefix       = "${var.deny-other-traffic_rule["sourceAddressPrefix"]}"
  destination_address_prefix  = "${var.deny-other-traffic_rule["destinationAddressPrefix"]}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.security_group.name}"
}
