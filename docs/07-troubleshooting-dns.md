# Troubleshooting: DNS Resolution Issues on DC01

A sequence of DNS-related errors worked through directly on DC01, each one a distinct problem rather than a repeat of the same mistake.

## Issue 1: Permission-denied querying DNS records

**Problem:** `Get-DnsServerResourceRecord -ZoneName "lab.internal" -RRType "A"` failed with a `PermissionDenied` / `CimException` error, even when run twice.

**Fix:** re-run from an elevated (Administrator) PowerShell session. The DNS Server PowerShell module requires administrative rights to query zone data via CIM/WMI, even for read-only lookups — a non-elevated prompt fails silently into a permissions error rather than an obviously-labeled "run as administrator" message.

**Result:** the same command succeeded afterward, returning the zone's real A records (`@`, `DomainDnsZones`, `ForestDnsZones`, the DC's own hostname record, and a workstation lease).

## Issue 2: Resolve-DnsName failing for the DC's own hostname

**Problem:** `Resolve-DnsName WIN-0L606TK3UHE.lab.internal -Server 127.0.0.1` returned **"DNS name does not exist"** — twice, with slightly different casing on the `-Server` flag, same result both times.

**Diagnosis:** the hostname had been typed manually and didn't exactly match the DC's actual computer name.

**Fix:** used the built-in environment variable instead of retyping the name:
```powershell
$env:computername
Resolve-DnsName "$env:COMPUTERNAME.lab.internal" -Server 127.0.0.1
```
This succeeded, returning both AAAA and A records correctly.

## Issue 3: Manually verifying the domain controller's SRV record

To confirm Active Directory's service-location mechanism was working (not just basic name resolution), the DC locator SRV record was queried directly:

```powershell
nslookup -type=SRV _ldap._tcp.dc.msdcs.lab.internal 127.0.0.1
```
This failed as **non-existent domain** — the query was missing an underscore before `msdcs`. Corrected to:
```powershell
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.internal 127.0.0.1
```
This returned the real SRV record, correctly pointing to DC01 as the LDAP service location.

## Lessons learned

- A permission error from a DNS cmdlet doesn't always look like a permission error — checking whether the session is elevated is worth doing before assuming DNS itself is broken.
- Manually typing a hostname is a common source of typos; `$env:computername` (or `hostname`) removes that risk entirely.
- AD's DC-locator SRV record naming convention (`_service._protocol.dc._msdcs.<domain>`) is exact and easy to get slightly wrong — this is the actual mechanism domain-joined clients use to find a domain controller, so being able to query it manually is a genuinely useful diagnostic skill, not just trivia.

See [`/screenshots/03-dns-ad-troubleshooting`](../screenshots/03-dns-ad-troubleshooting/) for the full sequence.
