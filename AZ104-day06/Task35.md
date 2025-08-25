# Task 35: Microsoft Entra ID and Role-Based Access Control (RBAC)

## Overview
Microsoft Entra ID (formerly Azure Active Directory) is Microsoft's cloud-based identity and access management service. It provides secure access to applications and resources while enabling comprehensive identity governance and access control through RBAC.

## What is Microsoft Entra ID?

Microsoft Entra ID is a comprehensive identity and access management solution that helps organizations:
- Manage user identities and access
- Secure applications and resources
- Enable single sign-on (SSO)
- Implement multi-factor authentication (MFA)
- Govern access through policies and controls

## Method 1: Using Azure Portal (GUI)

### Access Microsoft Entra ID via Portal

1. **Navigate to Microsoft Entra ID**
   - Go to Azure Portal → Search "Microsoft Entra ID"
   - Click on **Microsoft Entra ID** service
   - View the **Overview** dashboard

2. **Explore Entra ID Dashboard**
   - **Tenant information**: View tenant details
   - **Users**: Total user count
   - **Groups**: Security and Microsoft 365 groups
   - **Applications**: Registered applications
   - **Devices**: Managed devices count

### User Management via Portal

1. **Create New User**
   - Go to **Users** → **All users**
   - Click **New user** → **Create new user**
   - **User principal name**: `john.doe@yourdomain.com`
   - **Display name**: `John Doe`
   - **Password**: Auto-generate or set custom
   - **Groups**: Add to relevant groups
   - **Roles**: Assign directory roles
   - Click **Create**

2. **Bulk User Operations**
   - Click **Bulk operations**
   - **Bulk create**: Upload CSV with user details
   - **Bulk invite**: Send invitations to external users
   - **Bulk delete**: Remove multiple users
   - Download templates and follow format

3. **User Properties Configuration**
   - Select user → **Profile**
   - **Job info**: Title, department, manager
   - **Contact info**: Phone, address
   - **Settings**: Usage location, licenses
   - **Assigned roles**: Directory and application roles

### Group Management via Portal

1. **Create Security Group**
   - Go to **Groups** → **All groups**
   - Click **New group**
   - **Group type**: `Security`
   - **Group name**: `IT-Administrators`
   - **Group description**: `IT department administrators`
   - **Membership type**: 
     - `Assigned` - Manual membership
     - `Dynamic User` - Rule-based membership
     - `Dynamic Device` - Device-based membership
   - **Members**: Add users manually
   - Click **Create**

2. **Dynamic Group Rules**
   - For Dynamic User groups
   - **Rule syntax**: `user.department -eq "IT"`
   - **Advanced rule**: 
     ```
     (user.department -eq "IT") -and (user.jobTitle -contains "Manager")
     ```
   - **Validate rule**: Test with sample users

3. **Group-based Licensing**
   - Select group → **Licenses**
   - Click **Assignments**
   - Select **Microsoft 365** or **Azure AD Premium**
   - Configure license options
   - Click **Save**

### Application Registration via Portal

1. **Register New Application**
   - Go to **App registrations** → **New registration**
   - **Name**: `MyWebApp`
   - **Supported account types**:
     - `Single tenant` - This directory only
     - `Multi-tenant` - Any Azure AD directory
     - `Personal accounts` - Include consumer accounts
   - **Redirect URI**: `https://myapp.com/auth/callback`
   - Click **Register**

2. **Configure Application Settings**
   - **Authentication**: Configure redirect URIs, logout URLs
   - **Certificates & secrets**: Create client secrets or upload certificates
   - **API permissions**: Request permissions to Microsoft Graph or other APIs
   - **Expose an API**: Define scopes for your application
   - **App roles**: Create custom roles for the application

3. **Enterprise Applications**
   - Go to **Enterprise applications**
   - View all applications in your tenant
   - Configure **Single sign-on** settings
   - Manage **Users and groups** assignments
   - Configure **Conditional Access** policies

### Multi-Factor Authentication (MFA) via Portal

1. **Enable MFA for Users**
   - Go to **Users** → **Per-user MFA**
   - Select users and click **Enable**
   - **MFA status**:
     - `Disabled` - MFA not required
     - `Enabled` - MFA required on next sign-in
     - `Enforced` - MFA always required

2. **Configure MFA Settings**
   - Go to **Security** → **MFA**
   - **Account lockout**: Configure lockout thresholds
   - **Block/unblock users**: Manage blocked users
   - **Fraud alert**: Enable fraud reporting
   - **Notifications**: Configure admin notifications
   - **OATH tokens**: Manage hardware tokens

3. **Authentication Methods**
   - **Phone call**: Voice call verification
   - **Text message**: SMS verification
   - **Mobile app notification**: Microsoft Authenticator push
   - **Mobile app verification code**: TOTP codes
   - **Hardware tokens**: OATH hardware tokens

### Conditional Access via Portal

1. **Create Conditional Access Policy**
   - Go to **Security** → **Conditional Access**
   - Click **New policy**
   - **Name**: `Require MFA for Admins`
   - **Assignments**:
     - **Users**: Include admin roles
     - **Cloud apps**: All cloud apps
     - **Conditions**: Configure location, device, risk
   - **Access controls**:
     - **Grant**: Require MFA
     - **Session**: Configure session controls
   - **Enable policy**: Report-only or On
   - Click **Create**

2. **Common Policy Templates**
   - **Require MFA for administrators**
   - **Block legacy authentication**
   - **Require compliant devices**
   - **Require approved client apps**
   - **Sign-in risk-based policies**

### Identity Protection via Portal

1. **Configure Risk Policies**
   - Go to **Security** → **Identity Protection**
   - **User risk policy**: Configure for compromised accounts
   - **Sign-in risk policy**: Configure for risky sign-ins
   - **MFA registration policy**: Require MFA registration

2. **Risk Detections**
   - **Risky users**: Users flagged as compromised
   - **Risky sign-ins**: Suspicious sign-in attempts
   - **Risk detections**: Detailed risk events
   - **Vulnerabilities**: Security recommendations

## Role-Based Access Control (RBAC)

### Understanding RBAC Components

1. **Security Principal**
   - **User**: Individual person
   - **Group**: Collection of users
   - **Service Principal**: Application identity
   - **Managed Identity**: Azure-managed identity

2. **Role Definition**
   - **Actions**: Allowed operations
   - **NotActions**: Explicitly denied operations
   - **DataActions**: Data plane operations
   - **NotDataActions**: Denied data operations

3. **Scope**
   - **Management Group**: Multiple subscriptions
   - **Subscription**: Single subscription
   - **Resource Group**: Group of resources
   - **Resource**: Individual resource

### Built-in Azure Roles via Portal

1. **Common Built-in Roles**
   - **Owner**: Full access including access management
   - **Contributor**: Full access except access management
   - **Reader**: Read-only access
   - **User Access Administrator**: Manage user access only

2. **Service-Specific Roles**
   - **Virtual Machine Contributor**: Manage VMs
   - **Storage Account Contributor**: Manage storage accounts
   - **Network Contributor**: Manage network resources
   - **SQL DB Contributor**: Manage SQL databases

3. **View Role Definitions**
   - Go to **Subscriptions** → Select subscription
   - Click **Access control (IAM)** → **Roles**
   - Search and view role permissions
   - **JSON view**: See detailed permissions

### Assign RBAC Roles via Portal

1. **Subscription Level Assignment**
   - Go to **Subscriptions** → Select subscription
   - Click **Access control (IAM)**
   - Click **Add** → **Add role assignment**
   - **Role**: Select `Contributor`
   - **Assign access to**: User, group, or service principal
   - **Select**: Choose `john.doe@domain.com`
   - Click **Save**

2. **Resource Group Assignment**
   - Navigate to resource group
   - Click **Access control (IAM)**
   - **Add role assignment**:
     - **Role**: `Virtual Machine Contributor`
     - **Members**: `IT-Administrators` group
   - Click **Review + assign**

3. **Resource Level Assignment**
   - Navigate to specific resource (VM, Storage Account)
   - Click **Access control (IAM)**
   - Assign granular permissions
   - **Principle of least privilege**: Minimum required access

### Custom RBAC Roles via Portal

1. **Create Custom Role**
   - Go to **Subscriptions** → **Access control (IAM)**
   - Click **Add** → **Add custom role**
   - **Basics**:
     - **Custom role name**: `VM Operator`
     - **Description**: `Can start/stop VMs but not create/delete`
   - **Permissions**:
     - **Add permissions** → Search `Microsoft.Compute`
     - Select specific actions:
       - `Microsoft.Compute/virtualMachines/start/action`
       - `Microsoft.Compute/virtualMachines/restart/action`
       - `Microsoft.Compute/virtualMachines/deallocate/action`
   - **Assignable scopes**: Select subscription/resource groups
   - Click **Create**

2. **JSON Definition Example**
   ```json
   {
     "Name": "VM Operator",
     "Description": "Can start and stop VMs",
     "Actions": [
       "Microsoft.Compute/virtualMachines/start/action",
       "Microsoft.Compute/virtualMachines/restart/action",
       "Microsoft.Compute/virtualMachines/deallocate/action",
       "Microsoft.Compute/virtualMachines/read"
     ],
     "NotActions": [],
     "AssignableScopes": [
       "/subscriptions/{subscription-id}"
     ]
   }
   ```

### Privileged Identity Management (PIM) via Portal

1. **Enable PIM**
   - Go to **Azure AD Privileged Identity Management**
   - **Azure AD roles**: Manage directory roles
   - **Azure resources**: Manage subscription roles
   - Click **Consent to PIM**

2. **Configure Eligible Assignments**
   - **Azure AD roles** → **Roles**
   - Select role (e.g., `Global Administrator`)
   - Click **Add assignments**
   - **Assignment type**: `Eligible`
   - **Members**: Select users
   - **Settings**: Configure activation requirements
     - **Activation duration**: Maximum 8 hours
     - **Require approval**: Enable approval workflow
     - **Require MFA**: Require MFA for activation
     - **Require justification**: Business justification required

3. **Role Activation Process**
   - User goes to **My roles**
   - Click **Activate** on eligible role
   - Provide justification
   - Complete MFA if required
   - Wait for approval if configured
   - Role activated for specified duration

### Access Reviews via Portal

1. **Create Access Review**
   - Go to **Identity Governance** → **Access reviews**
   - Click **New access review**
   - **Review type**: 
     - `Teams + Groups` - Review group memberships
     - `Applications` - Review app assignments
     - `Azure AD roles` - Review role assignments
   - **Scope**: Select specific groups/roles
   - **Reviewers**: 
     - `Group owners` - Automatic delegation
     - `Selected users` - Specific reviewers
     - `Members review themselves` - Self-review
   - **Recurrence**: One-time, weekly, monthly, quarterly
   - Click **Create**

2. **Review Process**
   - Reviewers receive email notifications
   - **Review decisions**:
     - `Approve` - Maintain access
     - `Deny` - Remove access
     - `Don't know` - No decision
   - **Bulk decisions**: Apply to multiple users
   - **Auto-apply results**: Automatic enforcement

## Method 2: Using PowerShell and CLI

### User Management
```powershell
# Connect to Azure AD
Connect-AzureAD

# Create new user
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "TempPassword123!"
$PasswordProfile.ForceChangePasswordNextLogin = $true

New-AzureADUser -DisplayName "John Doe" -UserPrincipalName "john.doe@domain.com" -AccountEnabled $true -PasswordProfile $PasswordProfile -MailNickName "johndoe"

# Get user information
Get-AzureADUser -Filter "DisplayName eq 'John Doe'"

# Add user to group
$user = Get-AzureADUser -Filter "DisplayName eq 'John Doe'"
$group = Get-AzureADGroup -Filter "DisplayName eq 'IT-Administrators'"
Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $user.ObjectId
```

### Group Management
```powershell
# Create security group
New-AzureADGroup -DisplayName "IT-Administrators" -MailEnabled $false -SecurityEnabled $true -MailNickName "ITAdmins"

# Create dynamic group
$dynamicRule = "user.department -eq `"IT`""
New-AzureADGroup -DisplayName "IT-Dynamic" -GroupTypes "DynamicMembership" -MembershipRule $dynamicRule -MembershipRuleProcessingState "On" -MailEnabled $false -SecurityEnabled $true -MailNickName "ITDynamic"
```

### RBAC Role Assignments
```powershell
# Connect to Azure
Connect-AzAccount

# Assign role at subscription level
New-AzRoleAssignment -SignInName "john.doe@domain.com" -RoleDefinitionName "Contributor" -Scope "/subscriptions/{subscription-id}"

# Assign role at resource group level
New-AzRoleAssignment -SignInName "john.doe@domain.com" -RoleDefinitionName "Virtual Machine Contributor" -ResourceGroupName "rg-production"

# Get role assignments
Get-AzRoleAssignment -SignInName "john.doe@domain.com"

# Remove role assignment
Remove-AzRoleAssignment -SignInName "john.doe@domain.com" -RoleDefinitionName "Contributor" -Scope "/subscriptions/{subscription-id}"
```

### Custom Role Creation
```powershell
# Create custom role definition
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "VM Operator"
$role.Description = "Can start and stop VMs"
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/deallocate/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/read")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/{subscription-id}")

New-AzRoleDefinition -Role $role
```

### Azure CLI Commands
```bash
# Create user
az ad user create --display-name "John Doe" --password "TempPassword123!" --user-principal-name "john.doe@domain.com" --force-change-password-next-login true

# Create group
az ad group create --display-name "IT-Administrators" --mail-nickname "ITAdmins"

# Add user to group
az ad group member add --group "IT-Administrators" --member-id $(az ad user show --id "john.doe@domain.com" --query objectId -o tsv)

# Assign RBAC role
az role assignment create --assignee "john.doe@domain.com" --role "Contributor" --scope "/subscriptions/{subscription-id}"

# Create custom role
az role definition create --role-definition '{
  "Name": "VM Operator",
  "Description": "Can start and stop VMs",
  "Actions": [
    "Microsoft.Compute/virtualMachines/start/action",
    "Microsoft.Compute/virtualMachines/restart/action",
    "Microsoft.Compute/virtualMachines/deallocate/action",
    "Microsoft.Compute/virtualMachines/read"
  ],
  "AssignableScopes": ["/subscriptions/{subscription-id}"]
}'
```

## Management Groups

### What are Management Groups?

Management Groups provide a governance layer above subscriptions to efficiently manage access, policies, and compliance across multiple Azure subscriptions.

### Management Group Hierarchy

```
Root Management Group
├── Production Management Group
│   ├── Prod-Subscription-1
│   └── Prod-Subscription-2
├── Development Management Group
│   ├── Dev-Subscription-1
│   └── Dev-Subscription-2
└── Sandbox Management Group
    └── Sandbox-Subscription
```

### Create Management Groups via Portal

1. **Navigate to Management Groups**
   - Go to Azure Portal → Search "Management groups"
   - Click **Management groups**
   - View existing hierarchy

2. **Create New Management Group**
   - Click **Create**
   - **Management group ID**: `mg-production`
   - **Management group display name**: `Production Environment`
   - **Parent management group**: Select parent or root
   - Click **Submit**

3. **Move Subscriptions**
   - Select subscription to move
   - Click **Change parent**
   - Select target management group
   - Click **Save**

### Management Group RBAC

```powershell
# Assign role at management group level
New-AzRoleAssignment -SignInName "admin@domain.com" -RoleDefinitionName "Owner" -Scope "/providers/Microsoft.Management/managementGroups/mg-production"

# Create custom role for management group
$role = New-Object Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition
$role.Name = "Management Group Reader"
$role.Description = "Can read management group resources"
$role.Actions = @("Microsoft.Management/managementGroups/read")
$role.AssignableScopes = @("/providers/Microsoft.Management/managementGroups/mg-production")
New-AzRoleDefinition -Role $role
```

### Azure Policy at Management Group Level

1. **Create Policy Assignment**
   - Go to **Policy** → **Assignments**
   - Click **Assign policy**
   - **Scope**: Select management group
   - **Policy definition**: Choose built-in or custom policy
   - **Assignment name**: `Require tags on resources`
   - Click **Assign**

2. **Policy Inheritance**
   - Policies assigned to management groups inherit to child subscriptions
   - Lower-level assignments can add restrictions but not remove them
   - Use exclusions for specific resources if needed

## Microsoft Entra ID Licensing

### Licensing Tiers

#### Microsoft Entra ID Free
**Included with Azure subscription**
- Up to 500,000 directory objects
- User and group management
- Basic reports
- Self-service password change
- Single sign-on to Azure, Microsoft 365, and SaaS apps
- Device registration

#### Microsoft Entra ID P1
**$6/user/month**
- All Free features plus:
- Self-service password reset
- Group-based licensing
- Conditional Access
- Advanced security reports
- Multi-factor authentication
- Hybrid identities (Azure AD Connect)
- Dynamic groups
- Self-service group management

#### Microsoft Entra ID P2
**$9/user/month**
- All P1 features plus:
- Identity Protection (risk-based policies)
- Privileged Identity Management (PIM)
- Access Reviews
- Entitlement Management
- Identity Governance

#### Microsoft Entra ID Governance
**$7/user/month (add-on)**
- Advanced Identity Governance features
- Lifecycle Workflows
- Advanced Access Reviews
- Entitlement Management

### License Assignment via Portal

1. **Assign Licenses to Users**
   - Go to **Users** → Select user
   - Click **Licenses**
   - Click **Assignments**
   - Select **Microsoft Entra ID Premium P1**
   - Configure license options:
     - **Azure Multi-Factor Authentication**: Enable
     - **Azure Active Directory Premium P1**: Enable
   - Click **Save**

2. **Group-Based Licensing**
   - Go to **Groups** → Select group
   - Click **Licenses**
   - Click **Assignments**
   - Select license products
   - Configure options for all group members
   - Click **Save**

3. **License Usage Monitoring**
   - Go to **Licenses** → **All products**
   - View license consumption:
     - **Total licenses**: Purchased quantity
     - **Assigned**: Currently assigned
     - **Available**: Remaining licenses
   - **Users with errors**: License assignment issues

### PowerShell License Management

```powershell
# Connect to Azure AD
Connect-AzureAD

# Get available license SKUs
Get-AzureADSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits, PrepaidUnits

# Assign license to user
$user = Get-AzureADUser -ObjectId "john.doe@domain.com"
$license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$license.SkuId = "AAD_PREMIUM_P2"  # P2 license SKU
$licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licensesToAssign.AddLicenses = $license
Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign

# Remove license from user
$licensesToRemove = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licensesToRemove.RemoveLicenses = "AAD_PREMIUM_P2"
Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToRemove
```

### License Requirements by Feature

| Feature | Free | P1 | P2 | Governance |
|---------|------|----|----|------------|
| Basic SSO | ✓ | ✓ | ✓ | ✓ |
| Self-service password reset | | ✓ | ✓ | ✓ |
| Conditional Access | | ✓ | ✓ | ✓ |
| MFA | | ✓ | ✓ | ✓ |
| Dynamic Groups | | ✓ | ✓ | ✓ |
| Identity Protection | | | ✓ | ✓ |
| PIM | | | ✓ | ✓ |
| Access Reviews | | | ✓ | ✓ |
| Entitlement Management | | | | ✓ |
| Lifecycle Workflows | | | | ✓ |

### License Optimization Strategies

1. **Right-sizing Licenses**
   - Audit user requirements
   - Use Free tier for basic users
   - P1 for standard business users
   - P2 for privileged users only

2. **Group-Based Assignment**
   - Automate license assignment
   - Reduce administrative overhead
   - Ensure consistent licensing

3. **Regular License Reviews**
   - Monitor unused licenses
   - Remove licenses from inactive users
   - Optimize license distribution

## Advanced Entra ID Features

### Identity Governance
- **Entitlement Management**: Manage access packages
- **Access Reviews**: Periodic access certification
- **Terms of Use**: Legal agreements for access
- **Privileged Identity Management**: Just-in-time access

### Security Features
- **Conditional Access**: Policy-based access control
- **Identity Protection**: Risk-based policies
- **Security Defaults**: Basic security baseline
- **Password Protection**: Custom banned passwords

### Integration Capabilities
- **SAML/OAuth/OpenID Connect**: Standard protocols
- **SCIM**: Automated provisioning
- **LDAP**: Legacy application integration
- **Federation**: Trust relationships with other directories

## Best Practices

### Security Best Practices
1. **Enable MFA** for all users, especially administrators
2. **Use Conditional Access** policies for risk-based access
3. **Implement PIM** for privileged roles
4. **Regular access reviews** to maintain least privilege
5. **Monitor sign-in logs** for suspicious activities

### RBAC Best Practices
1. **Principle of least privilege**: Minimum required access
2. **Use groups** instead of individual assignments
3. **Custom roles** for specific business needs
4. **Regular role reviews** and cleanup
5. **Document role assignments** and business justification

### Operational Best Practices
1. **Naming conventions** for users, groups, and applications
2. **Lifecycle management** for user accounts
3. **Automated provisioning** where possible
4. **Regular security assessments** and audits
5. **Disaster recovery** planning for identity services

## Monitoring and Reporting

### Sign-in Logs
- **Interactive sign-ins**: User authentication events
- **Non-interactive sign-ins**: Service principal authentications
- **Service principal sign-ins**: Application authentications

### Audit Logs
- **Directory activities**: User/group changes
- **Application activities**: App registrations and changes
- **Policy activities**: Conditional Access policy changes

### Security Reports
- **Risky users**: Users flagged by Identity Protection
- **Risky sign-ins**: Suspicious authentication attempts
- **Vulnerabilities**: Security recommendations

## Troubleshooting Common Issues

### Authentication Issues
1. **Password problems**: Reset passwords, check policies
2. **MFA issues**: Verify phone numbers, reset MFA
3. **Conditional Access blocks**: Review policy conditions
4. **Application access**: Check app assignments and permissions

### RBAC Issues
1. **Permission denied**: Verify role assignments and scope
2. **Role not appearing**: Check role definition and assignable scopes
3. **Group membership**: Verify dynamic group rules
4. **PIM activation**: Check approval requirements and MFA

### Integration Issues
1. **SAML configuration**: Verify certificates and URLs
2. **Provisioning failures**: Check SCIM endpoint and mappings
3. **Federation issues**: Verify trust relationships
4. **API permissions**: Check consent and admin approval

## Conclusion

Microsoft Entra ID provides comprehensive identity and access management capabilities that enable organizations to:
- Secure access to applications and resources
- Implement zero-trust security models
- Automate identity lifecycle management
- Ensure compliance with regulatory requirements
- Enable modern authentication and authorization

Combined with RBAC, organizations can implement fine-grained access control that follows the principle of least privilege while maintaining operational efficiency and security.

---

*This task provides comprehensive coverage of Microsoft Entra ID and RBAC implementation for enterprise identity and access management.*