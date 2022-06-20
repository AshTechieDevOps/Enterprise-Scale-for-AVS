param Location string
param Prefix string
param VNetExists bool
param ExistingVnetName string
param GatewayExists bool
param ExistingGatewayName string
param NewVNetAddressSpace string
param NewGatewaySubnetAddressPrefix string
param NewGatewaySku string = 'Standard'

var NewVNetName = '${Prefix}-vnet'
var NewVnetNewGatewayName = '${Prefix}-gw'
var ExistingVnetNewGatewayName = '${Prefix}-egw'

resource ExistingVNet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = if (VNetExists) {
  name: ExistingVnetName
}

resource NewVNet 'Microsoft.Network/virtualNetworks@2021-02-01' = if (!VNetExists) {
  name: NewVNetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        NewVNetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: NewGatewaySubnetAddressPrefix
      }
    }
    ]
  }
}

resource NewVNetGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = if (!VNetExists) {
  name: 'GatewaySubnet'
  parent: NewVNet
  properties: {
    addressPrefix: NewGatewaySubnetAddressPrefix
  }
}

resource ExistingVNetGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = if (VNetExists) {
  name: '${ExistingVNet.name}/GatewaySubnet'
}

resource NewGatewayPIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = if (!GatewayExists) {
  name: '${NewVnetNewGatewayName}-pip'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource ExistingGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' existing = if (GatewayExists) {
  name: ExistingGatewayName
}

resource NewVnetNewGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = if ((!GatewayExists) && (!VNetExists)) {
  name: NewVnetNewGatewayName
  location: Location
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: NewGatewaySku
      tier: NewGatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: NewVNetGatewaySubnet.id
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}

resource ExistingVnetNewGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = if ((!GatewayExists) && (VNetExists)) {
  name: ExistingVnetNewGatewayName
  location: Location
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: NewGatewaySku
      tier: NewGatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: ExistingVNetGatewaySubnet.id
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}

output VNetName string = VNetExists ? ExistingVNet.name : NewVNet.name
output NewGatewayName string = (!GatewayExists) && (VNetExists) ? NewVnetNewGateway.name : ExistingVnetNewGateway.name
output ExistingGatewayName string = GatewayExists ? ExistingGateway.name : ExistingGateway.name
output VNetResourceId string = VNetExists ? ExistingVNet.id : NewVNet.id
