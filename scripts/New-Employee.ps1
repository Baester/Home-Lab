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
    [ValidateSet("Finance","IT","HR")]
    [string]$Department
)

# Build the username: first initial + last name (Jane Smith -> jsmith)
$SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
$FullName = "$FirstName $LastName"
$UPN = "$SamAccountName@lab.internal"

# Stop if the username already exists, so we never modify the wrong account
if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'") {
    Write-Error "User '$SamAccountName' already exists. No changes were made."
    return
}

# Map the department to its AD security group
switch ($Department) {
    "Finance" { $GroupName = "GG_FIN_USERS" }
    "IT"      { $GroupName = "GG_IT_USERS" }
    "HR"      { $GroupName = "GG_HR_USERS" }
}

# Build a random 14-character temporary password with at least one of each character type
$upper  = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
$lower  = 'abcdefghijkmnopqrstuvwxyz'
$digit  = '23456789'
$symbol = '!@#$%*?'
$all    = $upper + $lower + $digit + $symbol
$chars  = @(
    $upper[(Get-Random -Maximum $upper.Length)]
    $lower[(Get-Random -Maximum $lower.Length)]
    $digit[(Get-Random -Maximum $digit.Length)]
    $symbol[(Get-Random -Maximum $symbol.Length)]
) + (1..10 | ForEach-Object { $all[(Get-Random -Maximum $all.Length)] })
$TempPassword = -join ($chars | Sort-Object { Get-Random })

try {
    New-ADUser -Name $FullName `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $SamAccountName `
        -UserPrincipalName $UPN `
        -Path "OU=Employee Users,DC=lab,DC=internal" `
        -AccountPassword (ConvertTo-SecureString $TempPassword -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -ErrorAction Stop
}
catch {
    Write-Error "Could not create '$SamAccountName': $($_.Exception.Message)"
    return
}

try {
    Add-ADGroupMember -Identity $GroupName -Members $SamAccountName -ErrorAction Stop
}
catch {
    Write-Warning "User '$SamAccountName' was created but NOT added to $GroupName. Add the group manually."
    return
}

Write-Host "Created '$SamAccountName' in $Department and added to $GroupName. Temp password: $TempPassword"
