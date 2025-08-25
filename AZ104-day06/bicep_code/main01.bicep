resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'appstore443553'
  location: 'South East Asia'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

