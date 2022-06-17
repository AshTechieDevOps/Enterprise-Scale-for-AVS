param GatewayExists bool
param NewGatewayName string
param NewGWConnectionName string
param ExistingGatewayName string
param ExistingGWConnectionName string
param Location string

@secure()
param ExpressRouteAuthorizationKey string
@secure()
param ExpressRouteId string

resource NewGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' existing = if (!GatewayExists) {
  name: NewGatewayName
}

resource NewGWConnection 'Microsoft.Network/connections@2021-02-01' = if (!GatewayExists) {
  name: NewGWConnectionName
  location: Location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
    virtualNetworkGateway1: {
      id: NewGateway.id
      properties: {}
    }
    peer: {
      id: ExpressRouteId
    }
    authorizationKey: ExpressRouteAuthorizationKey
  }
}

resource ExistingGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' existing = if (GatewayExists) {
  name: ExistingGatewayName
}

resource ExistingGWConnection 'Microsoft.Network/connections@2021-02-01' = if (GatewayExists) {
  name: ExistingGWConnectionName
  location: Location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
    virtualNetworkGateway1: {
      id: ExistingGateway.id
      properties: {}
    }
    peer: {
      id: ExpressRouteId
    }
    authorizationKey: ExpressRouteAuthorizationKey
  }
}

output ExRConnectionResourceId string = GatewayExists ? ExistingGWConnection.id : NewGWConnection.id
