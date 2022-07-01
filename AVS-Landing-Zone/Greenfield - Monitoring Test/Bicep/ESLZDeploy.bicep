targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'SJAVS'

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

@description('Deploy AVS Dashboard')
param DeployDashbord bool = false

@description('Deploy Azure Monitor metric alerts for your AVS Private Cloud')
param DeployMetricAlerts bool = false

@description('Deploy Service Health Alerts for AVS')
param DeployServiceHealth bool = false

param PrivateCloudName string = ''

param PrivateCloudResourceId string = ''

param ExRConnectionResourceId string = ''

@description('Email addresses to be added to the alerting action group. Use the format ["name1@domain.com","name2@domain.com"].')
param AlertEmails string = ''

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module SkipMonitoring 'Modules/Deployment.bicep' = if ((!DeployMetricAlerts) || (!DeployServiceHealth) || (!DeployDashbord)) {
  name: '${deploymentPrefix}-SkipMonitoring'
} 

module OperationalMonitoring 'Modules/Monitoring.bicep' = if ((DeployMetricAlerts) || (DeployServiceHealth) || (DeployDashbord)) {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    PrimaryLocation: Location
    DeployMetricAlerts : DeployMetricAlerts
    DeployServiceHealth : DeployServiceHealth
    DeployDashbord : DeployDashbord
    PrivateCloudName : PrivateCloudName
    PrivateCloudResourceId : PrivateCloudResourceId
    ExRConnectionResourceId : ExRConnectionResourceId
  }
}
