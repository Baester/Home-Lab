# Active Directory Design

## Domain

`lab.internal`, hosted on **DC01** (Windows Server 2025), providing both AD DS and DNS.

## OU structure

Rather than leaving everything in AD's default containers, accounts and computers are organized into a role-based OU structure:

- Servers
- Workstations
- Employee Users
- Groups
- Service Accounts
- Domain Controllers

This matters beyond organization: Group Policy and delegated permissions apply at the OU level, so a flat structure would make future policy application unnecessarily broad or impossible to scope correctly.

## Security groups

Groups follow a `GG_` prefix naming convention (Global Group), department-based:

- `GG_FIN_USERS`
- `GG_IT_USERS`
- `GG_HR_USERS`
- `GG_MGMT_USERS`
- `GG_SALES_USERS`

Access to resources (file shares, and eventually Group Policy-based drive mappings) is granted to these groups — never to individual users directly. This is the standard enterprise pattern: adding or removing someone's access becomes a group-membership change, not a per-resource permission edit repeated across every server.

## Administrative access

A dedicated administrative account is used for domain administration, separate from any personal/standard account — least-privilege practice, so day-to-day activity isn't performed from an account with domain-wide rights.
