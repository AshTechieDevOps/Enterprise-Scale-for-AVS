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
param NewVnetNewGatewaySubnetAddressPrefix string = ''

@description('Set this to true if you are redeploying, and the VNet already exists')
param GatewayExists bool = false

@description('Does the GatewaySubnet Exist')
param GatewaySubnetExists bool = false

@description('The existing vnet gatewaysubnet id')
param ExistingGatewaySubnetId string = ''

@description('The existing vnet new gatewaysubnet prefix')
param ExistingVnetNewGatewaySubnetPrefix string = ''

@description('A string value to skip the networking deployment')
param DeployNetworking bool = false

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module SkipNetworking 'Modules/Deployment.bicep' = if (!DeployNetworking) {
  name: '${deploymentPrefix}-SkipNetworking'
} 

module Networking 'Modules/Networking.bicep' = if (DeployNetworking) {
  name: '${deploymentPrefix}-Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetExists: VNetExists
    ExistingVnetName : ExistingVnetName
    GatewayExists : GatewayExists
    ExistingGatewayName : ExistingGatewayName
    GatewaySubnetExists : GatewaySubnetExists
    ExistingGatewaySubnetId : ExistingGatewaySubnetId
    ExistingVnetNewGatewaySubnetPrefix : ExistingVnetNewGatewaySubnetPrefix
    NewVNetAddressSpace: NewVNetAddressSpace
    NewVnetNewGatewaySubnetAddressPrefix: NewVnetNewGatewaySubnetAddressPrefix
  }
}

module VNetConnection 'Modules/VNetConnection.bicep' = if (DeployNetworking) {
  name: '${deploymentPrefix}-VNet'
  params: {
    GatewayName: DeployNetworking ? Networking.outputs.GatewayName : 'none'
    NetworkResourceGroup: DeployNetworking ? Networking.outputs.NetworkResourceGroup : 'none'
    VNetPrefix: Prefix
    PrivateCloudName: 'SJAVS-SDDC'
    PrivateCloudResourceGroup: 'SJAVS-PrivateCloud'
    Location: Location
  }
}
