module "sql" {
  source = "../../../modules/azure/compute/sql"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"
  location = "${azurerm_resource_group.sandbox.location}"
  address_space = "10.0.0.0/16"
  vm_computername = "sql"
  vm_name_prefix = "ra-ntier-sql"
  admin_password = "AweS0me@PW"
  storage_account_name = "jbaccounte"
  prefix = "ts"
  # security_group_name = "${module.network.nsg_name}"
  # security_group_id = "${module.network.nsg_id}"
  subnet_id = "${module.network.nsg_subnets[2]}"

}

module "security_sql" {
  source = "../../../modules/azure/network/security/sql"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"
  location = "${azurerm_resource_group.sandbox.location}"
  network_security_group_name = "ra-ntier-sql-nsg"
  virtual_network_name = "ts-vnet"
  subnet_prefix = "10.0.3.0/24"
  security_rule_from_web = {
              name = "allow-traffic-from-web"
              protocol = "*"
              sourcePortRange = "*"
              destinationPortRange = "1433"
              sourceAddressPrefix = "10.0.1.0/24"
              destinationAddressPrefix = "*"
              access = "Allow"
              priority = 100
              direction = "Inbound"
            }
  allow-mgmt-rdp = {
                        name = "allow-mgmt-rdp"
                        protocol = "*"
                        sourcePortRange = "*"
                        destinationPortRange = "3389"
                        sourceAddressPrefix = "10.0.0.128/25"
                        destinationAddressPrefix = "*"
                        access = "Allow"
                        priority = 110
                        direction = "Inbound"
                      }
deny-other-traffic_rule = {
      name = "deny-other-traffic_rule"
      protocol = "*"
      sourcePortRange = "*"
      destinationPortRange = "*"
      sourceAddressPrefix = "*"
      destinationAddressPrefix = "*"
      access = "Deny"
      priority = 120
      direction = "Inbound"
  }
