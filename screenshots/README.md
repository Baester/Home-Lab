# Screenshots

30 screenshots, organized by topic. Each folder is referenced directly from the matching doc in `/docs`.

- **01-network-architecture/** — pfSense DHCP pool configuration; successful static-IP ping/nslookup from FS01. Supports [docs/01-network-architecture.md](../docs/01-network-architecture.md).
- **02-active-directory-structure/** — the full custom OU structure in ADUC. Supports [docs/02-active-directory.md](../docs/02-active-directory.md).
- **03-dns-ad-troubleshooting/** — the DNS permission error → success, and Resolve-DnsName failure → `$env:computername` fix → SRV record verification sequence. Supports [docs/07-troubleshooting-dns.md](../docs/07-troubleshooting-dns.md).
- **04-kerberos/** — `klist` output showing the TGT and an LDAP service ticket.
- **05-fs01-build/** — VM creation, the wrong-ISO catch and correction, the .NET 3.5 source-path warning, and the diskpart partition list. Supports [docs/05-troubleshooting-fs01-build.md](../docs/05-troubleshooting-fs01-build.md).
- **06-file-server-permissions/** — the full permission story: baseline inherited permissions, the WIN11 search-box mixup, the first Get-Acl/Get-SmbShare check, the cross-contamination discovered on IT and Finance, the parent-folder root cause, and the corrected final state. Supports [docs/03-file-server-permissions.md](../docs/03-file-server-permissions.md).
- **07-powershell-automation/** — the New-ADUser error chain (positional parameter, OU path, typo) through the first successful run, then the final parameterized script execution. Supports [docs/06-powershell-automation.md](../docs/06-powershell-automation.md).
- **08-lessons-learned/** — the populated Employee Users OU and Michael Smith's Domain Admins membership finding. Supports the "lessons learned" note in [docs/02-active-directory.md](../docs/02-active-directory.md).
