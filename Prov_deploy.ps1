#new tenant
New-O365Tenant -OnMicrosoftDomainName 'leghorn.onmicrosoft.com' `
    -CompanyName 'Operation Leghorn' `
    -ContactEmail 'bchen@abacusgroupllc.com' `
    -Country 'US' `
    -Region 'NY' `
    -City 'New York' `
    -State 'NY' `
    -Address '655 3rd Avenue, 8th Floor' `
    -PostalCode '10010' `
    -ContactFirstName 'Bryan' `
    -ContactLastName 'Chen' `
    -ContactPhoneNumber '6467016973' `
    -UserCount 1 `
    -Office365Instance 'US' `
    -Language 'en' `
    -ClientType 'FlexPublicCloud' `
    -ValidateOnly


#somehow wait until this is done.

#Create new subscription

write-host "bchen-log:get-Azsubscription"
$sub = Get-AzSubscription -SubscriptionID $subscriptionId

write-host "bchen-log:Set-AzContext"
$sub | Set-AzContext


#lightHouse Deployment
$Category = "LighthouseConfig"
New-AzDeployment -Name LighthouseDeployment `
                 -Location "East US" `
                 -TemplateParameterFile ".\Configuration\ArmTemplates\$Category\azuredeploy.parameters.json" `
                 -TemplateFile ".\Configuration\ArmTemplates\$Category\azuredeploy.json" `
                 -Verbose