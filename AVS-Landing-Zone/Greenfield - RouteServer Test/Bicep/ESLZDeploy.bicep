targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'SJAVS'

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param VNetName string = ''

param DeployRouteServer bool = false
param RouteServerSubnetExists bool = false

param OnPremConnectivity string = ''

@description('The subnet CIDR used for the RouteServer Subnet')
param RouteServerSubnetPrefix string = ''

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module Blank 'Modules/Deployment.bicep' = if ((OnPremConnectivity == 'ExpressRoute') || (!DeployRouteServer)) {
  name: '${deploymentPrefix}-Deployment'
} 

module RouteServer 'Modules/Networking.bicep' = if ((OnPremConnectivity == 'VPN') && (DeployRouteServer)) {
  name: '${deploymentPrefix}-VNet'
  params: {
    Prefix: Prefix
    Location: Location
    VNetName: VNetName
    RouteServerSubnetPrefix : RouteServerSubnetPrefix
    RouteServerSubnetExists : RouteServerSubnetExists
  }
}
