param location string = resourceGroup().location
param appServicePlanId string
param webServiceName string
param tags {}


resource webService 'Microsoft.Web/sites@2021-02-01' = {
  name: webServiceName
  location: location
  properties: {
    serverFarmId: appServicePlanId
  }
  tags: tags
}

output webServiceUrl string = webService.properties.defaultHostName
