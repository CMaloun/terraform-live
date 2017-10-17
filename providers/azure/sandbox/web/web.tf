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
variable "subnet_prefix" {}

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
    key                  = "sandbox.web.terraform.tfstate"
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

module "web" {
  source = "../../../../modules/azure/compute/web"
  resource_group_name = "${var.resource_group_name}"
  location = "${var.location}"
  prefix = "${var.prefix}"
  storage_account_name = "${var.storage_account_name}"
  vm_computer_name = "${var.vm_computer_name}"
  vm_name_prefix = "${var.vm_name_prefix}"
  vm_admin_password =  "${var.vm_admin_password}"
  vm_admin_username = "${var.vm_admin_username}"
  subnet_id = "${data.terraform_remote_state.network.nsg_subnets[0]}"
}

module "security_web" {
  source = "../../../../modules/azure/network/security/web"
  resource_group_name = "${var.resource_group_name}"
  location = "${var.location}"
  network_security_group_name = "web-nsg"
  virtual_network_name = "${data.terraform_remote_state.network.vnet_name}"
  subnet_prefix = "${var.subnet_prefix}"
  allow-web-traffic-from-external = {
                        name = "allow-web-traffic-from-external"
                        description = "Allow web traffic originating externally."
                        protocol = "*"
                        sourcePortRange = "*"
                        destinationPortRange = "80"
                        sourceAddressPrefix = "*"
                        destinationAddressPrefix = "*"
                        access = "Allow"
                        priority = 100
                        direction = "Inbound"
            }
  allow-web-traffic-from-vnet = {
                        name = "allow-web-traffic-from-vnet"
                        description = "Allow web traffic originating from vnet."
                        protocol = "*"
                        sourcePortRange = "*"
                        destinationPortRange = "80"
                        sourceAddressPrefix = "10.0.0.0/16"
                        destinationAddressPrefix = "*"
                        access = "Allow"
                        priority = 110
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
                        priority = 120
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
                        priority = 130
                        direction = "Inbound"
   }
}
