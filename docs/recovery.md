# unit-01 recovery guide

"My rebuild failed / I can't boot / I made a mistake — now what?"

Recovery options in increasing order of severity. Stop at the first one that works.

If you're doing a fresh install instead, see [`install-guide.md`](./install-guide.md).

---

## Triage: what kind of broken are we?

| Symptom | Where to start |
| --- | --- |
| `nixos-rebuild switch` failed before activation | **Tier 0** (just stay on the running generation) |
| Activation succeeded but desktop is broken / Hyprland won't start | **Tier 1** (boot previous generation) |
| Boots into Limine fine but selecting the latest generation hangs / panics | **Tier 1** (boot previous generation) |
| Limine itself broken — black screen, "no bootable device", weird Limine error | **Tier 2** (systemd-boot fallback specialisation) |
| Both bootloaders broken or boot disk damaged | **Tier 3** (chroot from USB) |
| Disk catastrophically broken | **Tier 4** (reinstall from `install-guide.md`) |

---

## Tier 0: rebuild failed, system still running

A failed `nixos-rebuild switch` (or `just switch`) leaves the running system untouched — the current generation is still loaded, you just don't have a new one to switch to.

1. Read the error carefully (`nh os switch -L` if you want the full log).
2. Fix the cause in the repo.
3. `just check` to confirm eval is clean again.
4. `just switch` to retry.

Nothing to "recover" from at this tier. The system never got into a bad state.

---

## Tier 1: boot a previous generation from Limine

Activation succeeded but the result is unusable (broken Hyprland config, missing module, wrong monitor IDs after a refactor, etc.).

1. Reboot.
2. At the **Limine** menu, pick the previous generation (it's listed by generation number + nixpkgs hash + date).
3. You're now on a known-good system.
4. Roll the breakage out of the repo:
   ```sh
   cd ~/nix-entry-plug
   git --no-pager log --oneline -10           # find the bad commit
   git revert <bad-commit>                    # safe — creates a new commit that undoes it
   just check
   just switch
   ```
5. Reboot back into the latest generation.

> **Don't** delete the broken generation until you've confirmed the fix sticks across a reboot. The whole point of having it in the menu is to fall back to.

---

## Tier 2: Limine itself broken — boot the systemd-boot fallback

`hosts/unit-01/specialisations.nix` defines a `systemd-boot-fallback` specialisation. It's the **same generation**, but boots via systemd-boot instead of Limine.

1. Reboot.
2. At the Limine menu (if it loads at all), pick the entry whose name ends in `(systemd-boot-fallback)`. The current generation has one; previous generations also have one each.
3. If Limine doesn't load at all: most firmwares let you pick a fallback bootloader from the boot-menu key (F12 / F11 / Del). Systemd-boot is registered as a separate EFI entry.
4. Once booted, you can:
   - Stay on systemd-boot indefinitely (it's a fully-functional bootloader; nothing forces a return to Limine).
   - Or fix Limine: identify what broke (recent Limine update? bad Limine config?), revert the offending commit, `just switch`, reboot.

To **temporarily make systemd-boot the default** while you debug Limine, in `modules/core/boot.nix` flip:

```nix
boot.loader = {
  limine.enable = false;
  systemd-boot.enable = true;
};
```

Rebuild and reboot. Flip back when Limine is happy again.

---

## Tier 3: chroot from a NixOS USB and repair

Both bootloaders broken, or you can't reach a Linux session at all.

1. Boot the NixOS minimal USB (see `install-guide.md` §1–2).
2. Enable flakes for the installer:
   ```sh
   sudo mkdir -p /etc/nix
   echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
   ```
3. Mount the BTRFS subvolumes:
   ```sh
   sudo mount -t btrfs -o subvol=@         /dev/disk/by-label/nixos /mnt
   sudo mount -t btrfs -o subvol=@home     /dev/disk/by-label/nixos /mnt/home
   sudo mount -t btrfs -o subvol=@nix      /dev/disk/by-label/nixos /mnt/nix
   sudo mount -t btrfs -o subvol=@log      /dev/disk/by-label/nixos /mnt/var/log
   sudo mount -t btrfs -o subvol=@persist  /dev/disk/by-label/nixos /mnt/persist
   sudo mount /dev/disk/by-label/BOOT      /mnt/boot    # ESP — label may differ
   sudo swapon /dev/disk/by-label/swap
   ```
4. Chroot in:
   ```sh
   sudo nixos-enter --root /mnt
   ```
   You're now inside the installed system with `/nix/store` available.
5. Common repairs from inside the chroot:
   - **Roll back a bad commit**:
     ```sh
     cd /home/ellen/nix-entry-plug
     git revert <bad-commit>
     nixos-rebuild switch --flake .#unit-01
     ```
   - **Switch to an earlier generation as the default**:
     ```sh
     /nix/var/nix/profiles/system-<N>-link/bin/switch-to-configuration switch
     ```
     where `N` is the generation number you want (find them with `ls /nix/var/nix/profiles/`).
   - **Reinstall the bootloader** (if its files on the ESP got corrupted):
     ```sh
     nixos-rebuild switch --flake .#unit-01 --install-bootloader
     ```
6. Exit the chroot, `umount -R /mnt`, `swapoff -a`, reboot.

---

## Tier 4: nuke and reinstall

Disk genuinely broken, BTRFS unrecoverable, or you'd rather start clean. Follow [`install-guide.md`](./install-guide.md) from §1. `/home` is on `@home` which gets wiped along with everything else — make sure anything you want is backed up (or, once Impermanence lands in a future phase, on `@persist`).

---

## Useful diagnostic commands

Run these whenever you want a clearer picture of what's going on:

```sh
# What boot loader entry am I on right now?
cat /run/current-system/init  # path under /nix/store/

# List all generations.
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# What changed between the booted system and the current one?
nvd diff /run/booted-system /run/current-system    # `just diff`

# Recent journal errors.
journalctl -p err -b

# Which service failed at boot.
systemctl --failed
```

---

## Prevention

- Run `just check` before every commit. The flake's `pre-commit` hook does this for you in `nix develop` / direnv.
- After `just switch`, do `just diff` to eyeball what actually changed in the closure.
- Don't delete old generations aggressively. `just gc` keeps the last 5 by default; that's a deliberate floor.
- If you're about to do something invasive (Limine version bump, kernel change, anything touching `boot.*`), `nh os boot --hostname unit-01` instead of `switch` — installs the new generation as the next-boot default without activating now. If it boots, you keep it; if not, you're already back on the previous generation.
