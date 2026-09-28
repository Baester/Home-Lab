# File Server & Permissions

## Design

**FS01** is a Windows Server 2025 **member server** — deliberately not a second Domain Controller. It hosts one parent SMB share, `\\FS01\Shares`, containing three department folders:

```
C:\Shares
├── Finance
├── IT
└── Public
```

## Two permission layers

Windows evaluates two separate permission systems for any network folder access, and **the more restrictive of the two always wins**:

1. **Share (SMB) permissions** — set broad: `Authenticated Users: Full Control`. This layer is intentionally not where access is actually restricted.
2. **NTFS permissions** — set per-folder, using AD security groups:
   - `Finance` → `GG_FIN_USERS` (Modify)
   - `IT` → `GG_IT_USERS` (Modify)
   - `Public` → `Domain Users` (Read & Execute)

Keeping the share layer open and doing the real access control at the NTFS layer matches common real-world practice, since NTFS permissions are more granular (per-file/folder, more permission types) than share permissions.

## Validation

Access was tested directly from a domain-joined Windows 11 client, in both directions:

- A Finance-group user: **allowed** into `\\FS01\Shares\Finance`, **denied** on `\\FS01\Shares\IT`, allowed into `Public`
- An IT-group user: the reverse

A denial is not a failure state here — it's the actual proof the permission boundary works, not just that it was configured.

## A real audit finding

After initial setup, a PowerShell audit (`Get-Acl`) on all three folders turned up an inconsistency: `GG_FIN_USERS` and `GG_IT_USERS` were both present on **all three folders**, not just their own — meaning the department separation had silently drifted at some point after the manual click-through configuration.

**Root cause:** permissions had been edited on the parent `C:\Shares` folder at one point instead of the individual subfolders, so the department groups propagated to every child folder via inheritance before being frozen in as explicit entries when inheritance was later disabled on each subfolder.

**Fix:** each folder's permission list was corrected individually (removing the incorrect cross-department group, keeping only the intended one), then re-verified with `Get-Acl`, and the WIN11 access tests were re-run to confirm the corrected state actually enforced the intended separation.

This is included here deliberately — catching a real misconfiguration through auditing, rather than assuming a one-time manual setup stayed correct, is a more realistic and more valuable story than a clean first pass.
