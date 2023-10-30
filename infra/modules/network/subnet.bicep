param vnet string
param name string

resource existingVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnet
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: name
  parent: existingVnet
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}
