param Location string
param Prefix string
param VNetAddressSpace string
param VNetGatewaySubnetPrefix string
param RouteServerSubnetPrefix string
param New bool
param ExistingVnetName string = ''
param vnetid string

var VNetName = empty(ExistingVnetName) ? '${Prefix}-VNet' : ExistingVnetName
var name = reference(vnetid, '2021-05-01', true)

resource VNet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (New) {

  name: VNetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: VNetGatewaySubnetPrefix
        }
      }
      {
        name: 'RouteServerSubnet'
        properties: {
          addressPrefix: RouteServerSubnetPrefix
        }
      }
    ]
  }
}

resource VNetExisting 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (!New) {

  name: VNetName
}

output VNetName string = New? VNet.name:VNetExisting.name
output VNetResourceId string = VNet.id
output VNetGatewaySubnetId string = VNet.properties.subnets[0].id
output VNetRouteServerSubnetId string = VNet.properties.subnets[1].id

