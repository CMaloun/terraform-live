module "web" {
  source = "../../../modules/azure/compute/web"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"
  location = "${azurerm_resource_group.sandbox.location}"
  address_space = "10.0.0.0/16"
  vm_computername = "web"
  vm_name_prefix = "ra-ntier-web"
  admin_password = "AweS0me@PW"
  storage_account_name = "jbaccounte"
  prefix = "ts"
  # security_group_name = "${module.network.nsg_name}"
  # security_group_id = "${module.network.nsg_id}"
  subnet_id = "${module.network.nsg_subnets[0]}"

}
