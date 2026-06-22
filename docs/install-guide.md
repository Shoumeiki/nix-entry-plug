# unit-01 install guide

End-to-end procedure for installing `nix-entry-plug` on `unit-01` from a NixOS minimal ISO. Assumes you're bombing the existing OS (no coexistence, no data preservation).

If a rebuild on an already-installed system breaks, see [`recovery.md`](./recovery.md) instead.

---

## 0. Before you start

- [ ] Anything you wanted from the old install is already backed up.
- [ ] Phase 5 closure build has been validated on a machine with disk for it (the deferred Phase 5 gate in [`nix-entry-plug-checklist.md`](./nix-entry-plug-checklist.md)).
- [ ] SSH key is generated and added to GitHub (the repo is public, but you'll want push access from `unit-01` afterwards).
- [ ] `hosts/unit-01/default.nix` has `nerv.disk.device` pointing at the correct disk path. Currently `/dev/disk/by-id/nvme-CT1000P3PSSD8_2349457CF10F` — the by-id path for unit-01's Crucial P3 Plus 1TB NVMe (serial `2349457CF10F`).

> **Verifying the by-id path on the live installer**
> Once booted from the NixOS ISO, run `ls -l /dev/disk/by-id/ | grep nvme` and confirm the symlink name in `nerv.disk.device` matches what `nvme0n1` is pointing back at. by-id paths are stable across reboots and don't shift if another NVMe joins, so they're the right answer for any non-throwaway install.

---

## 1. Prepare install media

On a working machine:

1. Download the latest **NixOS minimal ISO** (x86_64) from <https://nixos.org/download/#nixos-iso>.
2. Write it to a USB stick (≥ 2 GB):
   ```sh
   sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
   Replace `sdX` with the USB device (verify with `lsblk`!).

---

## 2. Boot the installer

### 2a. Firmware (UEFI) settings

Before booting the USB, hit the firmware **setup** key (Del / F2 on MSI — separate from the boot menu key) and confirm:

- [ ] **UEFI mode** is the boot mode (not Legacy / CSM-only). Installing in Legacy mode onto the GPT + ESP layout disko creates produces exactly the "HDD isn't bootable" symptom on first reboot.
- [ ] **Secure Boot** is **disabled**. Limine is unsigned in this config; you can opt into `boot.loader.limine.secureBoot.enable` later. With Secure Boot on, the firmware silently refuses to launch the bootloader.
- [ ] **CSM / Legacy Option ROMs** is **disabled** (called "CSM Support" on MSI boards). With CSM enabled, some firmwares try Legacy boot first and never reach the EFI bootloader.
- [ ] **Fast Boot** is **disabled** (MSI / ASUS quirk). Fast Boot skips parts of the EFI device enumeration, which can hide both the installer USB and the freshly-installed `\EFI\BOOT\BOOTX64.EFI` fallback path.
- [ ] **Boot priority** doesn't have a stale entry from the previous OS pinned ahead of everything else. After a wipe-and-reinstall, an orphaned `arch` / `ubuntu` / `Windows Boot Manager` entry that points at a now-overwritten path can hang the firmware long enough that it gives up instead of trying the next entry. Delete any stale entries while you're in setup.

Save and exit firmware setup.

### 2b. Boot from the USB

1. Plug the USB into unit-01.
2. Power on, hit the firmware **boot menu** key (F11 on MSI — separate from setup), pick the USB. You should land in a TTY as `nixos`.
3. Confirm the installer itself booted in UEFI mode (anything else and the install will succeed but the result won't boot):
   ```sh
   [ -d /sys/firmware/efi ] && echo "UEFI ✓" || echo "Legacy/BIOS ✗"
   ```
   If it says Legacy/BIOS, reboot, re-check §2a, and try again.

---

## 3. Network

Ethernet should just work. If you're on Wi-Fi:

```sh
sudo systemctl start wpa_supplicant
nmtui   # if NetworkManager is up, easier
```

Verify:

```sh
ping -c 3 1.1.1.1
```

Then confirm the clock is sane — the installer pulls signed substitutes over HTTPS from `cache.nixos.org`, and a skewed clock will fail TLS validation in ways that look like network errors:

```sh
timedatectl status
```

If the date is wildly off (RTC reset after a CMOS clear, for instance), fix it before continuing — `systemd-timesyncd` should sync once you're online, but you can also set it manually with `sudo timedatectl set-time "YYYY-MM-DD HH:MM:SS"`.

---

## 4. Make the installer comfortable to drive remotely (optional but recommended)

The installer user (`nixos`) starts with no password and `sshd` enabled. Setting a password lets you `ssh nixos@<unit-01-ip>` from a second machine and paste commands without retyping.

```sh
passwd                  # set a throwaway password for `nixos`
ip addr                 # find unit-01's address
```

From your laptop:

```sh
ssh nixos@<unit-01-ip>
```

The rest of this guide assumes either path.

---

## 5. Enable flakes for the installer

The minimal ISO doesn't ship flakes enabled.

```sh
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

---

## 6. Clone the repo

```sh
cd /tmp
git clone https://github.com/Shoumeiki/nix-entry-plug.git
cd nix-entry-plug
```

---

## 7. Partition with disko

> ⚠️ **Destructive.** This wipes the disk pointed to by `nerv.disk.device` (`/dev/disk/by-id/nvme-CT1000P3PSSD8_2349457CF10F` → `nvme0n1`) entirely. Triple-check the device path matches what you intend.

```sh
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko \
  --flake .#unit-01
```

When this returns, the layout from `hosts/unit-01/disko.nix` is on disk and everything is mounted under `/mnt`:

```
/mnt           → BTRFS @
/mnt/home      → BTRFS @home
/mnt/nix       → BTRFS @nix
/mnt/var/log   → BTRFS @log
/mnt/.snapshots → BTRFS @snapshots
/mnt/persist   → BTRFS @persist   (Phase 8/Impermanence)
/mnt/boot      → ESP (vfat)
```

Sanity check:

```sh
lsblk
findmnt -R /mnt
```

Confirm the ESP is mounted at `/mnt/boot`, formatted as `vfat`, and that its GPT partition type is the EFI System Partition GUID (`c12a7328-f81f-11d2-ba4b-00a0c93ec93b` — disko sets this from the `EF00` type code):

```sh
findmnt /mnt/boot                # fsType should be vfat
sudo blkid /dev/disk/by-label/nixos   # btrfs root
sudo sgdisk -p "$(readlink -f /dev/disk/by-id/nvme-CT1000P3PSSD8_2349457CF10F)"
```

The `sgdisk -p` output should show partition 1 with code `EF00` (EFI system partition). If it doesn't, **stop** — the firmware won't recognise the disk as bootable.

---

## 8. Install

```sh
sudo nixos-install --flake .#unit-01 --no-root-passwd
```

- `--no-root-passwd` skips the interactive root password prompt. We never log in as root, and `ellen` already gets `wheel` via the flake. If you'd rather set a root password too, drop the flag.
- This will build the full system closure on the real NVMe. Expect a long download (~20 GB from cache.nixos.org for this config) on first install.
- If it fails, fix the cause, then re-run the same command — `nixos-install` is idempotent.

When it finishes successfully you'll see something like `installation finished!`.

### 8a. Verify the bootloader actually got installed

Before rebooting, confirm Limine wrote its EFI binary to the universal fallback path (`boot.loader.limine.efiInstallAsRemovable = true` in [`modules/core/boot.nix`](../modules/core/boot.nix)):

```sh
sudo find /mnt/boot/efi -maxdepth 4 -type f -name '*.EFI' -o -name 'limine.conf'
```

You should see at least:

- `/mnt/boot/efi/boot/BOOTX64.EFI` — the bootloader at the path every UEFI firmware tries unconditionally.
- `/mnt/boot/limine/limine.conf` — Limine's menu config, listing the installed generation(s).
- `/mnt/boot/limine/kernels/...` — kernel + initrd for each generation.

If `/mnt/boot/efi/boot/BOOTX64.EFI` is **missing**, the bootloader step silently failed somewhere in `nixos-install`. Don't reboot — re-read the install log, fix the cause, and re-run `nixos-install --flake .#unit-01 --no-root-passwd`. Common causes: ESP wasn't mounted at `/mnt/boot` when install ran, ESP filled up, or `efibootmgr` couldn't reach EFI variables (installer not booted in UEFI mode — circle back to §2).

For good measure, also check the firmware boot-order entries that `efibootmgr` knows about. With `efiInstallAsRemovable = true` Limine intentionally **doesn't** add an NVRAM entry (the fallback path makes it unnecessary), so this is informational:

```sh
sudo efibootmgr -v
```

You may still see a `Linux Boot Manager` entry from systemd-boot if the fallback specialisation installed one. That's fine — it's the recovery path.

---

## 9. First boot

```sh
sudo reboot
```

Pull the USB. You should land at the **Limine** boot menu, then **ReGreet**.

- Username: `ellen`
- Password: whatever the hash in `modules/core/users.nix` decodes to (the one you set yourself in Phase 2 via `mkpasswd -m sha-512`). Phase 7 replaces this with a sops-managed file.

### 9a. If the firmware says "no bootable device" / skips straight to PXE / loops back into firmware setup

The first thing to try is the firmware **boot menu** (F11 on MSI) — pick the NVMe drive directly (it'll show up as `UEFI: <drive model>` or similar). If that boots into Limine, you have a boot-order issue, not a bootloader issue: go into firmware setup and pin the NVMe at the top, or delete leftover stale boot entries from the previous OS.

If the NVMe doesn't appear in the boot menu, or selecting it goes nowhere, walk down this list:

1. **Re-verify firmware settings (§2a)** — especially **CSM off** and **Secure Boot off**. After a fresh install, MSI boards have been known to flip CSM back on on their own when they don't immediately find a Legacy MBR.
2. **Disable Fast Boot** if you didn't already. Fast Boot is the single most common cause of "the disk is fine but the firmware refuses to enumerate it".
3. **Clear stale NVRAM entries.** Boot the installer USB again, `sudo efibootmgr -v` lists every EFI boot entry the firmware knows about. Anything that points at an old `\EFI\Arch\...` / `\EFI\ubuntu\...` / etc. path is now broken and may be sitting ahead of the disk in boot order. Delete with `sudo efibootmgr -b <hex-id> -B`.
4. **Try the disk from the firmware's UEFI shell** if your board has one. From the shell, `fs0:` (or `fs1:`, whichever maps to the ESP), then `cd EFI\BOOT`, then `BOOTX64.EFI`. If that boots Limine, the binary is good and the firmware just isn't trying the fallback path — `efiInstallAsRemovable` plus removing stale NVRAM entries usually solves this once and for all.
5. **Confirm `boot.loader.limine.efiInstallAsRemovable = true`** is in [`modules/core/boot.nix`](../modules/core/boot.nix). Without it, Limine relies on a `Limine` NVRAM entry that some firmwares ignore.
6. **Chroot-fix.** Re-mount the installed system per the Tier 3 steps in [`recovery.md`](./recovery.md) and run `nixos-rebuild switch --flake .#unit-01 --install-bootloader` from inside the chroot. The `--install-bootloader` flag forces the bootloader install hook to run again.

---

## 10. Post-install

Work through the **Post-install boot validation** and **Post-install desktop validation** checklists in [`nix-entry-plug-checklist.md`](./nix-entry-plug-checklist.md) (Phase 6). Each item is a specific thing to confirm now that you're on real hardware — bootloader, monitors, audio, gaming, hibernation, etc.

Once those are green:

1. Open a terminal.
2. `cd ~ && git clone git@github.com:Shoumeiki/nix-entry-plug.git` (or move the existing checkout into your home).
3. From there on, the workflow is `just switch` to apply changes, `just check` before commits, `just gc` periodically.
