## nix-entry-plug: NixOS Migration — Checklist

_"The entry plug is the pilot's interface to the Evangelion. This repository is your interface to your machines."_

**Repository:** nix-entry-plug
**Primary hosting:** GitHub (github.com/Shoumeiki/nix-entry-plug)
**Date created:** 2026-06-15

This document is the actionable, phase-by-phase plan. The design decisions, system inventory, repo layout, alias reference, and external links live in [`nix-entry-plug-spec.md`](./nix-entry-plug-spec.md).

---

### Table of Contents

1. Implementation Checklist
2. Future Phases

---

### 1. Implementation Checklist

**Testing principle:** Each phase ends with eval-time validation only — `nix flake check`, `statix`, `deadnix`, and `just build` (which builds the full system closure without activating it). Full boot validation is deferred to Phase 6 on real hardware, where the actual disk layout, swap, Limine, and GPU drivers all exist.

VM testing via `nixos-rebuild build-vm` was attempted and abandoned: nested-TCG performance was too poor for an interactive boot, and the synthetic disk forced enough divergence from the real disko layout that the VM was no longer validating the production config. The safety net for the real install is:

- **Limine's previous-generation menu** — every successful generation is selectable at boot
- **`systemd-boot-fallback` specialisation** — selectable if Limine itself misbehaves
- **NixOS minimal installer USB** — boot, mount the disko'd disk, `nixos-rebuild switch --flake` to recover
- **`just build` before activation** — catches every eval and build error before the system changes

If `just build` succeeds and `just check` is clean, the config is as validated as it can be off-target.

#### Phase 0: Pre-migration

- [x] Export current package list for reference: `pacman -Qqe > pkglist.txt`
- [x] Copy current dotfiles (Hyprland, waybar, fish) for reference
- [x] Note any manual tweaks, custom kernel params, sysctl settings
- [x] Document current monitor connector names (output of `hyprctl monitors`)

**Done when:** You have reference material for the rebuild.

#### Phase 1: Repository scaffolding and tooling

Set up the repo to be clean from day one.

- [x] Create `nix-entry-plug` repo on GitHub under Shoumeiki
- [x] Lay out directory structure as in spec
- [x] Write `flake.nix` with all inputs from spec
- [x] Configure `nixpkgs.follows` for all relevant inputs
- [x] Wire up `specialArgs` to pass `inputs`, `self` to every NixOS module
- [x] Wire up `extraSpecialArgs` to pass the same to home-manager modules
- [x] Define `unit-01` nixosConfiguration stub
- [x] `treefmt.nix`: configure nixfmt-rfc-style as the Nix formatter
- [x] Wire up `git-hooks.nix` in the flake's `devShells.default` and `checks`:
  - nixfmt-rfc-style
  - statix
  - deadnix
- [x] `.envrc` containing `use flake`
- [x] `justfile` with: `switch`, `boot`, `test`, `dry`, `check`, `build`, `fmt`, `update`, `gc`, `diff`
- [x] Run `nix flake check`
- [x] Run `just fmt` and confirm clean

**Done when:** `nix flake check` passes, formatters and linters work, direnv activates on `cd` into the repo.

#### Phase 2: Minimal bootable system

Goal: a config that evaluates and builds for a TTY login with networking.

- [x] `hosts/unit-01/disko.nix`: ESP, swap (labelled `swap`), BTRFS with @, @home, @nix, @log, @snapshots, @persist
- [x] `hosts/unit-01/hardware.nix`: stub, refine with `nixos-generate-config` output during real install
- [x] `modules/core/boot.nix`:
  - `boot.loader.limine.enable = true`
  - `boot.loader.limine.efiSupport = true`
  - `boot.kernelPackages = pkgs.linuxPackages_zen`
  - `boot.resumeDevice = "/dev/disk/by-label/swap"`
  - `boot.kernelParams = [ "resume=/dev/disk/by-label/swap" ]`
- [x] `hosts/unit-01/specialisations.nix`:
  ```nix
  specialisation.systemd-boot-fallback.configuration = {
    boot.loader.limine.enable = lib.mkForce false;
    boot.loader.systemd-boot.enable = lib.mkForce true;
  };
  ```
- [x] `modules/core/nix-settings.nix`:
  - Flakes, nix-command experimental features
  - `nix.gc` schedule
  - Binary cache config
  - `nixpkgs.config.allowUnfreePredicate` with starter allow-list
- [x] `modules/core/locale.nix`: en_AU.UTF-8, Australia/Melbourne
- [x] `modules/core/networking.nix`: NetworkManager, firewall on, SSH allowed (hostname set per-host in `hosts/unit-01/default.nix`)
- [x] `modules/core/users.nix`: user `ellen`, wheel, fish, `initialHashedPassword`
- [x] `modules/options/nerv.nix`: skeleton custom options module (define a placeholder option to validate the pattern)
- [x] `hosts/unit-01/default.nix`: imports all of the above

**Validate:**

- [x] `just check` — flake check + statix + deadnix all clean
- [x] `just build` — full system closure builds successfully

**Done when:** Config evaluates and builds. Boot / login / networking validation is deferred to Phase 6.

#### Phase 3: Hardware support and Nix tooling

- [x] `modules/hardware/amd.nix`:
  - `hardware.cpu.amd.updateMicrocode = true`
  - `hardware.enableRedistributableFirmware = true`
  - `hardware.graphics.enable = true`
  - `hardware.graphics.enable32Bit = true`
- [x] `modules/hardware/audio.nix`:
  - PipeWire + WirePlumber, ALSA compat, PulseAudio off
  - `security.rtkit.enable = true`
- [x] `modules/hardware/bluetooth.nix`: BlueZ + blueman
- [x] `modules/hardware/ssd.nix`: `services.fstrim.enable = true`
- [x] `modules/desktop/dconf.nix`: `programs.dconf.enable = true`
- [x] `modules/desktop/nix-ld.nix`: `programs.nix-ld.enable = true`
- [x] `modules/core/nix-tooling.nix`:
  - nh, nom, nvd packages
  - `programs.nix-index.enable = true`
  - `programs.command-not-found.enable = false`
  - comma package

**Validate:**

- [x] `just check` clean
- [x] `just build` succeeds

**Done when:** Hardware and Nix-tooling modules are written and the closure builds.

#### Phase 4: Desktop core + Stylix

- [x] `modules/desktop/stylix.nix`:
  - `stylix.enable = true`
  - `stylix.polarity = "dark"`
  - `stylix.base16Scheme` set to Rosé Pine
  - `stylix.image` set to a placeholder wallpaper
  - Fonts: JetBrains Mono Nerd Font, Inter, Merriweather, Noto Color Emoji
  - Cursor: Bibata Modern Classic
  - Icons: Papirus
- [x] `modules/desktop/hyprland.nix`: Hyprland enabled, Wayland session, XWayland
- [x] `modules/desktop/xdg-portal.nix`: hyprland + gtk portals
- [x] `modules/desktop/greetd.nix`: greetd + ReGreet

**Validate:**

- [x] `just check` clean
- [x] `just build` succeeds (this will pull a lot — Hyprland, fonts, theming)

**Done when:** Desktop modules build into the closure.

#### Phase 5: home-manager, applications, shell aliases

##### Common home

- [x] `home/ellen.nix`: imports common + desktop
- [x] `home/common/default.nix`
- [x] `home/common/shell.nix`: fish, starship, atuin, all aliases/abbreviations from spec §6
- [x] `home/common/git.nix`: Shoumeiki identity, SSH signing, `init.defaultBranch = "main"`, `push.autoSetupRemote = true`
- [x] `home/common/neovim.nix`: Declarative Neovim (plugins via `pkgs.vimPlugins`, config in `initLua`, LSP for nil + lua-language-server)
- [x] `home/common/direnv.nix`: direnv + nix-direnv
- [x] `home/common/cli-tools.nix`: eza, bat, ripgrep, fd, fzf, zoxide, btop, tldr, dust, duf, procs, jq, yq, fastfetch

##### Desktop home

- [x] `home/desktop/default.nix`
- [x] `home/desktop/hyprland.nix`:
  - Monitors:
    - Gigabyte M32U: `monitor = DP-X, 3840x2160@144, 0x0, 1` (primary, left, DP-1)
    - BenQ RD280UA: `monitor = DP-Y, 3840x2560@60, 3840x0, 1` (right, HDMI-A-1)
    - Confirm exact connector names during real install
  - KVM fallback: `exec-once = hyprctl output create headless` plus fallback workspace binding
  - Keybinds, window rules, input settings, animations (colours from Stylix)
  - hyprlock, hypridle, hyprpaper (Stylix managed)
- [x] `home/desktop/waybar.nix`
- [x] `home/desktop/rofi.nix`
- [x] `home/desktop/mako.nix`
- [x] `home/desktop/hyprshade.nix`: blue light filter with sunset/sunrise schedule
- [x] `home/desktop/terminals.nix`: foot + kitty
- [x] `home/desktop/audio.nix`: default sink/source config
- [x] `home/desktop/fun.nix`: cava, fastfetch on shell start
- [x] Clipboard (wl-clipboard + cliphist) and screenshot (grim + slurp) keybinds in Hyprland config

##### Applications

- [x] `home/desktop/browsers.nix`: Zen (default), Helium
- [x] `home/desktop/apps.nix`: Zed, Thunar (+ plugins), yazi, Signal, Vesktop, virt-manager + QEMU/KVM, Krita, Audacity, Obsidian, Zathura, LibreOffice, mpv, mpd + ncmpcpp, imv, Docker + Docker-Compose, OpenSSH client
- [x] `modules/gaming/steam.nix`:
  - `programs.steam.enable = true`
  - `programs.steam.gamescopeSession.enable = true`
  - gamemode, MangoHud, Heroic, PrismLauncher

**Validate:**

- [x] `just check` clean (eval gate — evaluation of every module + formatter + lint hooks)
- [x] `just build` deferred to Phase 6 pre-install

  > The full system toplevel closure for this config (Steam + Proton GE + LibreOffice + Krita + both browser flakes + Hyprland + Zed + …) is ~20 GB of downloads. That won't fit on a typical test VM disk, and once cache.nixos.org has handed back everything the build is mostly a download exercise rather than a meaningful additional check. The pre-install step in Phase 6 runs `just build` on the existing Arch host (which has the disk for it) before the migration, and `nixos-install --flake .#unit-01` performs the equivalent build on the real NVMe during the actual install.

**Done when:** `just check` is clean and every module has been touched/verified manually. The full closure build is validated for real in Phase 6 on the Arch host and then again during `nixos-install`.

#### Phase 6: First real install on unit-01

This is where boot / login / networking / desktop / hardware are all validated for the first time.

##### Pre-install

- [ ] Generate SSH key on the existing Arch system: `ssh-keygen -t ed25519 -C "shoumeiki@github"`
- [ ] Add public key to GitHub
- [ ] **Full closure build on the Arch host** (the build that was deferred from Phase 5 — the Arch host has the disk a VM doesn't): in the Arch system's Nix-with-flakes shell, `cd nix-entry-plug && nix build .#nixosConfigurations.unit-01.config.system.build.toplevel -L`. This is the last opportunity to catch a broken derivation before pulling the plug on Arch.
- [x] Confirm `nerv.disk.device` in `hosts/unit-01/default.nix` matches unit-01's disk. Currently `/dev/disk/by-id/nvme-CT1000P3PSSD8_2349457CF10F` (Crucial P3 Plus 1TB, serial `2349457CF10F`).
- [x] `docs/install-guide.md` written
- [x] `docs/recovery.md` written
- [ ] Have a second machine (laptop, phone tethered) available with `docs/recovery.md` open
- [ ] Confirm a NixOS minimal installer USB is written, bootable, and on the desk
- [ ] Final pass: anything you wanted from the Arch install is backed up (browser profiles, SSH keys, GPG keys, `~/.local/share`, etc.) — user has chosen the full-bomb option, so this is your last checkpoint

##### Install

Follow [`docs/install-guide.md`](./install-guide.md) end-to-end. Tick here when each phase of the guide is done:

- [ ] Booted from NixOS minimal USB, network up
- [ ] Flakes enabled on the installer
- [ ] Repo cloned to `/tmp/nix-entry-plug`
- [ ] `disko` ran cleanly, layout matches expectation (`findmnt -R /mnt`)
- [ ] `nixos-install --flake .#unit-01 --no-root-passwd` completed successfully
- [ ] First reboot lands at Limine → ReGreet

##### Post-install boot validation

This is the first time the system actually runs end-to-end.

- [ ] Limine appears at boot
- [ ] Plymouth splash shows during stage-1 / stage-2 boot (no wall of kernel text)
- [ ] Default entry boots to a usable system
- [ ] `systemd-boot-fallback` specialisation entry appears in Limine
- [ ] `systemd-boot-fallback` boots successfully (test once, then prefer the default)
- [ ] Login as `ellen` works
- [ ] `hostname` returns `unit-01`
- [ ] `ping -c 3 1.1.1.1` succeeds (ethernet)
- [ ] `groups` shows `wheel networkmanager video audio docker libvirtd`
- [ ] `sudo` works
- [ ] `swapon --show` lists the labelled swap partition
- [ ] `journalctl -p err -b` is empty or only contains expected entries
- [ ] `fwupdmgr get-devices` enumerates SSD / UEFI / peripherals

##### Post-install desktop validation

- [ ] Reach ReGreet login screen
- [ ] Hyprland session launches
- [ ] Monitor 1 (Gigabyte M32U): 3840x2160 @ 144Hz, left
- [ ] Monitor 2 (BenQ RD280UA): 3840x2560 @ 60Hz, right
- [ ] Primary waybar (DP-1) shows full module set incl. AMD GPU % and temp
- [ ] Secondary waybar (HDMI-A-1) shows workspaces + window title + clock
- [ ] KVM test: switch input and back, workspaces stay sane (headless fallback works)
- [ ] Passthrough submap toggles with `Super+Esc` (waybar `hyprland/submap` indicator shows status)
- [ ] Cursor (Bibata) is consistent across Hyprland, GTK and XWayland apps
- [ ] Stylix theming consistent across greeter, console (TTY), terminal, waybar, rofi, mako, GTK apps
- [ ] swayosd appears on volume / mute / brightness keypress
- [ ] Audio: UMC22 headphones, motherboard speakers, switchable in `pavucontrol`
- [ ] Bluetooth toggles via blueman, can pair a device
- [ ] Keybinds functional (launcher, terminal, screenshot, clipboard history)
- [ ] Apps launch (Zen, Zed, Thunar, yazi, Signal, Vesktop, mpv)
- [ ] Screen sharing works in Vesktop
- [ ] `gpu-screen-recorder-gtk` can capture the screen without prompting for sudo
- [ ] Gaming: Steam launches, Proton game runs, gamemode + MangoHud overlay visible
- [ ] gamescope session selectable at login
- [ ] Hibernation: `systemctl hibernate` + clean resume to logged-in session
- [ ] direnv activates on `cd` into the `nix-entry-plug` repo
- [ ] fastfetch displays on new shell
- [ ] Aliases work (`ls`, `, cowsay`, abbreviations from spec §6)
- [ ] Git: signed commit + push via SSH works
- [ ] Commit any post-install tweaks, push to GitHub

**Done when:** You're reading this document from unit-01 on NixOS.

#### Phase 7: sops-nix migration

Swap from `initialHashedPassword` to sops-managed.

- [ ] Add sops-nix to `flake.nix` (if not already present)
- [ ] `age-keygen -o ~/.config/sops/age/keys.txt`
- [ ] Copy age private key to `/var/lib/sops-nix/key.txt` (or your chosen `sops.age.keyFile`)
- [ ] Create `.sops.yaml` with the age public key
- [ ] Create and encrypt `secrets/secrets.yaml`:
  - `users.ellen.hashedPassword`
- [ ] `modules/secrets/sops.nix`: sops-nix configuration and secret definitions
- [ ] Update `modules/core/users.nix` to use `hashedPasswordFile`
- [ ] `just build`, then `just switch`, then reboot, confirm login still works
- [ ] Commit (encrypted secrets are safe to commit)

**Done when:** Password is sops-managed and login still works after reboot.

#### Phase 8: Mullvad VPN (optional)

- [ ] `services.mullvad-vpn.enable = true`
- [ ] `just switch`
- [ ] `mullvad account login <account-number>`
- [ ] Confirm tunnel works

#### Phase 9: AI tools and local LLMs

Your RX 7700 XT has 12GB VRAM, enough to run useful models locally.

- [ ] `services.ollama.enable = true`
- [ ] `services.ollama.acceleration = "rocm"` (test that ROCm works for your GPU first, fall back to CPU if not)
- [ ] Pull a starter model: `ollama pull qwen2.5-coder:14b` (or smaller `qwen2.5-coder:7b` to start)
- [ ] **open-webui** via Docker for a browser ChatGPT-style UI
- [ ] **aider** in `home/common/cli-tools.nix`: AI pair programmer that edits files and makes commits
- [ ] **mods** for piping things through an LLM: `cat logs.txt | mods "what's wrong here"`
- [ ] **continue.dev** in Zed for inline AI completion backed by ollama
- [ ] **whisper.cpp** for local speech-to-text

**Done when:** You can run prompts locally, pipe through `mods`, and use `aider` in the nix-entry-plug repo.

---

### 2. Future Phases

Not in current scope. Listed here so future-you doesn't forget.

#### Impermanence migration

Wipe root on every boot, only persist what's explicitly declared. The `@persist` subvolume is already in place from Phase 2, so the layout doesn't change.

- [ ] Add `impermanence` flake input
- [ ] Import its NixOS and home-manager modules
- [ ] Roll back `@` to a blank snapshot on boot (initrd-stage script)
- [ ] Declare `environment.persistence."/persist"` with paths to keep:
  - `/var/log`, `/var/lib/nixos`, `/var/lib/systemd/coredump`
  - `/etc/NetworkManager/system-connections`
  - `/etc/machine-id`
  - sops-nix key path
- [ ] Declare `home.persistence."/persist/home/ellen"` with home paths to keep
- [ ] Reboot, audit what breaks, add it to the persist list
- [ ] Repeat until clean

#### Custom colour theme

- [ ] Design a personal base16 scheme
- [ ] Replace Rosé Pine in `stylix.base16Scheme`
- [ ] Pair with a custom wallpaper

#### Quickshell migration

Replace waybar, rofi, mako with Quickshell QML components.
- Reference: celesrenata/end-4-flakes, end-4/dots-hyprland

#### Limine theming and Secure Boot

- [ ] Enable Stylix Limine target
- [ ] Set up Secure Boot via Limine + sbctl

#### Additional hosts

- [ ] unit-00 (management)
- [ ] unit-02 (media)
- [ ] unit-03 (NAS)
- [ ] unit-12 (router)

Shared modules in `modules/` already structured to support this. Each host gets its own `hosts/unit-XX/` directory.

#### Game streaming

- [ ] sunshine on unit-01
- [ ] moonlight on receiving devices (unit-02 near a TV, phone, tablet)

#### Android apps

- [ ] waydroid for the occasional Android app

#### Keyboard remapping at OS level

- [ ] kanata for declarative key remaps (move Nuphy layers into Nix)

#### Code quality additions

- [ ] nixosTests for any module that runs a service. Spin up a throwaway VM with assertions: service starts, port open, config sane. (Worth revisiting once the install is real and we have a working baseline to compare against — the eval-only validation path we're using now means a regression in a service module wouldn't be caught until activation.)

#### Binary cache for personal builds

- [ ] Cachix or self-hosted Attic to cache custom builds (Quickshell configs, custom themes). Saves rebuild time once you're building a lot of custom stuff.

#### unit-04 (Home Assistant)

- [ ] Decide on NixOS vs HAOS. HAOS is much easier to maintain, but loses the declarative benefit.
