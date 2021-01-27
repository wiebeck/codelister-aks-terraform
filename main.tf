// resource group for k8s cluster
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location
}

// the cluster itself
resource "azurerm_kubernetes_cluster" "example" {
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  // we can either use a "service_principal" or let Azure create a managed identity
  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }
}

// -------------------------------------------------------------------
// Give access to container registry

// access to existing container registry
data "azurerm_container_registry" "acr" {
  name                = "acrriegedev001"
  resource_group_name = "rg-container-registry-dev-001"
}

// create AcrPull role assignment on container registry for Kubelet managed identity
resource "azurerm_role_assignment" "ra_example" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
}
