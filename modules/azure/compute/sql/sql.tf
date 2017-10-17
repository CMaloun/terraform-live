variable "resource_group_name" {}
variable "location" {}
variable "storage_account_name" {}
variable "storage_account_type" {default = "Standard_GRS"}
variable "storage_account_kind" {default = "Storage"}
variable "storage_account_tier" {default     = "Standard"}
variable "storage_account_replication_type" {default     = "LRS"}
variable "enabled_ip_forwarding" {default = false}
variable "subnet_id" {}
variable "vm_admin_username" {default = "testuser"}
variable "vm_admin_password" {}
variable "vm_size" { default = "Standard_DS1_v2" }

#virtual machines variables
variable "vm_name_prefix" {}
variable "vm_computer_name" {}

resource "azurerm_storage_account" "sto-sql-vm0" {
  name                     = "${var.storage_account_name}sqlvm0"  #It would be better to have a unique identifier
  location                 = "${var.location}"
  resource_group_name      = "${var.resource_group_name}"
  account_kind             = "${var.storage_account_kind}"
  account_type             = "${var.storage_account_type}"
}

resource "azurerm_network_interface" "nic" {
  name                = "nicSQL${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  enable_ip_forwarding = "${var.enabled_ip_forwarding}"
  count = 1

  ip_configuration {
    name                          = "ipconfigSQL${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    primary =  "true"
  }

  dns_servers =  ["10.0.4.4", "10.0.4.5"]
}


resource "azurerm_virtual_machine" "vm0" {
  name                  = "${var.vm_name_prefix}-vm0"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, 0)}"]
  # availability_set_id   = "${azurerm_availability_set.ad-as.id}"

  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2014SP2-WS2012R2"
    sku       = "Enterprise"
    version   = "latest"
  }


  storage_os_disk {
    name          = "${var.vm_name_prefix}-vm0-os.vhd"
    vhd_uri       = "https://${azurerm_storage_account.sto-sql-vm0.name}.blob.core.windows.net/${azurerm_storage_account.sto-sql-vm0.name}-vhds/${var.vm_name_prefix}-vm0-os.vhd"
    create_option = "FromImage"
    caching = "ReadWrite"
  }

  storage_data_disk {
    name            = "${var.vm_name_prefix}-sqlvm0-dataDisk1.vhd"
    vhd_uri         = "https://${azurerm_storage_account.sto-sql-vm0.name}.blob.core.windows.net/${azurerm_storage_account.sto-sql-vm0.name}-vhds/${var.vm_name_prefix}-sqlvm0-dataDisk1.vhd"
    create_option   = "Empty"
    lun             = 0
    disk_size_gb    = "128"
  }

  storage_data_disk {
    name            = "${var.vm_name_prefix}-sqlvm0-dataDisk2.vhd"
    vhd_uri         = "https://${azurerm_storage_account.sto-sql-vm0.name}.blob.core.windows.net/${azurerm_storage_account.sto-sql-vm0.name}-vhds/${var.vm_name_prefix}-sqlvm0-dataDisk2.vhd"
    create_option   = "Empty"
    lun             = 1
    disk_size_gb    = "128"
  }

  os_profile {
    computer_name  = "${var.vm_computer_name}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }
}

resource "azurerm_virtual_machine_extension" "join-ad-domain" {
name = "join-ad-domain"
location = "${var.location}"
resource_group_name = "${var.resource_group_name}"
virtual_machine_name = "${azurerm_virtual_machine.vm0.name}"
publisher = "Microsoft.Compute"
type = "JsonADDomainExtension"
type_handler_version = "1.3"
depends_on = ["azurerm_virtual_machine.vm0"]

  settings = <<SETTINGS
  {
    "Name": "contoso.com",
    "OUPath": "",
    "User": "contoso.com\\testuser",
    "Restart": true,
    "Options": 3
  }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "Password": "AweS0me@PW"
  }
PROTECTED_SETTINGS
}
