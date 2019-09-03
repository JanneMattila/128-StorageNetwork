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
.\deploy.ps1 -IPRestrictions "123.123.123.123","321.321.321.321"

# Execute deployment with overriding defaults in command-line:
.\deploy.ps1  -IPRestrictions "123.123.123.123","321.321.321.321" -ResourceGroupName "storagenetwork-dev-rg" -Location "North Europe"

```