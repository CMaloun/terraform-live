variable "resource_group_name" {}
variable "prefix" {}
variable "location" {}
variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "storage_account_name" {}
variable "vm_computer_name" {}
variable "vm_name_prefix" {}
variable "vm_admin_password" {}
variable "vm_admin_username" {}

provider "azurerm" {
    client_id = "${var.client_id}" #"ff2151a0-198f-4716-a58b-f17a8d103292"
    client_secret = "${var.client_secret}"#"817d8ab7-8cf9-4193-8533-29c0b510fa1e"
    subscription_id = "${var.subscription_id}"#"c92d99d5-bf52-4de7-867f-a269bbc19b3d"
    tenant_id ="${var.tenant_id}"  #"461a774b-c94c-4ea0-b027-311a135d9234"
}

terraform {
  backend "azurerm" {
    storage_account_name = "terraformstoragesandbox"
    container_name       = "terraform"
    key                  = "sandbox.bastion.terraform.tfstate"
    access_key = "hlktSi5s6rjmTnX6lZCfaE6fVHj7Hd8+gF0XDQv+ZIOgMwjkssBgrtzndNNtxELkKjwph/XZMF1poDYRCzDyiQ=="
    resource_group_name  = "terraformstorage"
  }
}

data "terraform_remote_state" "network" {
  backend = "azure"
  config {
    storage_account_name = "terraformstoragesandbox"
    container_name       = "terraform"
    key                  = "sandbox.network.terraform.tfstate"
    access_key = "hlktSi5s6rjmTnX6lZCfaE6fVHj7Hd8+gF0XDQv+ZIOgMwjkssBgrtzndNNtxELkKjwph/XZMF1poDYRCzDyiQ=="
    resource_group_name  = "terraformstorage"
  }
}

module "bastion" {
		source = "../../../../modules/azure/compute/bastion"
		resource_group_name = "${var.resource_group_name}"
		location = "${var.location}"
		prefix = "${var.prefix}"
		storage_account_name = "${var.storage_account_name}"
		subnet_id = "${data.terraform_remote_state.network.nsg_subnets[4]}"
		vm_computer_name = "${var.vm_computer_name}"
		vm_name_prefix = "${var.vm_name_prefix}"
		vm_admin_password =  "${var.vm_admin_password}"
    vm_admin_username = "${var.vm_admin_username}"
    network_security_group_name = "bastion-nsg"
	}
