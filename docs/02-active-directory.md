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

**A lesson from testing, not just theory:** while working through group membership testing, one of the test accounts (Michael Smith) was found to be a member of **Domain Admins** rather than a standard department group. This wasn't intentional design — it's a realistic mistake that happens when test accounts get created quickly, and it's exactly the kind of thing a periodic AD audit (see the PowerShell automation doc) is meant to catch. Left uncorrected, it would violate least-privilege practice.

See [`/screenshots/02-active-directory-structure`](../screenshots/02-active-directory-structure/) for the OU structure, and [`/screenshots/08-lessons-learned`](../screenshots/08-lessons-learned/) for the Domain Admins membership finding.
