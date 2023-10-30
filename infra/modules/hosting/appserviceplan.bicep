param location string = resourceGroup().location
param appServicePlanName string
param tags object
param sku object

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: sku
  tags: tags
}

output appServicePlanId string = appServicePlan.id
