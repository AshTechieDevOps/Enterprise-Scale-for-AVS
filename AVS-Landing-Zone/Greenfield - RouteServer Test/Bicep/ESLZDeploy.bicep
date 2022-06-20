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
param RouteServerSubnetPrefix string = ''

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module RouteServer 'Modules/RouteServer.bicep' = {
  name: '${deploymentPrefix}-VNet'
  params: {
    Prefix: Prefix
    Location: Location
    VNetName: 'SJAVS-Vnet'
    RouteServerSubnetPrefix : RouteServerSubnetPrefix
    NetworkResourceGroup: NetworkResourceGroup
    VNetPrefix: Prefix
    PrivateCloudName: 'SJAVS-SDDC'
    PrivateCloudResourceGroup: 'SJAVS-PrivateCloud'
  }
}
