# Verify Terraform is using the expected Azure credentials
data "azurerm_client_config" "current" {}

output "tf_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}
output "tf_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "tf_client_id" {
  value = data.azurerm_client_config.current.client_id
}
output "tf_object_id" {
  value = data.azurerm_client_config.current.object_id
}
