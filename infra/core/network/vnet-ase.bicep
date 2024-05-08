param name string
param location string = resourceGroup().location
param resourceGroupName string = resourceGroup().name
param tags object = {}

param aseName string = ''

@allowed(['ASEV3'])
param kind string = 'ASEV3'

var addressPrefix = '10.0.0.0/16'

//var commonSubnets = [
var subnets = [
  {
    name: 'ai-subnet'
    properties: {
      addressPrefix:'10.0.1.0/24'
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'      
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefix:'10.0.2.0/24'
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'      
    }
  }
  {
    name: 'app-int-subnet'
    properties: {
      addressPrefix:'10.0.3.0/24'
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'Microsoft.Web.hostingEnvironments'
          properties: {
            serviceName: 'Microsoft.Web/hostingEnvironments'
          }
        }
      ]   
    }
  } 
]

resource vnetAse 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: subnets
  }
}

var appIntSubName = vnetAse.properties.subnets[2].name

resource ase 'Microsoft.Web/hostingEnvironments@2020-06-01' = {
  name: aseName
  location: location
  kind: kind
  tags: tags
  dependsOn: [
    vnetAse
  ]
  properties: {
    location: location
    name: aseName
    workerPools: []
    virtualNetwork: {
      id: resourceId(resourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetAse.name, appIntSubName)
    }
  }
}

output subnets array = [for (name, i) in subnets :{
  subnets : vnetAse.properties.subnets[i]
}]

output subnetids array = [for (name, i) in subnets :{
  subnets : vnetAse.properties.subnets[i].id
}]

output id string = vnetAse.id
output name string = vnetAse.name

output aiSubId string = vnetAse.properties.subnets[0].id
output bastionSubId string = vnetAse.properties.subnets[1].id
output appIntSubId string = vnetAse.properties.subnets[2].id

output aseId string = ase.id
output aseName string = ase.name
