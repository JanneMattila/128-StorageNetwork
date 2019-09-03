# 128-StorageNetwork

Example Azure Storage Account template deployment
which sets IP network restrictions to the storage account.

Steps to execute deployment using Azure PowerShell: 
```powershell
Login-AzureRmAccount

# *Explicitly* select your working context
Select-AzureRmSubscription -SubscriptionName <YourSubscriptionName>

# Now you're ready!
cd .\deploy\

# Execute deployment with "local" development defaults:
.\deploy.ps1

# Execute deployment with overriding defaults in command-line:
.\deploy.ps1 -ResourceGroupName "storagenetwork-dev-rg" -Location "North Europe"

```