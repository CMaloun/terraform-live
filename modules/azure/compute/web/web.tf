variable "resource_group_name" {}
variable "prefix" {}
variable "location" {}
variable "storage_account_name" {}
variable "storage_account_type" {default = "Standard_GRS"}
variable "storage_account_kind" {default = "Storage"}
variable "storage_account_tier" {default     = "Standard"}
variable "storage_account_replication_type" {default     = "LRS"}
variable "enabled_ip_forwarding" {default = false}
variable "subnet_id" {}
variable "vm_computer_name" {}
variable "vm_name_prefix" {}
variable "vm_admin_password" {}
variable "vm_admin_username" {}
variable "vm_size" { default = "Standard_DS1_v2" }


resource "azurerm_availability_set" "web-as" {
  name                = "web-as"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_storage_account" "sto-web-vm" {
  name                     = "${var.storage_account_name}webvm${count.index}"  #It would be better to have a unique identifier
  location                 = "${var.location}"
  resource_group_name      = "${var.resource_group_name}"
  account_kind             = "${var.storage_account_kind}"
  account_type             = "${var.storage_account_type}"
  count = 2
}

resource "azurerm_public_ip" "lbpip" {
  name                         = "${var.prefix}-lbpip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_lb" "web-lb" {
  resource_group_name = "${var.resource_group_name}"
  name                = "${var.prefix}-web-lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "web-lb-fe-config1"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.web-lb.id}"
  name                           = "lbr1"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "web-lb-fe-config1"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
  name                = "lb-bep1"
}


resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
  name                = "lbp1"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}

# virtual-machines
#
resource "azurerm_network_interface" "nic" {
  name                = "nicWEB${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  enable_ip_forwarding = "${var.enabled_ip_forwarding}"
  count = 2

  ip_configuration {
    name                          = "ipconfigWeb${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
    primary =  "true"
  }
}


resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.vm_name_prefix}-vm${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  availability_set_id   = "${azurerm_availability_set.web-as.id}"
  count = 2

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.vm_name_prefix}-vm${count.index}-os.vhd"
    vhd_uri       = "https://${element(azurerm_storage_account.sto-web-vm.*.name, count.index)}.blob.core.windows.net/${element(azurerm_storage_account.sto-web-vm.*.name, count.index)}-vhds/${var.vm_name_prefix}-vm${count.index}-os.vhd"
    create_option = "FromImage"
    caching = "ReadWrite"
 }

  storage_data_disk {
    name            = "${var.vm_name_prefix}-vm${count.index}-dataDisk1.vhd"
    vhd_uri         = "https://${element(azurerm_storage_account.sto-web-vm.*.name, count.index)}.blob.core.windows.net/${element(azurerm_storage_account.sto-web-vm.*.name, count.index)}-vhds/${var.vm_name_prefix}-vm${count.index}-dataDisk1.vhd"
    create_option   = "Empty"
    lun             = 0
    disk_size_gb    = "128"
  }

  os_profile {
    computer_name  = "${var.vm_computer_name}${count.index}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }
}

resource "azurerm_virtual_machine_extension" "join-ad-domain" {
name = "join-ad-domain"
location = "${var.location}"
resource_group_name = "${var.resource_group_name}"
virtual_machine_name = "${element(azurerm_virtual_machine.vm.*.name, count.index)}"
publisher = "Microsoft.Compute"
type = "JsonADDomainExtension"
type_handler_version = "1.3"
depends_on = ["azurerm_virtual_machine.vm"]
count = 2

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
