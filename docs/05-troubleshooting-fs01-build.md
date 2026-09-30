# Troubleshooting: FS01 Build Issues

Two separate problems encountered while building the FS01 file server, from installation through role setup.

## Issue 1: Missing storage driver during Windows Server installation

**Problem:** during Windows Server 2025 setup, the disk selection screen showed no available disks at all.

**Cause:** the VM's SCSI controller was configured as **VirtIO SCSI single** — a high-performance paravirtualized driver that Windows does not natively recognize during installation, unlike the standard emulated controllers.

**Fix:** the VirtIO driver ISO (mounted as a second virtual CD/DVD device alongside the Windows installer) was loaded manually during setup via the "Load driver" option, pointing to the appropriate driver folder on that ISO. The disk then appeared and installation proceeded normally.

## Issue 2: Disk-space failure installing the File Server role

**Problem:** installing the File Server role failed, citing insufficient disk space — the original 20 GB virtual disk had only ~11 MB free after the base OS and additional features (including a required .NET Framework 3.5 dependency, which prompted its own alternate-source-path warning since the lab has no internet access to fetch it from Windows Update).

**Diagnosis and fix:**
1. The virtual disk was resized in Proxmox from 20 GB to 30 GB.
2. Resizing the virtual disk alone doesn't extend the Windows partition — Windows still saw the original partition size, with the new space sitting unallocated.
3. Windows' Disk Management only offered "Shrink," not "Extend," because a **Recovery partition** sat at the end of the disk, blocking the new unallocated space from being contiguous with C:.
4. Using `diskpart`, the Recovery partition was deleted (`select partition`, `delete partition override`), and the C: volume was extended into the newly contiguous space (`select volume C`, `extend`).

**Result:** the File Server role installed successfully afterward.

## Lessons learned

- A driver-not-found problem and a "no disks available" problem can look identical at first glance — the fix here required understanding *why* Windows couldn't see the disk, not just retrying the install.
- Resizing a virtual disk and extending the actual filesystem inside the guest OS are two separate steps, easy to assume are the same thing.
- Partition layout (specifically, what sits at the physical end of a disk) can silently block an otherwise-valid resize operation.

See [`/screenshots/05-fs01-build`](../screenshots/05-fs01-build/) for the VM configuration, the ISO mix-up and correction, the .NET 3.5 warning, and the `diskpart` output.
