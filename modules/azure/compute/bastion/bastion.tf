
resource "azurerm_storage_account" "sto-vm0" {
  name                     = "${var.storage_account_name}"  #It would be better to have a unique identifier
  location                 = "${var.location}"
  resource_group_name      = "${var.resource_group_name}"
  account_kind             = "${var.storage_account_kind}"
  account_type             = "${var.storage_account_type}"
}

resource "azurerm_public_ip" "bastionpip" {
    name                         = "pipBastion"
    location                     = "${var.location}"
    resource_group_name          = "${var.resource_group_name}"
    public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "nicBastion"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  enable_ip_forwarding = "${var.enabled_ip_forwarding}"

  ip_configuration {
    name                          = "ipconfigbastion"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.bastionpip.id}"
    primary = "true"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.vm_name_prefix}-vm"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "${var.vm_name_prefix}-vm-os.vhd"
    vhd_uri       = "https://${azurerm_storage_account.sto-vm0.name}.blob.core.windows.net/${azurerm_storage_account.sto-vm0.name}-vhds/${var.vm_name_prefix}-vm-os.vhd"
    create_option = "FromImage"
    caching = "ReadWrite"
  }

  storage_data_disk {
    name            = "${var.vm_name_prefix}-vm-dataDisk1.vhd"
    vhd_uri         = "https://${azurerm_storage_account.sto-vm0.name}.blob.core.windows.net/${azurerm_storage_account.sto-vm0.name}-vhds/${var.vm_name_prefix}-vm-dataDisk1.vhd"
    create_option   = "Empty"
    lun             = 0
    disk_size_gb    = "128"
  }


  os_profile {
    computer_name  = "${var.vm_computer_name}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }
}

resource "azurerm_virtual_machine_extension" "iaas" {
  name                 = "IaaSAntimalware"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm.name}"
  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"
  depends_on           = ["azurerm_virtual_machine.vm"]

  settings = <<SETTINGS
  {
            "AntimalwareEnabled": true,
            "RealtimeProtectionEnabled": "true",
            "ScheduledScanSettings": {
              "isEnabled": "false",
              "day": "7",
              "time": "120",
              "scanType": "Quick"
            },
            "Exclusions": {
              "Extensions": "",
              "Paths": "",
              "Processes": ""
            }
          }
SETTINGS
}

output "bastion_id" { value = "${azurerm_virtual_machine.vm.id}" }
