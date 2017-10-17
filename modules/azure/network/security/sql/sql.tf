variable "resource_group_name" {}
variable "location" {}
variable "network_security_group_name" {}
variable "virtual_network_name" {}
variable "subnet_prefix" {}
variable "security_rule_from_web" {type = "map"}
variable "allow-mgmt-rdp" {type = "map"}
variable "deny-other-traffic_rule" {type = "map"}

resource "azurerm_network_security_group" "security_group" {
  name                  = "${var.network_security_group_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "sql"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.resource_group_name}"
  address_prefix       = "${var.subnet_prefix}"
  network_security_group_id = "${azurerm_network_security_group.security_group.id}"
}

resource "azurerm_network_security_rule" "security_rule_from_web" {
  name                     = "${var.security_rule_from_web["name"]}"
  priority                     = "${var.security_rule_from_web["priority"]}"
  direction                   = "${var.security_rule_from_web["direction"]}"
  access                      = "${var.security_rule_from_web["access"]}"
  protocol                    = "${var.security_rule_from_web["protocol"]}"
  source_port_range           = "${var.security_rule_from_web["sourcePortRange"]}"
  destination_port_range      = "${var.security_rule_from_web["destinationPortRange"]}"
  source_address_prefix       = "${var.security_rule_from_web["sourceAddressPrefix"]}"
  destination_address_prefix  = "${var.security_rule_from_web["destinationAddressPrefix"]}"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${var.network_security_group_name}"
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
  network_security_group_name = "${var.network_security_group_name}"
}
