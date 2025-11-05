# Project 1: On-Premises & Hybrid Cloud Infrastructure

## Project Overview

This foundational project simulates the design and deployment of a complete on-premises and hybrid cloud infrastructure for a small business, "Contoso Ltd." The project began with building a core on-premises network using Windows Server, including identity, network services, and centralized management. It concluded by integrating this traditional environment with the cloud using Microsoft Entra ID to enable a seamless single sign-on experience.

## Technologies Used

*   Windows Server 2022
*   Active Directory Domain Services (AD DS)
*   **DNS, DHCP, and Group Policy (GPO)**
*   **Routing and Remote Access (RRAS) for NAT**
*   Microsoft Entra ID
*   Microsoft Entra ID Connect v2
*   PowerShell 5.1

---
## 1. Core On-Premises Infrastructure & Management

The first phase was to build a fully functional local area network from the ground up using Hyper-V.

### Active Directory & DNS

I deployed a domain controller (`DC01`) for the `corp.contoso.com` domain, which also serves as the authoritative DNS server for the internal network. I demonstrated DNS management by creating a manual A (Host) record for a fictional server.

![Initial On-Premises AD and DNS Setup](screenshot-00-ADUC-DC01-CLIENT01.png)
![Manual A Record in DNS Manager](screenshot-1-01-dns-record.png)

### DHCP Server & Network Routing

To provide automatic IP configuration for clients, I installed and configured the DHCP role on `DC01`. This included creating a scope, setting an IP address range, and configuring options for the default gateway and DNS server. To provide secure internet access to the lab, I also configured the Routing and Remote Access Service (RRAS) to function as a NAT router.

![CLIENT01 receiving a DHCP Lease](screenshot-1-02-dhcp-lease.png)

### Centralized Management with Group Policy (GPO)

To demonstrate centralized client management, I used Group Policy to automatically map a network drive for users in the "Sales" department. This involved configuring a file share, creating a new GPO, and linking it to the correct OU. I successfully troubleshooted a path typo to ensure the policy was applied correctly on the client machine.

![Mapped Network Drive and gpresult on Client](screenshot-1-03-gpo-mapped-drive.png)

---
## 2. Hybrid Identity Configuration

The second phase was to connect the established on-premises environment to the cloud.

### Custom Domain Verification

A critical prerequisite was to verify the on-premises domain namespace (`corp.contoso.com`) within Microsoft Entra ID to establish trust and ensure correct user principal name (UPN) mapping.

![Custom Domain Name Verification](screenshot1a-custom_domain_name_verification.PNG)

### User Synchronization to the Cloud

Using Microsoft Entra ID Connect, I configured the synchronization bridge. Key configurations included Password Hash Synchronization (PHS) and OU Filtering to ensure only designated user accounts were synced.

![Proof of Synced Users](screenshot-01-synced-users.png)

### End-to-End User Authentication Test

The ultimate test was to log in as a synced user (`Amelie Dubois`) to the Office 365 portal using her on-premises credentials, which validated the entire identity flow.

![Successful User Login to Office 365](screenshot-02-successful-login.png)

---
## 3. Automation and Technical Detail

### Automation of User Onboarding

To demonstrate efficiency, I wrote a PowerShell script to automate the creation of new user accounts in Active Directory. This script creates a user in the correct OU and initiates a sync cycle with Entra ID Connect.

![PowerShell ISE showing the script and successful output](screenshot-04-powershell-script.png)

*(The full script is available in the repository.)*

### Evidence of Technical Detail (Source Anchor)

To confirm the identity link, I inspected the user object's attributes in Active Directory. The presence of a value in the `msDS-ConsistencyGuid` attribute serves as the immutable "source anchor" linking the on-prem object to its cloud counterpart.

![ConsistencyGuid Attribute in Active Directory](screenshot-03-consistency-guid.png)

---
## Summary of Skills Demonstrated

This project showcases a wide range of critical skills required for modern IT administration roles:

*   **Full-Stack On-Premises Administration:** Deployed and managed the core trinity of network services: Active Directory for identity, DNS for name resolution, and DHCP for IP management.
*   **Network Infrastructure:** Configured a server to act as a router and NAT gateway, demonstrating a strong understanding of core networking principles.
*   **Centralized Client Management:** Utilized Group Policy Objects (GPO) to enforce settings and deploy resources to targeted users and computers.
*   **Systematic Troubleshooting:** Successfully diagnosed and resolved a GPO application failure by verifying network paths and permissions, a critical real-world administrative skill.
*   **Hybrid Cloud Integration:** Configured and maintained Microsoft Entra ID Connect to synchronize identities between an on-premises environment and the cloud.
*   **IT Automation:** Scripted user management tasks using PowerShell to improve efficiency and reduce manual error.
