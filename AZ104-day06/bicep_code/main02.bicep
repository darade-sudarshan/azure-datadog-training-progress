resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for i in range(0, 3): {
  name: '${i}appstore443443'
  location: 'South East Asia'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}]
