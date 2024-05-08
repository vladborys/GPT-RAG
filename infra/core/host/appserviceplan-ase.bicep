param name string
param location string = resourceGroup().location
param tags object = {}

param kind string = ''
param reserved bool = true
param sku object

param aseName string

resource appServicePlanAse 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
    hostingEnvironmentProfile: {
      id: resourceId('Microsoft.Web/hostingEnvironments', aseName)
    }
  }
}

output id string = appServicePlanAse.id
output name string =appServicePlanAse.name
