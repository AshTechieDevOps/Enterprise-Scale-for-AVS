targetScope = 'subscription'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'SJAVS'

@description('Optional: The location the private cloud should be deployed to, by default this will be the location of the deployment')
param Location string = deployment().location

@description('Email addresses to be added to the alerting action group. Use the format ["name1@domain.com","name2@domain.com"].')
param AlertEmails string

var deploymentPrefix = 'AVS-${uniqueString(deployment().name, Location)}'

module OperationalMonitoring 'Modules/Monitoring.bicep' = {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    PrimaryLocation: Location
  }
}
