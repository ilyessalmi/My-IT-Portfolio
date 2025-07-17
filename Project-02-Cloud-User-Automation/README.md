# Project 2: Cloud-Native User Automation with Microsoft Graph API

## Project Overview

This project simulates the complete lifecycle management of cloud-native users for a growing company. The primary goal was to automate the onboarding and offboarding processes using modern tools, ensuring efficiency, security, and scalability. All operations were performed using the **Microsoft Graph PowerShell SDK**, which is the current industry standard, replacing legacy modules like MSOnline.

## Technologies Used

*   PowerShell 7
*   **Microsoft Graph PowerShell SDK**
*   Microsoft Entra ID
*   Microsoft 365 E5 Licensing
*   Visual Studio Code

## 1. Automated Onboarding from a CSV File

I developed a PowerShell script (`Onboard-CloudUsers.ps1`) to ingest a list of new hires from a CSV file. The script performs the following actions for each user:
*   Connects to Microsoft Graph with the required `User.ReadWrite.All` permissions.
*   Programmatically finds the correct License SKU ID for the tenant's primary license.
*   Creates a new user account in Microsoft Entra ID with properties from the CSV.
*   Sets the user's mandatory "Usage Location" to enable license assignment.
*   Assigns a secure, temporary password and sets the "Force password change on next sign-in" flag—a critical security best practice.
*   Assigns the correct license to the new user.

The script's output provides a real-time audit trail of created users and their temporary passwords.

![PowerShell script successfully creating users](screenshot-2-01-onboarding-in-action.png)

The newly created users were immediately visible and correctly configured in the Microsoft 365 Admin Center, fully licensed and ready for work.

![Newly onboarded users in the Admin Center](screenshot-2-02-onboarded-users-in-gui.png)

## 2. Scalable and Secure Bulk Offboarding

To handle departing employees, a second script (`Bulk-Offboard-Users.ps1`) was developed to process a list of users from a CSV file. This script follows a secure offboarding workflow:
1.  **Immediate Sign-in Block:** The user's account is immediately disabled to prevent any further access.
2.  **License Reclamation:** The script first checks if the user has licenses, then removes all assigned licenses to free them up for new employees and ensure cost efficiency.
3.  **Robust Error Handling:** The entire process for each user is wrapped in a `try/catch` block, allowing the script to report an error for one user (e.g., a typo in the CSV) and continue processing the rest of the list.

![The offboarding script processing multiple users](screenshot-2-03-offboarding-in-action.png)

## 3. Real-World Troubleshooting

During development, several real-world challenges were encountered and resolved:
*   **Incorrect License SKU:** The initial script failed because the hardcoded license SKU (`SPE_E5`) did not match the tenant's actual SKU. This was resolved by using `Get-MgSubscribedSku` to dynamically find the correct license part number.
*   **Missing PowerShell Modules:** The `Set-MgUserLicense` command failed because its specific module (`Microsoft.Graph.Users.Actions`) was not installed. This was resolved by identifying and installing the required module.
*   **Invalid Usage Location:** License assignments failed with a "BadRequest" error. I diagnosed this as a missing "Usage Location" property on the user accounts and updated the scripts to set this mandatory property before attempting to assign a license.
*   **Modern Graph SDK Syntax:** An error with the `Update-MgUser` command was traced to a syntax change in the modern SDK. The issue was resolved by using the correct `-BodyParameter` format to pass the account status.

---
## Summary of Skills Demonstrated

*   **Modern IT Automation:** Utilized the current-generation **Microsoft Graph PowerShell SDK** to perform complex administrative tasks, demonstrating modern, best-practice scripting skills.
*   **Identity Lifecycle Management:** Managed the full user lifecycle from creation and licensing to secure offboarding and license reclamation.
*   **Advanced Troubleshooting:** Successfully diagnosed and resolved multiple real-world errors related to licensing, module dependencies, and mandatory user attributes.
*   **Robust Scripting:** Implemented security best practices (force password change on next sign-in) and robust features like error handling (`try/catch`) and pre-checks (verifying if a user has licenses before removal).
*   **Process Efficiency:** Created a scalable solution that can manage dozens of users in seconds, a massive improvement over manual GUI-based methods.
