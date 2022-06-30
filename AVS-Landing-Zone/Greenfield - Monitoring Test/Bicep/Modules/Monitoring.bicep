targetScope = 'subscription'

param Prefix string
param PrimaryLocation string
param AlertEmails string

resource OperationalResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: '${Prefix}-Operational'
  location: PrimaryLocation
}

module ActionGroup 'Monitoring/ActionGroup.bicep' = {
  scope: OperationalResourceGroup
  name: '${deployment().name}-ActionGroup'
  params: {
    Prefix: Prefix
    ActionGroupEmails: AlertEmails
  }
}

