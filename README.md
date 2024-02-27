
# Zabbix-Azure-App-Registration-Expiration-Monitoring

# Attention, this monitoring was developed in Zabbix 5.0 so previous versions are not compatible

Powershell script to audit all Azure AD app registrations and notify secret key or certificate expiration to zabbix using Microsoft Graph. Script check all the Azure AD Applications registered in your tenant and check key expiration.


This project was created based on the project below where we used the main idea and created more optimized monitoring with discovery rules and mass data collection thinking about large environments.

Original project url:

https://github.com/Ufoton/ZabbixAzureSecretTTL

1 - Change macros with your Azure credentials.

{$APPID} = Azure clientid

{$SECRET} = Azure client secret

{$TENANTID} = Azure Tenant ID

{$HIGHALERTDAYS} = Alert Parameter for High severity

{$WARNINGALERTDAYS} = Alert parameter for the Attention severity

2 - Requirements:

Powershell 7.0 or higher is required for correct operation.

Install-Module Microsoft.Graph -Scope AllUsers

3 - Command line usage for testing the zabbix discovery rule:

.\Azure_App_Registration_Discovery.ps1 -appid {$APPID} -tenantid {$TENANTID} -secret {$SECRET} lld

4 - Testing to Get Bulk Data from Azure App Registrations in JSON

.\App_Registration_Azure_Dados.ps1" -appid {$APPID} -tenantid {$TENANTID} -secret {$SECRET} -requestType "credentials"
