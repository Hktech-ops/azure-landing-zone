// terraform.tfvars for env: prod

## In a real-world scenario, I would refrain from adding ids in tf.vars --> when pushing to git hub!


/* 
tenant_root_group_id --> CLI = az accout management-goup list
subscription_id --> CLI = az account show --query id --> /subscriptions/"**<id>** 
tenant id --> CLI = az account show
*/

tenant_root_group_id = "/providers/Microsoft.Management/managementGroups/77be291f-9570-4756-acb1-959637138e2f"
subscription_id = "/subscriptions/c8f4dd9e-fab4-4fc1-90c4-9f7f9c1a094f"

tenant_id = "77be291f-9570-4756-acb1-959637138e2f"
