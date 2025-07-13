# Project 1: Hybrid Identity Configuration for a Small Business

## Project Overview

This project simulates the configuration of a hybrid identity environment for a fictional company, "Contoso Ltd." The goal was to integrate an existing on-premises Active Directory with new Microsoft 365 cloud services. This solution enables employees to use a single set of credentials for both local and cloud resources, improving user experience and centralizing identity management under the IT department.

## Technologies Used

*   Windows Server 2022
*   Active Directory Domain Services (AD DS)
*   Microsoft Entra ID (formerly Azure AD)
*   Microsoft Entra ID Connect v2 (with Password Hash Synchronization)
*   Microsoft 365 E5
*   PowerShell 5.1 (via Windows PowerShell ISE)

## Implementation Steps

### 1. On-Premises & Cloud Foundation

I began by building a foundational on-premises environment using Hyper-V. This included a domain controller (`DC01`) configured with the `corp.contoso.com` domain and a client machine (`CLIENT01`). 

![Initial On-Premises Setup with DC01 and CLIENT01](screenshot-00-ADUC-DC01-CLIENT01.png)

A crucial prerequisite was to verify the `corp.contoso.com` custom domain within the M365 tenant to establish trust and ensure correct user principal name (UPN) mapping.


### 1a. Custom Domain Verification

A critical prerequisite for a successful hybrid identity deployment is verifying ownership of the on-premises domain namespace within Microsoft Entra ID. I initiated this process by adding the corp.contoso.com custom domain to the M365 tenant.
The verification process requires adding a specific TXT record to the domain's public DNS. While this was not possible for the fictional lab domain, I documented the required value, demonstrating a clear understanding of the real-world procedure.

![Custom Domain Name Verification](screenshot1a-custom_domain_name_verification.PNG)

To prepare the on-premises environment for synchronization, I then added corp.contoso.com as an alternative UPN suffix in Active Directory Domains and Trusts and ensured all user accounts were configured to use this UPN. This step is crucial for ensuring seamless identity mapping between on-premises AD and Microsoft Entra ID.


### 2. User Synchronization to the Cloud

Using Microsoft Entra ID Connect, I configured the synchronization bridge between the on-premises AD and Microsoft Entra ID. Key configurations included:
*   **Password Hash Synchronization (PHS):** For secure and seamless user sign-in to cloud services.
*   **OU Filtering:** Precisely selecting only the 'CORP' Organizational Unit for synchronization to prevent system accounts from being synced to the cloud.

The successful synchronization was confirmed in the M365 Admin Center, where on-prem users appeared with a "Synced from on-premises" status.

![Proof of Synced Users](screenshot-01-synced-users.png)


### 3. End-to-End User Authentication Test

The ultimate test of the system was to perform a login as an end-user. I assigned an M365 license to the test user 'Amelie Dubois' and successfully logged into the Office 365 portal using her on-premises credentials. This validated the entire identity flow.

![Successful User Login to Office 365](screenshot-02-successful-login.png)


### 4. Automation of User Onboarding

To demonstrate efficiency and scalability, I wrote a PowerShell script to automate the creation of new user accounts. This script creates a user in the correct Active Directory OU, sets their initial password, and then programmatically initiates a delta sync cycle with Entra ID Connect. This reduces a multi-step manual process to a single, repeatable command.

![PowerShell ISE showing the script and successful output](screenshot-04-powershell-script.png)

```PowerShell
# # This script automates the creation of a new user in the Sales OU and initiates a cloud sync.

# Step 1: Import the Active Directory module so we can use AD commands.
Import-Module ActiveDirectory

# Step 2: Define all our user information in variables.
# This makes the script easy to read and modify for the next new hire.
$FirstName = "Alex"
$LastName = "Bernard"
$LogonName = "a.bernard"
$Password = "P@ssw0rd123!" | ConvertTo-SecureString -asPlainText -Force
$OUPath = "OU=Sales,OU=_Users,OU=CORP,DC=corp,DC=contoso,DC=com" # This is the exact "address" of the Sales OU.

# Step 3: Use the New-ADUser command to create the account.
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
Write-Host "Starting a Delta Sync to Microsoft Entra ID..."
Start-ADSyncSyncCycle -PolicyType Delta
Write-Host "Sync cycle has been initiated. Check M365 Admin Center in a few minutes."
```

### 5. Evidence of Technical Detail
To confirm the underlying mechanism of the identity link, I inspected the user object's attributes in Active Directory. The presence of a value in the msDS-ConsistencyGuid attribute serves as the immutable "source anchor," proving the object is successfully and permanently linked to its corresponding cloud identity.

![alt text](screenshot-03-consistency-guid.png)


### 6. Skills Demonstrated
* Identity & Access Management: Deployed and managed Active Directory and Microsoft Entra ID.
* Hybrid Cloud Integration: Configured and maintained Microsoft Entra ID Connect for identity synchronization.
* IT Automation: Scripted user management tasks using PowerShell to improve efficiency and reduce manual error.
* System Administration: Performed core administrative tasks including OU design, user onboarding, and domain client management.
* Problem Solving: Understood and implemented a solution for a common business need: unifying user identities across on-premises and cloud platforms.
