//Bool
param VNetExists bool
param GatewayExists bool
param GatewaySubnetExists bool

//String
param Location string
param Prefix string
param ExistingVnetName string
param ExistingGatewayName string
param NewVNetAddressSpace string
param NewVnetNewGatewaySubnetAddressPrefix string
param NewGatewaySku string = 'Standard'
param ExistingGatewaySubnetId string
param ExistingVnetNewGatewaySubnetPrefix string

var NewVNetName = '${Prefix}-vnet'
var NewVnetNewGatewayName = '${Prefix}-gw'
var ExistingVnetNewGatewayNewSubnetName = '${Prefix}-egw'

// Existing VNet Workflow
resource ExistingVNet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = if (VNetExists) {
  name: ExistingVnetName
}

// If VNet exists, but GatewaySubnet does not. Create new GatewaySubnet
resource ExistingVnetNewGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = if ((VNetExists) && (!GatewaySubnetExists)) {
  name: 'GatewaySubnet'
  parent: ExistingVNet
  properties: {
    addressPrefix: ExistingVnetNewGatewaySubnetPrefix
  }
}

//Vnet exists, deploy new gateway in new gateway subnet
resource ExistingVnetNewGatewayNewSubnet 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = if ((!GatewayExists) && (VNetExists) && (!GatewaySubnetExists)) {
  name: ExistingVnetNewGatewayNewSubnetName
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
            id: ExistingVnetNewGatewaySubnet.id
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}

//Vnet exists, deploy new gateway in existing gateway subnet
resource ExistingVnetNewGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = if ((!GatewayExists) && (VNetExists) && (GatewaySubnetExists)) {
  name: ExistingVnetNewGatewayNewSubnetName
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
            id: ExistingGatewaySubnetId
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}

//New VNet Workflow
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
          addressPrefix: NewVnetNewGatewaySubnetAddressPrefix
      }
    }
    ]
  }
}

//New Gateway Workflow
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
            id: NewVNet.properties.subnets[0].id
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
output NewGatewayName string = ((!GatewayExists) && (!VNetExists)) ? NewVnetNewGateway.name : ExistingVnetNewGateway.name
output ExistingGatewayName string = GatewayExists ? ExistingGateway.name : ExistingGateway.name
output VNetResourceId string = VNetExists ? ExistingVNet.id : NewVNet.id
