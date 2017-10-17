variable "resource_group_name" {}
variable "prefix" {}
variable "location" {}
variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "tags" { type = "map"}

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
    key                  = "sandbox.network.terraform.tfstate"
    access_key = "hlktSi5s6rjmTnX6lZCfaE6fVHj7Hd8+gF0XDQv+ZIOgMwjkssBgrtzndNNtxELkKjwph/XZMF1poDYRCzDyiQ=="
    resource_group_name  = "terraformstorage"
  }
}

# create a resource group
resource "azurerm_resource_group" "sandbox" {
  name = "${var.resource_group_name}"
  location = "${var.location}"
}

module "network" {
  source = "../../../../modules/azure/network/vnet"
  resource_group_name = "${azurerm_resource_group.sandbox.name}"
  location = "${var.location}"
  prefix = "${var.prefix}"
  tags = "${var.tags}"
  address_space = "10.0.0.0/16"
  dns_servers = [
        "10.0.4.4",
        "10.0.4.5",
        "168.63.129.16"
      ]
  subnet_prefixes = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24",
      "10.0.4.0/24",
      "10.0.0.128/25"
  ]
  subnet_names = [
      "web",
      "biz",
      "sql",
      "ad",
      "mgmt"]
}

output "vnet_name" { value = "${module.network.vnet_name}" }
output "vnet_id" {value = "${module.network.vnet_id}"}
output "nsg_subnets" { value = "${module.network.nsg_subnets}" }
