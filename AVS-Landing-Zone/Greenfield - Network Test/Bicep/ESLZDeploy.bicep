targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'AVS'

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

@description('Set this to true if you are redeploying, and the VNet already exists')
param VNetExists bool = false
@description('The Existing VNet name')
param ExistingVnetName string = ''
@description('The Existing Gateway name')
param ExistingGatewayName string = ''
@description('The address space used for the VNet attached to AVS. Must be non-overlapping with existing networks')
param NewVNetAddressSpace string = ''
@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param NewGatewaySubnetAddressPrefix string = ''

@description('Set this to true if you are redeploying, and the VNet already exists')
param GatewayExists bool = false

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module Networking 'Modules/Networking.bicep' = {
  name: '${deploymentPrefix}-Network'
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

module VNetConnection 'Modules/VNetConnection.bicep' = {
  name: '${deploymentPrefix}-VNet'
  params: {
    NewGatewayName: Networking.outputs.NewGatewayName
    ExistingGatewayName : Networking.outputs.ExistingGatewayName
    NetworkResourceGroup: Networking.outputs.NetworkResourceGroup
    VNetPrefix: Prefix
    GatewayExists : GatewayExists
    PrivateCloudName: 'SJAVS-SDDC'
    PrivateCloudResourceGroup: 'SJAVS-PrivateCloud'
    Location: Location
  }
}
