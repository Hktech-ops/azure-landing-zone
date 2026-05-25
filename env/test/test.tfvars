# terraform.tfvars for env: test

## In a real-world scenario, I would refrain from adding ids in tf.vars --> when pushing to git hub!


/* 
tenant_root_group_id --> CLI = az accout management-goup list
subscription_id --> CLI = az account show --query id --> /subscriptions/"**<id>** 
tenant id --> CLI = az account show
*/

tenant_root_group_id = "/providers/Microsoft.Management/managementGroups/2b4bb9a8-b0c8-415d-a87c-919dd639e8f5"
subscription_id      = "/subscriptions/c8f4dd9e-fab4-4fc1-90c4-9f7f9c1a094f"

tenant_id = "2b4bb9a8-b0c8-415d-a87c-919dd639e8f5"
