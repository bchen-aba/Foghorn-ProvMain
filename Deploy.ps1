
[CmdletBinding()]
param (
    
    #[Parameter(Position=0)]
    #[string]$target_env 
    #,
    [string]$Category = "ConfigResourceGroup"
    ,
    $resource_group_name = "DevOps-Test-Resource-Group"
    ,
    $location = "East US"
)

###
#Initialize Connection
###
dir env:
#$allSubs = Get-Content "C:\Users\adm-bchen\Documents\WindowsPowershell\Scripts\FogHorn-DeploymentGroups\Environment.JSON" | ConvertFrom-Json
$allSubs = Get-Content ".\_bchen-aba_FogHorn-DeploymentGroups\Environment.JSON" | ConvertFrom-Json
#$target_Env_Subs = $allSubs | select -expandproperty dev
$target_Env_Subs = $allSubs | select -expandproperty $Env:BUILD_SOURCEBRANCH

### 
#Working Dir mgmt 
####

cd $PSScriptRoot

foreach($subscriptionId in $target_Env_Subs){

    write-host "bchen-log:Query for AzSubscription $($subscriptionId.name)"
    $sub = Get-AzSubscription -SubscriptionID $subscriptionId.AzureSubID
    
    write-host "bchen-log:Set-AzContext"
    $sub | Set-AzContext
    
    #####
    #Create resource group
    ###
    $check_existing_rg = Get-AzResourceGroup -Name $resource_group_name -ErrorAction SilentlyContinue
    if($null -eq $check_existing_rg){
        write-host "bchen-log:New-AzResourceGroup"
        New-AzResourceGroup -Name $resource_group_name -Location $location 
    }else{
        write-warning "$resource_group_name already exists, Proceeding..."
    }
    
    ####
    #Configure resource group
    ####
    write-host "bchen-log:New-AzResourceGroupDeployment"
    
    New-AzResourceGroupDeployment -Name $Category `
        -ResourceGroupName $resource_group_name `
        -TemplateParameterFile ".\ArmTemplates\$Category\azuredeploy.parameters.json" `
        -TemplateFile ".\ArmTemplates\$Category\azuredeploy.json" `
        -Mode Incremental
    
    ####
    #End
    ###
    write-host "bchen-log:Clear-AZContext"
    Clear-AZContext -force
}
