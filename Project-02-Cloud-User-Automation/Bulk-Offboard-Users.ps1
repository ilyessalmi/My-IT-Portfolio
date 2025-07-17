# SCRIPT: Bulk-Offboard-CloudUsers.ps1
# PURPOSE: Securely offboards multiple cloud-only users from a CSV file.

# Connect to Microsoft Graph with the necessary permissions.
Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# Import the list of departing employees.
Write-Host "Importing users to offboard from CSV file..."
$usersToOffboard = Import-Csv -Path "C:\Temp\DepartingUsers.csv"
Write-Host "Found $($usersToOffboard.Count) users to process."
Write-Host "---"

# Loop through each user in the CSV and perform the secure offboarding process.
foreach ($user in $usersToOffboard) {

    # This is the UPN from our CSV file for the current user in the loop.
    $upn = $user.UserPrincipalName

    # This is the error handling block. PowerShell will TRY to run the code inside {}.
    # If ANY command fails, it will immediately jump to the CATCH block.
    try {
        # Find the user in Microsoft Entra ID.
        Write-Host "Processing user: $upn"
        $userObject = Get-MgUser -UserId $upn -ErrorAction Stop

        # Block their sign-in immediately using the correct BodyParameter format.
        # Create a "body" package (a hashtable) containing the properties we want to change.
        $userUpdate = @{
            AccountEnabled = $false
        }
        # Now we call Update-MgUser and pass the entire package to the -BodyParameter.
        Update-MgUser -UserId $userObject.Id -BodyParameter $userUpdate
        Write-Host "  -> Sign-in for $($userObject.DisplayName) is now BLOCKED." -ForegroundColor Yellow

        # Remove all assigned licenses to free them up and save costs.
        Write-Host "  -> Checking for assigned licenses..."
        if ($userObject.AssignedLicenses.Count -gt 0) {
            # This code only runs IF the user has one or more licenses.
            Write-Host "  -> Found $($userObject.AssignedLicenses.Count) license(s). Removing them..."
            Set-MgUserLicense -UserId $userObject.Id -AddLicenses @() -RemoveLicenses $userObject.AssignedLicenses.SkuId
            Write-Host "  -> All licenses removed." -ForegroundColor Yellow
        }
        else {
            # This code runs if the user has no licenses.
            Write-Host "  -> User has no licenses to remove." -ForegroundColor Green
        }

        # Provide info for the final deletion step.
        Write-Host "  -> User is ready for deletion. To permanently delete, run:" -ForegroundColor Cyan
        Write-Host "     Remove-MgUser -UserId '$($userObject.Id)'" -ForegroundColor Cyan
    }
    catch {
        # This code only runs if something in the 'try' block failed.
        # The "$_" variable automatically contains the error message.
        Write-Error "Failed to process user '$upn'. They might not exist or another error occurred. Details: $_"
    }
    Write-Host "---" # Separator to make the output easy to read
}
