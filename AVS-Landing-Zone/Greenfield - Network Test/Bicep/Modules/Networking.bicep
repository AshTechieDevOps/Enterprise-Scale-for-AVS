targetScope = 'subscription'

param Location string
param Prefix string
param VNetExists bool
param ExistingVnetName string
param GatewayExists bool
param ExistingGatewayName string
param NewVNetAddressSpace string
param NewGatewaySubnetAddressPrefix string

resource NetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-Network'
  location: Location
}

module Network 'Networking/VNetWithGW.bicep' = {
  scope: NetworkResourceGroup
  name: '${deployment().name}-Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetExists: VNetExists
    ExistingVnetName : ExistingVnetName
    GatewayExists : GatewayExists
    ExistingGatewayName : ExistingGatewayName
    NewVNetAddressSpace: NewVNetAddressSpace
    NewGatewaySubnetAddressPrefix: NewGatewaySubnetAddressPrefix
  }
}

output NewGatewayName string = Network.outputs.NewGatewayName
output ExistingGatewayName string = Network.outputs.ExistingGatewayName
output VNetName string = Network.outputs.VNetName
output VNetResourceId string = Network.outputs.VNetResourceId
output NetworkResourceGroup string = NetworkResourceGroup.name
