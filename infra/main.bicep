targetScope = 'subscription'

// parametes Note:
// Use main.parameters.json to set the parameters values.
// From main.parametes.json, you can map the parameters to environment variables using the "${ENV_VAR_NAME}" notation,
// The ENV_VAR_NAME's value will be automatically pulled if you use azd to deploy the template.

// environmentName, location and principalId are mapped to env_vars and automatically resolved if you are using azd.

@minLength(1)
@maxLength(64)
@description('Environment name used as a tag for all resources. This is directly mapped to the azd-environment.')
param environmentName string

@minLength(1)
@description('Primary location for all resources.')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Name of the resource group where all resources will be created. When empty, the name is autogenerated.')
param resourceGroupName string = ''

// resourceToken is a unique hash based on the subcription id, environment name and location. The hash is used to generate unique names for resources.
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
// default required tags for azd deployment
var azdTags = { 'azd-env-name': environmentName }

@description('Key-value pairs of tags to assign to all resources. The default azd tags are automatically added.')
param deploymentTags object

// Merge azdTags and deploymentTags
var tags = union(azdTags, deploymentTags)

//network
@description('Network isolation? If yes it will create the private endpoints.')
@allowed([true, false])
param networkIsolation bool = false

//app service environment
@description('ASE? If yes it will create isolated app with network.')
@allowed([true, false])
param appServiceEnvironment bool = false

// azd can automatically generate a password and put in keyvault. See the mapping in main.parameters.json for vmUserInitialPassword.
// If the references KeyVault exists, azd will pull the value from it, otherwise it will generate a random password and store in the KeyVault after it is created.
// The template makes sure to create the KeyVault and set the output to match what is used in main.parameters.json.
@minLength(6)
@maxLength(72)
@description('Test vm gpt user password. Use strong password with letters and numbers. Needed only when choosing network isolation and create bastion option. If not creating with network isolation you can write anything. Password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following: 1-Contains an uppercase character, 2-Contains a lowercase character, 3-Contains a numeric digit, 4-Contains a special character, 5- Control characters are not allowed.')
@secure()
param vmUserInitialPassword string

// defaults are set on main.parameters.json for the next parameters.
@description('Test vm gpt user name. Needed only when choosing network isolation and create bastion option. If not you can leave it blank.')
param vmUserName string

//language settings
@description('Language used when orchestrator needs send error messages to the UX.')
@allowed(['pt', 'es', 'en'])
param orchestratorMessagesLanguage string
@description('Analyzer language used by Azure search to analyze indexes text content.')
@allowed(['standard', 'pt-Br.microsoft', 'es.microsoft', 'ar.microsoft', 'bn.microsoft', 'bg.microsoft', 'ca.microsoft', 'zh-Hans.microsoft', 'zh-Hant.microsoft', 'hr.microsoft', 'cs.microsoft', 'da.microsoft', 'nl.microsoft', 'en.microsoft', 'et.microsoft', 'fi.microsoft', 'fr.microsoft', 'de.microsoft', 'el.microsoft', 'gu.microsoft', 'he.microsoft', 'hi.microsoft', 'hu.microsoft', 'is.microsoft', 'id.microsoft', 'it.microsoft', 'ja.microsoft', 'kn.microsoft', 'ko.microsoft', 'lv.microsoft', 'lt.microsoft', 'ml.microsoft', 'ms.microsoft', 'mr.microsoft', 'nb.microsoft', 'pl.microsoft', 'pt-Pt.microsoft', 'pa.microsoft', 'ro.microsoft', 'ru.microsoft', 'sr-cyrillic.microsoft', 'sr-latin.microsoft', 'sk.microsoft', 'sl.microsoft', 'sv.microsoft', 'ta.microsoft', 'te.microsoft', 'th.microsoft', 'tr.microsoft', 'uk.microsoft', 'ur.microsoft', 'vi.microsoft' ])
param searchAnalyzerName string
@description('Language used for speech recognition in the frontend.')
@allowed(['pt-BR', 'af-ZA', 'am-ET', 'ar-AE', 'ar-BH', 'ar-DZ', 'ar-EG', 'ar-IL', 'ar-IQ', 'ar-JO', 'ar-KW', 'ar-LB', 'ar-LY', 'ar-MA', 'ar-OM', 'ar-PS', 'ar-QA', 'ar-SA', 'ar-SY', 'ar-TN', 'ar-YE', 'az-AZ', 'bg-BG', 'bn-IN', 'bs-BA', 'ca-ES', 'cs-CZ', 'cy-GB', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'el-GR', 'en-AU', 'en-CA', 'en-GB', 'en-GH', 'en-HK', 'en-IE', 'en-IN', 'en-KE', 'en-NG', 'en-NZ', 'en-PH', 'en-SG', 'en-TZ', 'en-US', 'en-ZA', 'es-AR', 'es-BO', 'es-CL', 'es-CO', 'es-CR', 'es-CU', 'es-DO', 'es-EC', 'es-ES', 'es-GQ', 'es-GT', 'es-HN', 'es-MX', 'es-NI', 'es-PA', 'es-PE', 'es-PR', 'es-PY', 'es-SV', 'es-US', 'es-UY', 'es-VE', 'et-EE', 'eu-ES', 'fa-IR', 'fi-FI', 'fil-PH', 'fr-BE', 'fr-CA', 'fr-CH', 'fr-FR', 'ga-IE', 'gl-ES', 'gu-IN', 'he-IL', 'hi-IN', 'hr-HR', 'hu-HU', 'hy-AM', 'id-ID', 'is-IS', 'it-CH', 'it-IT', 'ja-JP', 'jv-ID', 'ka-GE', 'kk-KZ', 'km-KH', 'kn-IN', 'ko-KR', 'lo-LA', 'lt-LT', 'lv-LV', 'mk-MK', 'ml-IN', 'mn-MN', 'mr-IN', 'ms-MY', 'mt-MT', 'my-MM', 'nb-NO', 'ne-NP', 'nl-BE', 'nl-NL', 'pl-PL', 'ps-AF', 'pt-PT', 'ro-RO', 'ru-RU', 'si-LK', 'sk-SK', 'sl-SI', 'so-SO', 'sq-AL', 'sr-RS', 'sv-SE', 'sw-KE', 'sw-TZ', 'ta-IN', 'te-IN', 'th-TH', 'tr-TR', 'uk-UA', 'uz-UZ', 'vi-VN', 'wuu-CN', 'yue-CN', 'zh-CN', 'zh-CN-shandong', 'zh-CN-sichuan', 'zh-HK', 'zh-TW', 'zu-ZA' ])
param speechRecognitionLanguage string
@description('Language used for speech synthesis in the frontend.')
@allowed(['pt-BR', 'es-ES', 'es-MX','ar-EG', 'ar-SA', 'ca-ES', 'cs-CZ', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'en-AU', 'en-CA', 'en-GB', 'en-HK', 'en-IE', 'en-IN', 'en-US', 'es-ES', 'es-MX', 'fi-FI', 'fr-BE', 'fr-CA', 'fr-CH', 'fr-FR', 'hi-IN', 'hu-HU', 'id-ID', 'it-IT', 'ja-JP', 'ko-KR', 'nb-NO', 'nl-BE', 'nl-NL', 'pl-PL', 'pt-PT', 'ru-RU', 'sv-SE', 'th-TH', 'tr-TR', 'zh-CN', 'zh-HK', 'zh-TW'])
param speechSynthesisLanguage string
@description('Voice used for speech synthesis in the frontend.')
@allowed([ 'pt-BR-FranciscaNeural', 'es-MX-BeatrizNeural', 'en-US-RyanMultilingualNeural', 'de-DE-AmalaNeural', 'fr-FR-DeniseNeural'])
param speechSynthesisVoiceName string

//python runtime version
@description('Python runtime version in function apps')
@allowed(['3.10', '3.11'])
param funcAppRuntimeVersion string = '3.11'
@description('Python runtime version in app service')
@allowed(['3.10', '3.11', '3.12'])
param appServiceRuntimeVersion string = '3.12'

// openai
@description('GPT model used to answer user questions. Don\'t forget to check region availability.')
@allowed([ 'gpt-35-turbo','gpt-35-turbo-16k', 'gpt-4', 'gpt-4-32k' ])
param chatGptModelName string
@description('GPT model version.')
@allowed([ '0613', '1106', '1106-Preview', '0125-preview'])
param chatGptModelVersion string
@description('GPT model deployment name.')
param chatGptDeploymentName string = 'chat'
@description('GPT model tokens per Minute Rate Limit (thousands). Default quota per model and region: gpt-4: 20; gpt-4-32: 60; All others: 240.')
@minValue(1)
@maxValue(20)
param chatGptDeploymentCapacity int = 20
@description('Embeddings model used to generate vector embeddings. Don\'t forget to check region availability.')
@allowed([ 'text-embedding-ada-002' ])
param embeddingsModelName string = 'text-embedding-ada-002'
@description('Embeddings model version.')
@allowed([ '2' ])
param embeddingsModelVersion string = '2'
@description('Embeddings model deployment name.')
param embeddingsDeploymentName string = 'text-embedding-ada-002'
@description('Embeddings model tokens per Minute Rate Limit (thousands). Default quota per model and region: 240')
@minValue(1)
@maxValue(240)
param embeddingsDeploymentCapacity int = 20
@description('Azure OpenAI API version.')
@allowed([ '2023-05-15', '2024-02-15-preview'])
param openaiApiVersion string
@description('Enables LLM monitoring to generate conversation metrics.')
@allowed([true, false])
param chatGptLlmMonitoring bool = true

//docint
var docintApiVersion = (location == 'eastus' || location == 'westus2' || location == 'westeurope') ? '2023-10-31-preview' : '2023-07-31'

// search
@description('Orchestrator supports the following retrieval approaches: term, vector, hybrid(term + vector search), or use oyd feature of Azure OpenAI.')
@allowed(['term', 'vector', 'hybrid', 'oyd' ])
param retrievalApproach string = 'hybrid'
@description('Use semantic reranking on top of search results?.')
@allowed([true, false])
param useSemanticReranking bool = true
var searchServiceSkuName = networkIsolation?'standard2':'standard'
@description('Search index name.')
var searchIndex = 'ragindex'
@allowed([ '2023-11-01', '2023-10-01-Preview' ])
// Requires version 2023-10-01-Preview or higher for indexProjections and MIS authResourceId.
param searchApiVersion string = '2023-10-01-Preview'

@description('Frequency of search reindexing. PT5M (5 min), PT1H (1 hour), P1D (1 day).')
@allowed(['PT5M', 'PT1H', 'P1D'])
param searchIndexInterval string = 'PT1H'
@description('Use Search Service Managed Identity to Connect to data ingestion function?')
@allowed([true, false])
param azureSearchUseMIS bool = false

// chunking
@description('The number of tokens in each chunk.')
param chunkNumTokens string = '2048'
@description('The minimum chunk size below which chunks will be filtered.')
param chunkMinSize string = '100'
@description('The number of tokens to overlap between chunks.')
param chunkTokenOverlap string = '200'

// storage
@description('Name of the container where source documents will be stored.')
param storageContainerName string = 'documents'

// hosting
@description('App service plan sku')
@allowed(['P0v3', 'I2'])
param appServicePlanSku string = true?'I2':'P0v3'
//param appServicePlanSku string = appServiceEnvironment?'I1':'P0v3'


// Service names
// The name for each service can be set from environment variables which are mapped in main.parameters.json.
// Then no maping to specific name is defined, a unique name is generated for each service based on the resourceToken created above.
@description('Cosmos DB Account Name. Use your own name convention or leave as it is to generate a random name.')
param azureDbAccountName string = ''
var dbAccountName = !empty(azureDbAccountName) ? azureDbAccountName : 'dbgpt0-${resourceToken}'
@description('Cosmos DB Database Name. Use your own name convention or leave as it is to generate a random name.')
param azureDbDatabaseName string = ''
var dbDatabaseName = !empty(azureDbDatabaseName) ? azureDbDatabaseName : 'db0-${resourceToken}'
@description('Key Vault Name. Use your own name convention or leave as it is to generate a random name.')
param azureKeyVaultName string = ''
var keyVaultName = !empty(azureKeyVaultName) ? azureKeyVaultName : 'kv0-${resourceToken}'
@description('Storage Account Name. Use your own name convention or leave as it is to generate a random name.')
param azureStorageAccountName string = ''
var storageAccountName = !empty(azureStorageAccountName) ? azureStorageAccountName : 'strag0${resourceToken}'
@description('Cognitive services multi-service name. Use your own name convention or leave as it is to generate a random name.')
param azureCognitiveServiceName string = ''
var cognitiveServiceName = !empty(azureCognitiveServiceName) ? azureCognitiveServiceName : 'cs0-${resourceToken}'
@description('App Service Plan Name. Use your own name convention or leave as it is to generate a random name.')
param azureAppServicePlanName string = ''
var appServicePlanName = !empty(azureAppServicePlanName) ? azureAppServicePlanName : 'appplan0-${resourceToken}'
@description('App Insights Name. Use your own name convention or leave as it is to generate a random name.')
param azureAppInsightsName string = ''
var appInsightsName = !empty(azureAppInsightsName) ? azureAppInsightsName : 'appins0-${resourceToken}'
@description('Front-end App Service Name. Use your own name convention or leave as it is to generate a random name.')
param azureAppServiceName string = ''
var appServiceName = !empty(azureAppServiceName) ? azureAppServiceName : 'webgpt0-${resourceToken}'
@description('Orchestrator Function Name. Use your own name convention or leave as it is to generate a random name.')
param azureOrchestratorFunctionAppName string = ''
var orchestratorFunctionAppName = !empty(azureOrchestratorFunctionAppName) ? azureOrchestratorFunctionAppName : 'fnorch0-${resourceToken}'
@description('Data Ingestion Function Name. Use your own name convention or leave as it is to generate a random name.')
param azureDataIngestionFunctionAppName string = ''
var dataIngestionFunctionAppName = !empty(azureDataIngestionFunctionAppName) ? azureDataIngestionFunctionAppName : 'fninges0-${resourceToken}'
@description('Search Service Name. Use your own name convention or leave as it is to generate a random name.')
param azureSearchServiceName string = ''
var searchServiceName = !empty(azureSearchServiceName) ? azureSearchServiceName : 'search0-${resourceToken}'
@description('OpenAI Service Name. Use your own name convention or leave as it is to generate a random name.')
param azureOpenAiServiceName string = ''
var openAiServiceName = !empty(azureOpenAiServiceName) ? azureOpenAiServiceName : 'oai0-${resourceToken}'
@description('Virtual network name if using network isolation. Use your own name convention or leave as it is to generate a random name.')
param azureVnetName string = ''
var vnetName = !empty(azureVnetName) ? azureVnetName : 'aivnet0-${resourceToken}'
@description('App Service Environment Name. Use your own name convention or leave as it is to generate a random name.')
param azureAppServiceEnvironmentName string = ''
var appServiceEnvironmentName = !empty(azureAppServiceEnvironmentName) ? azureAppServiceEnvironmentName : 'ase0-${resourceToken}'


var orchestratorEndpoint = 'https://${orchestratorFunctionAppName}.azurewebsites.net/api/orc'
var orchestratorUri = 'https://${orchestratorFunctionAppName}.azurewebsites.net'

// main

// resource group
var azureResourceGroupName = !empty(resourceGroupName) ? resourceGroupName : 'rg-${environmentName}'
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: azureResourceGroupName
  location: location
  tags: tags
}

// Networking and ASE

/*module vnetClassic './core/network/vnet.bicep' = if(!true) {
  name: vnetName
  scope: resourceGroup
  params: {
    name: vnetName    
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    appServicePlanName: appServicePlan.outputs.name 
  }
}*/

module vnetAse './core/network/vnet-ase.bicep' = if(true) {
  name: vnetName
  scope: resourceGroup
  params: {
    name: vnetName    
    location: location
    tags: tags
    aseName: appServiceEnvironmentName
  }
}

//initialize vnet var with current networking profile 
var vnet = vnetAse //vnetClassic

// DNSs Zones

module blobDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'blob-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.blob.core.windows.net' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

module documentsDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'documents-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.documents.azure.com' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

module vaultDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'vault-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.vaultcore.azure.net' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

module websitesDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'websites-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.azurewebsites.net' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

module cognitiveservicesDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'cognitiveservices-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.cognitiveservices.azure.com' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

module openaiDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'openai-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.openai.azure.com' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

module searchDnsZone './core/network/private-dns-zones.bicep' = if (networkIsolation) {
  name: 'searchs-dnzones'
  scope: resourceGroup
  params: {
    dnsZoneName: 'privatelink.search.windows.net' 
    tags: tags
    virtualNetworkName: vnet.outputs.name
  }
}

// VMs
var ztVmName = 'testvm${resourceToken}'
var bastionKvName = 'bastionkv${resourceToken}'
var vmKeyVaultSecName = 'vmUserInitialPassword'

module testvm './core/vm/dsvm.bicep' = if (networkIsolation) {
  name: 'testvm'
  scope: resourceGroup
  params: {
    location: location
    name: ztVmName
    tags: tags
    aiSubId: vnet.outputs.aiSubId
    bastionSubId: vnet.outputs.bastionSubId
    vmUserPassword: vmUserInitialPassword
    vmUserName: vmUserName
    keyVaultName: bastionKvName
    // this is the named of the secret to store the vm password in keyvault. It matches what is used on main.parameters.json
    vmUserPasswordKey: vmKeyVaultSecName
    principalId: principalId
  }
}

// storage

var containerName = storageContainerName

module storage './core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: storageAccountName
    location: location
    tags: tags
    publicNetworkAccess: networkIsolation?'Disabled':'Enabled'
    allowBlobPublicAccess: false // Disable anonymous access
    containers: [{name:containerName, publicAccess: 'None'}]
    keyVaultName: keyVault.outputs.name
    secretName: 'storageConnectionString'
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }  
}

module storagepe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'storagepe'
  scope: resourceGroup
  params: {
    location: location
    name:'stragpe0${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: storage.outputs.id
    groupIds: ['blob']
    dnsZoneId: networkIsolation?blobDnsZone.outputs.id:''
  }
}


// Database
module cosmosAccount './core/db/cosmos.bicep' = {
  name: 'cosmosaccount'
  scope: resourceGroup
  params: {
    accountName: dbAccountName
    publicNetworkAccess: networkIsolation?'Disabled':'Enabled'
    location: location
    containerName: 'conversations'
    databaseName: dbDatabaseName
    tags: tags
    secretName: 'azureDBkey'
    keyVaultName: keyVault.outputs.name    
  }
}

module cosmospe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'cosmospe'
  scope: resourceGroup
  params: {
    location: location
    name: 'dbgptpe0${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: cosmosAccount.outputs.id
    groupIds: ['Sql']
    dnsZoneId: networkIsolation?documentsDnsZone.outputs.id:''
  }
}

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  scope: resourceGroup
  params: {
    name: keyVaultName
    location: location
    publicNetworkAccess: networkIsolation?'Disabled':'Enabled'
    tags: tags
    principalId: principalId
    // this is the named of the secret to store the vm password in keyvault. It matches what is used on main.parameters.json
    vmUserPasswordKey: vmKeyVaultSecName
    vmUserPassword: vmUserInitialPassword
  }
}

module keyvaultpe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'keyvaultpe'
  scope: resourceGroup
  params: {
    location: location
    name:'kvpe0${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: keyVault.outputs.id
    groupIds: ['Vault']
    dnsZoneId: networkIsolation?vaultDnsZone.outputs.id:''
  }
}

// Create an App Service Plan
/*module appServicePlanClassic './core/host/appserviceplan.bicep' = if(!true) {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: appServicePlanSku
      capacity: 1
    }
    kind: 'linux'
  }
}*/

module appServicePlanAse './core/host/appserviceplan-ase.bicep' = if(true) {
  name: 'appserviceplanAse'
  scope: resourceGroup
  dependsOn: [vnetAse]
  params: {
    name: appServicePlanName
    aseName: appServiceEnvironmentName
    location: location
    tags: tags
    sku: {
      name: appServicePlanSku
      tier: 'Isolated'
      size: appServicePlanSku
      family: 'I'
      capacity: 1
    }
    kind: 'linux'
  }
}

//initialize appServicePlan var with current server farms profile 
var appServicePlan = appServicePlanAse //appServicePlanClassic

// app insights
module appInsights './core/host/appinsights.bicep' = {
  name: 'appinsights'
  scope: resourceGroup
  params: {
    applicationInsightsName: appInsightsName
    appInsightsLocation: location
  }
}

// orchestrator
module orchestrator './core/host/functions.bicep' = {
  name: 'orchestrator'
  scope: resourceGroup
  params: {
    aseName: true ? appServiceEnvironmentName : ''
    //subnetId: vnet.outputs.appIntSubId
    //vnetName: vnet.outputs.name
    //networkIsolation: networkIsolation
    keyVaultName: keyVault.outputs.name
    storageAccountName: '${storageAccountName}orc'
    appServicePlanId: appServicePlan.outputs.id
    appName: orchestratorFunctionAppName
    location: location
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    tags: union(tags, { 'azd-service-name': 'orchestrator' })
    alwaysOn: true
    functionAppScaleLimit: 2
    numberOfWorkers: 2
    runtimeName: 'python'
    runtimeVersion: funcAppRuntimeVersion
    minimumElasticInstanceCount: 1
    allowedOrigins: [ '*' ]    
    appSettings:[
      {
        name: 'AZURE_DB_ID'
        value: dbAccountName
      }
      {
        name: 'AZURE_DB_NAME'
        value: dbDatabaseName
      }      
      {
        name: 'AZURE_KEY_VAULT_NAME'
        value: keyVault.outputs.name
      }      
      {
        name: 'AZURE_SEARCH_SERVICE'
        value: searchServiceName
      }
      {
        name: 'AZURE_SEARCH_INDEX'
        value: searchIndex
      }
      {
        name: 'AZURE_SEARCH_APPROACH'
        value: retrievalApproach
      }
      {
        name: 'AZURE_SEARCH_USE_SEMANTIC'
        value: useSemanticReranking
      }      
      {
        name: 'AZURE_SEARCH_API_VERSION'
        value: searchApiVersion
      }
      {
        name: 'AZURE_OPENAI_RESOURCE'
        value: openAiServiceName
      }
      {
        name: 'AZURE_OPENAI_CHATGPT_MODEL'
        value: chatGptModelName
      }      
      {
        name: 'AZURE_OPENAI_CHATGPT_DEPLOYMENT'
        value: chatGptDeploymentName
      }
      {
        name: 'AZURE_OPENAI_CHATGPT_LLM_MONITORING'
        value: chatGptLlmMonitoring
      }
      {
        name: 'AZURE_OPENAI_API_VERSION'
        value: openaiApiVersion
      }      
      {
        name: 'AZURE_OPENAI_LOAD_BALANCING'
        value: false
      }               
      {
        name: 'AZURE_OPENAI_EMBEDDING_MODEL'
        value: embeddingsModelName
      }      
      {
        name: 'AZURE_OPENAI_EMBEDDING_DEPLOYMENT'
        value: embeddingsDeploymentName
      }
      {
        name: 'AZURE_OPENAI_STREAM'
        value: false
      }
      {
        name: 'ORCHESTRATOR_MESSAGES_LANGUAGE'
        value: orchestratorMessagesLanguage
      }
      {
        name: 'ENABLE_ORYX_BUILD'
        value: 'true'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'true'
      }
      {
        name: 'LOGLEVEL'
        value: 'INFO'
      }                         
    ]  
  }
}

module orchestratorPe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'orchestratorPe'
  scope: resourceGroup
  params: {
    location: location
    name: 'orchestratorPe${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: orchestrator.outputs.id
    groupIds: ['sites']
    dnsZoneId: networkIsolation?websitesDnsZone.outputs.id:''
  }
}

// Give the orchestrator access to KeyVault
module orchestratorKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'orchestrator-keyvault-access'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: orchestrator.outputs.identityPrincipalId
  }
} 

// Give the orchestrator access to Cosmos
module orchestratorCosmosAccess './core/security/cosmos-access.bicep' = {
  name: 'orchestrator-cosmos-access'
  scope: resourceGroup
  params: {
    principalId: orchestrator.outputs.identityPrincipalId
    accountName: cosmosAccount.outputs.name
  }
} 

// Give the orchestrator access to AOAI
module orchestratorOaiAccess './core/security/openai-access.bicep' = {
  name: 'orchestrator-openai-access'
  scope: resourceGroup
  params: {
    principalId: orchestrator.outputs.identityPrincipalId
    openaiAccountName: openAi.outputs.name
  }
} 


module frontEnd  'core/host/appservice.bicep'  = {
  name: 'frontend'
  scope: resourceGroup
  params: {
    name: appServiceName
    applicationInsightsName: appInsightsName
    aseName: true ? appServiceEnvironmentName : ''
    //subnetId: vnet.outputs.appIntSubId
    //vnetName: vnet.outputs.name
    appCommandLine: 'python ./app.py'
    location: location
    tags: union(tags, { 'azd-service-name': 'frontend' })
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: appServiceRuntimeVersion
    scmDoBuildDuringDeployment: true
    basicPublishingCredentials: networkIsolation?true:false
    appSettings: [
      {
        name: 'SPEECH_SYNTHESIS_VOICE_NAME'
        value: speechSynthesisVoiceName
      }
      {
        name: 'SPEECH_SYNTHESIS_LANGUAGE'
        value: speechSynthesisLanguage
      }      
      {
        name: 'SPEECH_RECOGNITION_LANGUAGE'
        value: speechRecognitionLanguage
      }
      {
        name: 'SPEECH_REGION'
        value: location
      }
      {
        name: 'ORCHESTRATOR_URI'
        value: orchestratorUri
      }
      {
        name: 'ORCHESTRATOR_ENDPOINT'
        value: orchestratorEndpoint
      }
      {
        name: 'AZURE_KEY_VAULT_ENDPOINT'
        value: keyVault.outputs.endpoint
      }
      {
        name: 'AZURE_KEY_VAULT_NAME'
        value: keyVault.outputs.name
      }
      {
        name: 'STORAGE_ACCOUNT'
        value: storageAccountName
      } 
      {
        name: 'LOGLEVEL'
        value: 'INFO'
      } 
    ]
  }
}

module frontendPe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'frontendPe'
  scope: resourceGroup
  params: {
    location: location
    name: 'frontendPe${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: frontEnd.outputs.id
    groupIds: ['sites']
    dnsZoneId: networkIsolation?websitesDnsZone.outputs.id:''
  }
}

// Give the App Service access to KeyVault
module appsericeKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'appservice-keyvault-access'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: frontEnd.outputs.identityPrincipalId
  }
}

// Give the App Service access to Storage Account
module appserviceStorageAccountAccess './core/security/blobstorage-access.bicep' = {
  name: 'appservice-blobstorage-access'
  scope: resourceGroup
  params: {
    storageAccountName: storage.outputs.name
    principalId: frontEnd.outputs.identityPrincipalId
  }
}

// Give the App Service access to Orchestrator Function
module appserviceOrchestratorAccess './core/host/functions-access.bicep' = {
  name: 'appservice-function-access'
  scope: resourceGroup
  params: {
    functionAppName: orchestrator.outputs.name
    principalId: frontEnd.outputs.identityPrincipalId
  }
}

module dataIngestion './core/host/functions.bicep' = {
  name: 'dataIngestion'
  scope: resourceGroup
  params: {
    aseName: true ? appServiceEnvironmentName : ''
    keyVaultName: keyVault.outputs.name
    appServicePlanId: appServicePlan.outputs.id
    //subnetId: vnet.outputs.appIntSubId
    //vnetName: vnet.outputs.name
    //networkIsolation: networkIsolation
    storageAccountName: '${storageAccountName}ing'
    appName: dataIngestionFunctionAppName
    location: location
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    tags: union(tags, { 'azd-service-name': 'dataIngest' })
    alwaysOn: true
    allowedOrigins: [ '*' ]
    functionAppScaleLimit: 1
    minimumElasticInstanceCount: 1
    numberOfWorkers: 1
    runtimeName: 'python'
    runtimeVersion: funcAppRuntimeVersion
    appSettings:[
      {
        name: 'DOCINT_API_VERSION'
        value: docintApiVersion
      }
      {
        name: 'AZURE_KEY_VAULT_NAME'
        value: keyVault.outputs.name
      }
      {      
        name: 'FUNCTION_APP_NAME'
        value: dataIngestionFunctionAppName
      }
      {
        name: 'SEARCH_SERVICE'
        value: searchServiceName
      }
      {
        name: 'SEARCH_INDEX_NAME'
        value: searchIndex
      } 
      {
        name: 'SEARCH_ANALYZER_NAME'
        value: searchAnalyzerName
      }
      {
        name: 'SEARCH_API_VERSION'
        value: searchApiVersion
      }
      {
        name: 'SEARCH_INDEX_INTERVAL'
        value: searchIndexInterval
      }
      {
        name: 'STORAGE_ACCOUNT_NAME'
        value: storageAccountName
      }
      {
        name: 'STORAGE_CONTAINER'
        value: containerName
      }
      {
        name: 'AZURE_FORMREC_SERVICE'
        value: cognitiveServiceName
      }
      {
        name: 'AZURE_OPENAI_API_VERSION'
        value: openaiApiVersion
      }
      {
        name: 'AZURE_SEARCH_APPROACH'
        value: retrievalApproach
      }
      {
        name: 'AZURE_OPENAI_SERVICE_NAME'
        value: openAiServiceName
      }
      {
        name: 'AZURE_OPENAI_EMBEDDING_DEPLOYMENT'
        value: embeddingsDeploymentName
      }
      {
        name: 'NUM_TOKENS'
        value: chunkNumTokens
      }
      {
        name: 'MIN_CHUNK_SIZE'
        value: chunkMinSize
      }
      {
        name: 'TOKEN_OVERLAP'
        value: chunkTokenOverlap
      }
      {
        name: 'NETWORK_ISOLATION'
        value: networkIsolation
      }
      {
        name: 'ENABLE_ORYX_BUILD'
        value: 'true'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'true'
      }   
      {
        name: 'AzureWebJobsFeatureFlags'
        value: 'EnableWorkerIndexing'
      }
      {
        name: 'LOGLEVEL'
        value: 'INFO'
      }       
    ]  
  }
}

// Give the data ingestion access to KeyVault
module dataIngestionKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'data-ingestion-keyvault-access'
  scope: resourceGroup
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: dataIngestion.outputs.identityPrincipalId
  }
}

// Give the data ingestion access to blob storage
module dataIngestionBlobStorageAccess './core/security/blobstorage-access.bicep' = {
  name: 'data-ingestion-blobstorage-access'
  scope: resourceGroup
  params: {
    storageAccountName: storage.outputs.name
    principalId: dataIngestion.outputs.identityPrincipalId
  }
}

module ingestionPe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'ingestionPe'
  scope: resourceGroup
  params: {
    location: location
    name: 'ingestionPe${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: dataIngestion.outputs.id
    groupIds: ['sites']
    dnsZoneId: networkIsolation?websitesDnsZone.outputs.id:''
  }
}

module cognitiveServices 'core/ai/cognitiveservices.bicep' = {
  name: 'CognitiveServices'
  scope: resourceGroup
  params: {
    name: cognitiveServiceName
    location: location
    publicNetworkAccess: networkIsolation?'Disabled':'Enabled'
    kind: 'CognitiveServices'
    tags: tags
    sku: {
      name: 'S0'
    }
    secretsNames: { 
      secretName01: 'formRecKey' 
      secretName02: 'speechKey'
    }
    keyVaultName: keyVault.outputs.name
  }
}

module cognitiveServicesPe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'cognitiveServicesPe'
  scope: resourceGroup
  params: {
    location: location
    name: 'cognitiveServicesPe${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: cognitiveServices.outputs.id
    groupIds: ['account']
    dnsZoneId: networkIsolation?cognitiveservicesDnsZone.outputs.id:''
  }
}


module openAi 'core/ai/cognitiveservices.bicep' = {
  name: 'openai'
  scope: resourceGroup
  params: {
    name: openAiServiceName
    location: location
    publicNetworkAccess: networkIsolation?'Disabled':'Enabled'
    tags: tags
    sku: {
      name: 'S0' 
    }
    secretsNames: { 
      secretName01: 'azureOpenAIKey'
    }
    keyVaultName: keyVault.outputs.name    
    deployments: [
      {
        name: chatGptDeploymentName
        model: {
          format: 'OpenAI'
          name: chatGptModelName
          version: chatGptModelVersion
        }
        sku: {
          name: 'Standard'
          capacity: chatGptDeploymentCapacity
        }
      }
      {
        name: embeddingsDeploymentName
        model: {
          format: 'OpenAI'
          name: embeddingsModelName
          version: embeddingsModelVersion
        }
        sku: {
          name: 'Standard'
          capacity: embeddingsDeploymentCapacity
        }
      }      
    ]
  }
}

module openAiPe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'openAiPe'
  scope: resourceGroup
  params: {
    location: location
    name: 'openAiPe${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: openAi.outputs.id
    groupIds: ['account']
    dnsZoneId: networkIsolation?openaiDnsZone.outputs.id:''
  }
}

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: resourceGroup
  params: {
    name: searchServiceName
    location: location
    secretName: 'azureSearchKey'
    keyVaultName: keyVault.outputs.name
    publicNetworkAccess: networkIsolation?'Disabled':'Enabled'
    tags: tags
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    sku: {
      name: searchServiceSkuName
    }
    semanticSearch: 'free'
  }
}

module searchStoragePrivatelink 'core/search/search-private-link.bicep' = if (networkIsolation) {
  name: 'searchStoragePrivatelink'
  scope: resourceGroup
  params: {
   name: '${searchServiceName}-storagelink'
   searchName: searchServiceName
   resourceId: storage.outputs.id
   groupId: 'blob'
  }
}

module searchFuncAppPrivatelink 'core/search/search-private-link.bicep' = if (networkIsolation) {
  name: 'searchFuncAppPrivatelink'
  scope: resourceGroup
  params: {
   name: '${searchServiceName}-funcapplink'
   searchName: searchServiceName
   resourceId: dataIngestion.outputs.id
    groupId: 'sites'
  }
}

module searchPe './core/network/private-endpoint.bicep' = if (networkIsolation) {
  name: 'searchPe'
  scope: resourceGroup
  params: {
    location: location
    name: 'searchPe${resourceToken}'
    tags: tags
    subnetId: vnet.outputs.aiSubId
    serviceId: searchService.outputs.id
    groupIds: ['searchService']
    dnsZoneId: networkIsolation?searchDnsZone.outputs.id:''
  }
}

output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_ZERO_TRUST string = networkIsolation ? 'TRUE' : 'FALSE'
output AZURE_VM_NAME string = networkIsolation ? ztVmName : ''
output AZURE_VM_USERNAME string = networkIsolation ? vmUserName : ''
output AZURE_VM_KV_NAME string = networkIsolation ? bastionKvName : keyVault.outputs.name
output AZURE_VM_KV_SEC_NAME string = networkIsolation ? vmKeyVaultSecName : ''
output AZURE_DATA_INGEST_FUNC_NAME string = dataIngestionFunctionAppName
output AZURE_DATA_INGEST_FUNC_RG string = resourceGroup.name
output AZURE_SEARCH_PRINCIPAL_ID string = searchService.outputs.principalId
output AZURE_ORCHESTRATOR_FUNC_RG string = resourceGroup.name
output AZURE_ORCHESTRATOR_FUNC_NAME string = orchestratorFunctionAppName

// Set input params as outputs to persist the selection
// This strategy would allow to re-construct the .env file from a deployment object on azure by using env-name, sub and location.
// Without this, any custom selection would be lost when running `azd env refresh` from another machine.
output AZURE_RESOURCE_GROUP_NAME string = azureResourceGroupName
output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_NETWORK_ISOLATION bool = networkIsolation
output AZURE_DB_ACCOUNT_NAME string = azureDbAccountName
output AZURE_DB_DATABASE_NAME string = azureDbDatabaseName
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccountName
output AZURE_COGNITIVE_SERVICE_NAME string = azureCognitiveServiceName
output AZURE_APP_SERVICE_PLAN_NAME string = azureAppServicePlanName
output AZURE_APP_INSIGHTS_NAME string = azureAppInsightsName
output AZURE_APP_SERVICE_NAME string = azureAppServiceName
output AZURE_ORCHESTRATOR_FUNCTION_APP_NAME string = azureOrchestratorFunctionAppName
output AZURE_DATA_INGESTION_FUNCTION_APP_NAME string = azureDataIngestionFunctionAppName
output AZURE_SEARCH_SERVICE_NAME string = azureSearchServiceName
output AZURE_OPEN_AI_SERVICE_NAME string = openAiServiceName
output AZURE_OPEN_AI_MODEL_NAME string = chatGptDeploymentName
output AZURE_VNET_NAME string = azureVnetName

output AZURE_SEARCH_USE_MIS bool = azureSearchUseMIS
