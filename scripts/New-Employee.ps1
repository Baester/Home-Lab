<#
.SYNOPSIS
    Provisions a new Active Directory employee account and assigns department-based group access.

.DESCRIPTION
    Creates a new AD user under the Employee Users OU, auto-generates a username and a
    temporary password, and adds the account to the correct department security group.

.PARAMETER FirstName
    The new employee's first name.

.PARAMETER LastName
    The new employee's last name.

.PARAMETER Department
    The employee's department. Must be "Finance" or "IT".

.EXAMPLE
    .\New-Employee.ps1 -FirstName "Jane" -LastName "Smith" -Department "IT"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FirstName,

    [Parameter(Mandatory=$true)]
    [string]$LastName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Finance","IT")]
    [string]$Department
)

# Build the username automatically: first initial + last name (e.g. Jane Smith -> jsmith)
$SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
$FullName = "$FirstName $LastName"
$UPN = "$SamAccountName@lab.internal"

# Map the chosen department to the correct AD security group
switch ($Department) {
    "Finance" { $GroupName = "GG_FIN_USERS" }
    "IT"      { $GroupName = "GG_IT_USERS" }
}

# Generate a random temporary password rather than reusing a fixed default
$TempPassword = "Welcome" + (Get-Random -Minimum 1000 -Maximum 9999) + "!"

New-ADUser -Name $FullName `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $SamAccountName `
    -UserPrincipalName $UPN `
    -Path "OU=Employee Users,DC=lab,DC=internal" `
    -AccountPassword (ConvertTo-SecureString $TempPassword -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true

Add-ADGroupMember -Identity $GroupName -Members $SamAccountName

Write-Host "Created user '$SamAccountName' in $Department, added to $GroupName. Temp password: $TempPassword"
