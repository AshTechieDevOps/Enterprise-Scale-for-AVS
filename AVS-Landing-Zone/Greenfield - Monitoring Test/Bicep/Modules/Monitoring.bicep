targetScope = 'subscription'

param Prefix string
param PrimaryLocation string
param AlertEmails string
param DeployMetricAlerts bool
param DeployServiceHealth bool
param PrivateCloudName string
param PrivateCloudResourceId string

resource OperationalResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: '${Prefix}-Operational'
  location: PrimaryLocation
}

module ActionGroup 'Monitoring/ActionGroup.bicep' = if ((DeployMetricAlerts) || (DeployServiceHealth)) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-ActionGroup'
  params: {
    Prefix: Prefix
    ActionGroupEmails: AlertEmails
  }
}

module PrimaryMetricAlerts 'Monitoring/MetricAlerts.bicep' = if (DeployMetricAlerts) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-MetricAlerts'
  params: {
    ActionGroupResourceId: ActionGroup.outputs.ActionGroupResourceId
    AlertPrefix: PrivateCloudName
    PrivateCloudResourceId: PrivateCloudResourceId
  }
}
