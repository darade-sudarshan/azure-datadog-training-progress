resource app_set 'Microsoft.Compute/availabilitySets@2022-11-01' = {
  name: 'app-set'
  location: 'South East Asia'
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 3
    platformUpdateDomainCount: 5
  }
}
