

resource "azurerm_template_deployment" "adds" {
  name                = "addsdeployment"
  resource_group_name = "${var.resource_group_name}"

  template_body = <<DEPLOY
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "templateRootUri": {
      "type": "string",
      "defaultValue": "https://raw.githubusercontent.com/mspnp/template-building-blocks/v1.0.0/",
      "metadata": {
        "description": "Root path for templates"
      }
    },
    "parameterRootUri": {
      "type": "string",
      "defaultValue": "https://raw.githubusercontent.com/CMaloun/reference-architectures/master/virtual-machines/n-tier-windows/parameters/",
      "metadata": {
        "decription": "Root path for parameters"
      }
    }
  },
  "variables": {
    "templates": {
      "deployment": {
        "loadBalancer": "[concat(parameters('templateRootUri'), 'templates/buildingBlocks/loadBalancer-backend-n-vm/azuredeploy.json')]",
        "virtualNetwork": "[concat(parameters('templateRootUri'), 'templates/buildingBlocks/vnet-n-subnet/azuredeploy.json')]",
        "virtualMachine": "[concat(parameters('templateRootUri'), 'templates/buildingBlocks/multi-vm-n-nic-m-storage/azuredeploy.json')]",
        "extensions": "[concat(parameters('templateRootUri'), 'templates/buildingBlocks/virtualMachine-extensions/azuredeploy.json')]"
      },
      "parameter": {
        "ad": "[concat(parameters('parameterRootUri'), 'adds/ad.parameters.json')]",
        "adPrimaryExtension": "[concat(parameters('parameterRootUri'), 'adds/create-adds-forest-extension.parameters.json')]",
        "adSecondaryExtension": "[concat(parameters('parameterRootUri'), 'adds/add-adds-domain-controller.parameters.json')]",
        "vnetDnsUpdate": "[concat(parameters('parameterRootUri'), 'adds/virtualNetwork-adds-dns.parameters.json')]",
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2015-01-01",
      "name": "ra-ntier-sql-ad-deployment",
      "dependsOn": [
        "ts-vnet-deployment"
      ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('templates').deployment.virtualMachine]"
        },
        "parametersLink": {
          "uri": "[variables('templates').parameter.ad]",
          "contentVersion": "1.0.0.0"
        }
      }
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2015-01-01",
      "name": "ra-ntier-sql-update-dns",
      "dependsOn": [
        "ra-ntier-sql-ad-deployment"
      ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('templates').deployment.virtualNetwork]"
        },
        "parametersLink": {
          "uri": "[variables('templates').parameter.vnetDnsUpdate]",
          "contentVersion": "1.0.0.0"
        }
      }
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2015-01-01",
      "name": "ra-ntier-sql-primary-ad-ext",
      "dependsOn": [
        "ra-ntier-sql-update-dns"
      ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('templates').deployment.extensions]"
        },
        "parametersLink": {
          "uri": "[variables('templates').parameter.adPrimaryExtension]",
          "contentVersion": "1.0.0.0"
        }
      }
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2015-01-01",
      "name": "ra-ntier-sql-secondary-ad-ext",
      "dependsOn": [
        "ra-ntier-sql-primary-ad-ext"
      ],
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[variables('templates').deployment.extensions]"
        },
        "parametersLink": {
          "uri": "[variables('templates').parameter.adSecondaryExtension]",
          "contentVersion": "1.0.0.0"
        }
      }
    }
  ]
}
DEPLOY

  deployment_mode = "Incremental"
}
