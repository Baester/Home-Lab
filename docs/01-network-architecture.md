# Network Architecture

## The problem this solves

The Proxmox host has only one physical Ethernet connection, so all network segmentation has to happen virtually rather than with separate physical NICs — the same constraint many real hypervisor deployments face.

## Design

Two Linux bridges are configured in Proxmox:

- **`vmbr0`** — external/WAN-facing. pfSense's WAN interface connects here.
- **`vmbr1`** — isolated internal LAN (`10.10.10.0/24`). pfSense's LAN interface connects here, along with every internal VM (DC01, FS01, WIN11).

Internal machines are never connected directly to `vmbr0`. This isn't just a naming convention — it's the actual security boundary: a misconfiguration on the external side can't directly reach internal infrastructure, because there's no network path between `vmbr0` and internal VMs except through pfSense.

pfSense sits in the middle as the router/firewall, with:

- **WAN:** `vmbr0`
- **LAN:** `10.10.10.1` (the internal default gateway) on `vmbr1`

## DNS design

Domain-joined machines use **DC01 (`10.10.10.10`)** as their DNS server — not a public DNS server. This is a deliberate choice, not an oversight: Active Directory relies on DNS SRV records to locate domain controllers and services. A client pointed at public DNS would never be able to find `lab.internal` resources. DC01 forwards to external DNS as needed for general internet resolution.

## IP addressing

| Device | IP | Role |
|---|---|---|
| pfSense LAN | 10.10.10.1 | Gateway |
| DC01 | 10.10.10.10 | Domain Controller / DNS |
| FS01 | 10.10.10.20 | File Server |
| WIN11 | DHCP (pool: 10.10.10.100–200) | Domain client |

Servers are given static addresses deliberately — DNS records, Group Policy, and file share paths all depend on a server's address never silently changing, which a DHCP lease could otherwise do. The DHCP pool range itself was checked directly in pfSense (Services → DHCP Server) before choosing FS01's static address, to guarantee no future conflict.

See [`/screenshots/01-network-architecture`](../screenshots/01-network-architecture/) for the pfSense DHCP pool configuration and the successful static-IP ping/nslookup validation.
