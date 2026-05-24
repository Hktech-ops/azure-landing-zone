# main file for github service principal

/* 
Goal is to create 
 - App registration (Entra / Azure AD App)
 - Federated Credential for GitHub
 - Service principal
 - RBAC roles to Service Principal
*/
# RBAC roles for service principal
/* 
Why these 3 RBAC roles to SP?
 - Each role covers specific capability that Terraform needs
 - Contributor
  - Covers 95% of terraform operations such as create, update, delete, deploy resources etc...
 - Resource Policy Contributor
  - Useful for policy assignments - policies module
 - User Access Administrator
  - assign/remove roles to identities
*/

/* 
As the last bit in the Authorization process, I have added 
 - AZURE_CLIENT_ID
 - AZURE_SUBSCRIPTION_ID
 - AZURE_TENANT_ID
in my Github repo > secrets and variables > actions 

This completes both Azure part + GitHub part for 2 way comminication b/w Azure and Service Principal (GitHub)
*/

# --------------------------------------------

# Create an App registration
resource "azuread_application" "github" {
  display_name = var.azuread_app_github
}

# Service Principal for GitHub app
resource "azuread_service_principal" "github_sp" {
  client_id = azuread_application.github.client_id // client id is generated as soon as an app is registered
}

# Federated Credential for github app
resource "azuread_application_federated_identity_credential" "github-oidc" {
  application_id = azuread_application.github.id // id of the entra app provisioned earlier
  display_name   = "${var.azuread_app_github}-oidc"
  subject        = "repo:Hktech-ops/azure-landing-zone:ref:refs/heads/env-test"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
}

# -------------------------------------------------
# RBAC roles at scope 'Subscription'
# Contributor RBAC role to sp
resource "azurerm_role_assignment" "contributor_to_github_sp" {
  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = azuread_service_principal.github_sp.object_id  //object id of github SP
  role_definition_name = "Contributor"
}
# Resource Policy Contributor RBAC role to sp
resource "azurerm_role_assignment" "resource_policy_contributor_to_github_sp" {
  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = azuread_service_principal.github_sp.object_id  //object id of github SP
  role_definition_name = "Resource Policy Contributor"
}
# User Access Administrator RBAC role to sp
resource "azurerm_role_assignment" "user_acces_admin_to_github_sp" {
  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = azuread_service_principal.github_sp.object_id  //object id of github SP
  role_definition_name = "User Access Administrator"
}
