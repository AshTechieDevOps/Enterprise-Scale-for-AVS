targetScope = 'subscription'

param VNetPrefix string
param AVSPrefix string = VNetPrefix
param PrivateCloudResourceGroup string
param PrivateCloudName string
param NetworkResourceGroup string
param GatewayExists bool
param NewGatewayName string
param ExistingGatewayName string
param Location string

module AVSExRAuthorization 'VNetConnection/AVSAuthorization.bicep' = {
  scope: resourceGroup(PrivateCloudResourceGroup)
  name: '${deployment().name}-ExRAuth'
  params: {
    ConnectionName: '${VNetPrefix}-VNet'
    PrivateCloudName: PrivateCloudName
  }
}

module VNetExRConnection 'VNetConnection/VNetExRConnection.bicep' = {
  scope: resourceGroup(NetworkResourceGroup)
  name: '${deployment().name}-ExR'
  params: {
    NewGWConnectionName: '${AVSPrefix}-AVS-GW'
    ExistingGWConnectionName: '${AVSPrefix}-AVS-EGW'
    GatewayExists : GatewayExists
    NewGatewayName: NewGatewayName
    ExistingGatewayName : ExistingGatewayName
    ExpressRouteAuthorizationKey: AVSExRAuthorization.outputs.ExpressRouteAuthorizationKey
    ExpressRouteId: AVSExRAuthorization.outputs.ExpressRouteId
    Location: Location
  }
}

output ExRConnectionResourceId string = VNetExRConnection.outputs.ExRConnectionResourceId
