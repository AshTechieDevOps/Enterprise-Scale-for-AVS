param Location string
param Prefix string
param VNetName string
param RouteServerSubnetPrefix string

var RouteServerName = '${Prefix}-RS'

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource RouteServerSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'RouteServerSubnet'
  parent: VNet
  properties: {
    addressPrefix: RouteServerSubnetPrefix
  }
}

resource RouteServerIPConfiguration 'Microsoft.Network/virtualHubs/ipConfigurations@2021-05-01' = {
  name: '${RouteServerName}-ipconfig'
  parent: RouteServer
  properties: {
    subnet: {
      id: RouteServerSubnet.id
    }
    publicIPAddress: {
      id: RouteServerPIP.id
    }
  }
}

resource RouteServerPIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${RouteServerName}-PIP'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource RouteServer 'Microsoft.Network/virtualHubs@2021-05-01' = {
  name: RouteServerName
  location: Location
  properties: {
    allowBranchToBranchTraffic: true
    sku: 'Standard'
  }
}


output RouteServer string = RouteServer.name
output RouteServerSubnetId string = RouteServerSubnet.id
