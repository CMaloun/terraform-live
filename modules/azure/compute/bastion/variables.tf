variable "resource_group_name" {}
variable "prefix" {}
variable "location" {}

#virtual machines variables
variable "vm_name_prefix" {}
variable "vm_computer_name" {}
variable "vm_size" { default = "Standard_DS1_v2" }
variable "image_publisher" { default = "MicrosoftWindowsServer"}
variable "image_offer" { default = "WindowsServer"}
variable "image_sku" { default = "2012-R2-Datacenter"}
variable "image_version" {default = "latest"}
variable "vm_admin_username" {default = "testuser"}
variable "vm_admin_password" {}

#storage account variables
variable "storage_account_name" {}
variable "storage_account_type" {default = "Standard_GRS"}
variable "storage_account_kind" {default = "Storage"}
variable "storage_account_tier" {default     = "Standard"}
variable "storage_account_replication_type" {default     = "LRS"}
variable "network_security_group_name" {}


#network interface variables
variable "enabled_ip_forwarding" {default = false}
variable "subnet_id" {}
