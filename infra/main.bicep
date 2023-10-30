targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param appServicePlanName string = ''
param resourceGroupName string = ''
param webServiceName string = ''
param existingVnet string = 'existingVnet'
// serviceName is used as value for the tag (azd-service-name) azd uses to identify deployment host
param serviceName string = 'web'
@description('Id of the user or app to assign application roles')

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

resource rgVnet 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: existingVnet
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './modules/hosting/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    appServicePlanName: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
    }
  }
}

// The application frontend
module web './modules/hosting/appservice.bicep' = {
  name: serviceName
  scope: rg
  params: {
    webServiceName: !empty(webServiceName) ? webServiceName : '${abbrs.webSitesAppService}web-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    appServicePlanId: appServicePlan.outputs.appServicePlanId
  }
}

module subnet './modules/network/subnet.bicep' = {
  name: serviceName
  scope: rgVnet
  params: {
    vnet: 'vnet'
    name: 'subnet'
  }
}

// App outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output REACT_APP_WEB_BASE_URL string = web.outputs.webServiceUrl
