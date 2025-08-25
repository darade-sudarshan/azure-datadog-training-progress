resource data_disk 'Microsoft.Compute/disks@2022-07-02' = {
  name: 'data-disk'
  location:  'South East Asia'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 16
  }
}
