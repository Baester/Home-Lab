# Troubleshooting: Proxmox Management Interface Outage

## Problem

After rebooting the Proxmox host, the web management GUI (`https://<host-IP>:8006`) became unreachable.

## Environment

Proxmox VE, single physical NIC, two virtual bridges (`vmbr0` external, `vmbr1` internal), pfSense routing between them.

## Initial hypothesis

pfSense was suspected first — a misconfigured mapping between pfSense's WAN/LAN interfaces and Proxmox's own bridges seemed like a plausible cause for a network-level conflict.

## Testing the hypothesis

Rather than assume, the hypothesis was tested directly: the pfSense VM was removed entirely via the physical console (`qm destroy`), and the Proxmox GUI was checked again.

**Result:** the GUI was still unreachable with pfSense completely gone. This ruled pfSense out as the cause — if it had been a pfSense firewall rule, removing pfSense entirely would have had no further effect on GUI reachability one way or the other, but it confirmed the problem lived at a different layer entirely.

## Root cause

With pfSense eliminated, attention shifted to the host's own networking. Investigation from the physical console found that **`vmbr0` — Proxmox's own bridge — had lost its static IP configuration**, most likely from an accidental change made while investigating the (incorrect) pfSense theory. Without a valid IP on that bridge, the Proxmox host itself had no reachable address for its management interface.

## Fix

The static IP was re-applied to `vmbr0` directly from the Linux shell on the physical console, and networking was restarted.

## Validation

The Proxmox web GUI became reachable again at `https://<host-IP>:8006`.

## Lessons learned

- Test one variable at a time rather than guessing — eliminating pfSense entirely, rather than partially adjusting it, gave an unambiguous answer.
- A management-interface outage doesn't mean the whole hypervisor or every VM has failed — the web GUI, the API daemon, and the underlying host networking are separate components that can fail independently.
- Diagnosing at the correct layer (host networking vs. firewall rule vs. VM state) matters more than the specific fix once you're looking in the right place.
