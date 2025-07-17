# SCRIPT: Onboard-CloudUsers.ps1
# PURPOSE: Onboards new cloud-only M365 users from a CSV file using Microsoft Graph API.

# Connect to Microsoft Graph with the necessary permissions.
Write-Host "Connecting to Microsoft Graph ..."
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# Find the main assignable license in this tenant.
Write-Host "Finding the tenant's main user license..."
$licenseSku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "O365_w/o_Teams_Bundle_M5" }

# A safety check. If we didn't find the license, we stop the script.
if (-not $licenseSku) {
    Write-Error "Could not find the specified license SKU (O365_w/o_Teams_Bundle_M5) in this tenant."
    return
}
Write-Host "Found License SKU ID: $($licenseSku.SkuId)" -ForegroundColor Cyan

# Import the user data from the CSV file.
$users = Import-Csv -Path "C:\Temp\NewHires.csv"

# Loop through each user in the CSV and create their account.
foreach ($user in $users) {
    # Construct the user's information
    $displayName = "$($user.FirstName) $($user.LastName)"
    $mailNickname = "$($user.FirstName.Substring(0,1))$($user.LastName)".ToLower()
    $userPrincipalName = "$($mailNickname)@acces93.onmicrosoft.com"

    # Define the user's password profile and forces the user to change their password on first login.
    $passwordProfile = @{
        ForceChangePasswordNextSignIn = $true
        Password                      = ('P@ssw0rd' + (Get-Random -Minimum 1000 -Maximum 9999)) # Generate a temporary, random password
    }

    # Create the user object with all properties
    $newUserParams = @{
        AccountEnabled    = $true
        DisplayName       = $displayName
        UserPrincipalName = $userPrincipalName
        MailNickname      = $mailNickname
        GivenName         = $user.FirstName
        Surname           = $user.LastName
        Department        = $user.Department
        UsageLocation     = "FR"
        PasswordProfile   = $passwordProfile
    }

    try {
        Write-Host "Creating user: $displayName..."
        $newUser = New-MgUser @newUserParams
        Write-Host "Successfully created user $($newUser.UserPrincipalName). Temporary Password: $($passwordProfile.Password)" -ForegroundColor Green
        # Assign the E5 license to the new user
        Write-Host "Assigning E5 license to $($newUser.UserPrincipalName)..."
        Set-MgUserLicense -UserId $newUser.Id -AddLicenses @{SkuId = $licenseSku.SkuId } -RemoveLicenses @()
        Write-Host "License assigned successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create or license user $displayName. Error: $_"
    }
}
