# PowerShell Automation

## Why

Manually creating an AD user and assigning department group membership through ADUC works, but doesn't scale, and isn't how a real IT department handles routine onboarding. [`New-Employee.ps1`](../scripts/New-Employee.ps1) automates both steps into a single, reusable, parameterized script.

## What it does

```powershell
.\New-Employee.ps1 -FirstName "Jane" -LastName "Smith" -Department "IT"
```

Given a first name, last name, and department, the script:

1. Auto-generates a username (first initial + last name, lowercased — e.g. `jsmith`)
2. Maps the human-readable department name to the correct AD security group (`Finance` → `GG_FIN_USERS`, `IT` → `GG_IT_USERS`)
3. Generates a random temporary password
4. Creates the AD user account in the `Employee Users` OU, with `ChangePasswordAtLogon` enforced
5. Adds the new account to the correct department security group
6. Prints a confirmation with the generated username and temporary password

## Design choices worth calling out

- **`[ValidateSet("Finance","IT")]`** on the `-Department` parameter rejects an invalid department name before the script ever touches Active Directory, rather than failing partway through or silently creating a misconfigured account.
- **`Mandatory=$true`** on every parameter means the script cannot run with missing information — no silent defaults masking an incomplete command.
- **A freshly generated password per run** (`Get-Random`), rather than a fixed default, avoids the real-world anti-pattern of every new hire sharing the same known temporary password.

## Getting there: real debugging along the way

Before the script reached this working, parameterized state, several genuine errors were worked through by hand:

- A copy-paste corruption dropped a hyphen from `-SamAccountName`, producing `New-ADUser : A positional parameter cannot be found that accepts argument 'SamAccountName'`
- `-ChangePasswordAtLogon` was once left with no value at all (`Missing an argument for parameter`), from a command getting cut off mid-paste
- `-Path "OU=Users,DC=lab,DC=internal"` failed with `Directory object not found` — because the real OU is named **"Employee Users,"** not the default "Users" container. The typo `DistinguisehdName` also silently produced empty `{}` results in an earlier `Select` statement, since PowerShell doesn't error on a misspelled property name in `Select` — it just creates an empty column.

Each of these is included because they're realistic mistakes, not scripted demo failures — and each one has a concrete, reusable lesson attached to it.

## Verified output

```
PS C:\Scripts> .\New-Employee.ps1 -FirstName "Jane" -LastName "Smith" -Department "IT"
Created user 'jsmith' in IT, added to GG_IT_USERS. Temp password: Welcome2525!
```

Verified independently afterward with `Get-ADUser -Identity jsmith` and `Get-ADGroupMember -Identity "GG_IT_USERS"` — both confirmed the account and group membership were created correctly.

## Possible extensions

- Accept a CSV of multiple new hires instead of one at a time
- Automatically create the user's personal folder on FS01 with matching NTFS permissions in the same run
- Email the generated credentials directly to a manager instead of printing them to the console

See [`/screenshots/07-powershell-automation`](../screenshots/07-powershell-automation/) for the full error-to-success sequence, including the final parameterized run.
