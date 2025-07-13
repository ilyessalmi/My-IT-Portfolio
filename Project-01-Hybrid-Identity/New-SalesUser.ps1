#
# SCRIPT: New-SalesUser.ps1
# AUTHOR: Ilyes Salmi
# PURPOSE: Automates the creation of a new user in the Sales OU and initiates a cloud sync.
#

# Step 1: Import the Active Directory module so we can use AD commands.
# This is like loading the right set of tools for the job.
Import-Module ActiveDirectory

# Step 2: Define all our user information in variables.
# This makes the script easy to read and modify for the next new hire.
$FirstName = "Alex"
$LastName = "Bernard"
$LogonName = "a.bernard"
$Password = "P@ssw0rd123!" | ConvertTo-SecureString -asPlainText -Force
$OUPath = "OU=Sales,OU=_Users,OU=CORP,DC=corp,DC=contoso,DC=com" # This is the exact "address" of the Sales OU.

# Step 3: Use the New-ADUser command to create the account.
# The backtick ` character lets us break a long command onto multiple lines for readability.
New-ADUser -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $LogonName `
    -UserPrincipalName "$LogonName@corp.contoso.com" `
    -Path $OUPath `
    -AccountPassword $Password `
    -Enabled $true `
    -ChangePasswordAtLogon $false

# Step 4: Provide feedback to the admin running the script.
Write-Host "User '$FirstName $LastName' was created successfully in Active Directory." -ForegroundColor Green

# Step 5: Manually trigger an Entra ID Connect sync cycle.
# Otherwise, we would have to wait up to 30 minutes for the new user to appear in the cloud.
# 'Delta' means "sync only the changes."
Write-Host "Starting a Delta Sync to Microsoft Entra ID..."
Start-ADSyncSyncCycle -PolicyType Delta
Write-Host "Sync cycle has been initiated. Check M365 Admin Center in a few minutes."
