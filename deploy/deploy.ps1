<#
.SYNOPSIS
Deploy Azure Storage account and apply IP Restrictions
to it based on user provided parameters.

.DESCRIPTION
Demonstration application for ARM template deployment
and Azure Storage account handling.

.PARAMETER ResourceGroupName
    Deployment target resource group.

.PARAMETER Location
    Deployment target resource group location.

.PARAMETER IPRestrictions
    IP Restrictions for the storage acceount.

.LINK
See original source code from GitHub:
https://github.com/JanneMattila/128-StorageNetwork

.EXAMPLE
.\deploy.ps1 -IPRestrictions "123.123.123.123","321.321.321.321"

Deploys ARM template and applies two IP rules to it.
#>
Param (
    [Parameter(HelpMessage="Deployment target resource group")] 
    [string] $ResourceGroupName = "storagenetwork-local-rg",

    [Parameter(HelpMessage="Deployment target resource group location")] 
    [string] $Location = "West Europe",

    [Parameter(HelpMessage="IP Restrictions for the storage acceount")] 
    [string[]] $IPRestrictions,

    [string] $Template = "$PSScriptRoot\azuredeploy.json",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json"
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME))
{
   Write-Host (@"
Not executing inside Azure DevOps Release Management.
Make sure you have done "Login-AzureRmAccount" and
"Select-AzureRmSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else
{
    $deploymentName = $env:RELEASE_RELEASENAME
}

if ($null -eq (Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue))
{
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Create additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable

if ($IPRestrictions -ne $null)
{
    $rules = New-Object System.Collections.ArrayList
    Write-Host "Following IP Rules will be set:"
    foreach($rule in $IPRestrictions)
    {
        Write-Host $rule
        $rules.Add(@{"value"=$rule}) | Out-Null
    }
    $additionalParameters['ipRules'] = $rules.ToArray()
}
else
{
    Write-Warning "No IP Rules set."
}

$result = New-AzureRmResourceGroupDeployment `
    -DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
    -Mode Complete -Force `
    -Verbose

$result

if ($null -eq $result.Outputs.storage)
{
    Throw "Template deployment didn't return 'output' variables correctly and therefore deployment is cancelled."
}

$variableName = $result.Outputs.storage.value

Write-Host "##vso[task.setvariable variable=Custom.Storage;]$variableName"
