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

**Testing principle:** Every phase that produces a buildable config ends with a VM test using `nixos-rebuild build-vm-with-bootloader` (or `build-vm` if Limine doesn't cooperate, then swap to the systemd-boot specialisation). Don't move on until the VM does what the phase says it should.

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
- [x] `justfile` with: `switch`, `test`, `check`, `fmt`, `update`, `vm`, `gc`
- [x] Run `nix flake check`
- [x] Run `just fmt` and confirm clean

**Done when:** `nix flake check` passes, formatters and linters work, direnv activates on `cd` into the repo.

#### Phase 2: Minimal bootable system (VM test)

Goal: a config that boots in a VM to a TTY login with networking.

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
- [x] `modules/core/networking.nix`: NetworkManager, hostname `unit-01`, firewall on, SSH allowed
- [x] `modules/core/users.nix`: user `ellen`, wheel, fish, `initialHashedPassword`
- [x] `modules/options/nerv.nix`: skeleton custom options module (define a placeholder option to validate the pattern)
- [x] `hosts/unit-01/default.nix`: imports all of the above
- [ ] `just vm`

**VM test:**
- [ ] Boots to login prompt
- [ ] Can log in as `ellen`
- [ ] Networking works (`ping 1.1.1.1`)
- [ ] systemd-boot-fallback specialisation appears as a separate boot menu entry
- [ ] Both boot entries work

**Done when:** VM boots, networking works, fallback specialisation is selectable.

#### Phase 3: Hardware support and Nix tooling (VM test)

- [ ] `modules/hardware/amd.nix`:
  - `hardware.cpu.amd.updateMicrocode = true`
  - `hardware.enableRedistributableFirmware = true`
  - `hardware.graphics.enable = true`
  - `hardware.graphics.enable32Bit = true`
- [ ] `modules/hardware/audio.nix`:
  - PipeWire + WirePlumber, ALSA compat, PulseAudio off
  - `security.rtkit.enable = true`
- [ ] `modules/hardware/bluetooth.nix`: BlueZ + blueman
- [ ] `modules/hardware/ssd.nix`: `services.fstrim.enable = true`
- [ ] `modules/desktop/dconf.nix`: `programs.dconf.enable = true`
- [ ] `modules/desktop/nix-ld.nix`: `programs.nix-ld.enable = true`
- [ ] `modules/core/nix-tooling.nix`:
  - nh, nom, nvd packages
  - `programs.nix-index.enable = true`
  - `programs.command-not-found.enable = false`
  - comma package
- [ ] `just vm`

**VM test:**
- [ ] Still boots
- [ ] `nh`, `nom`, `nvd` available
- [ ] `, hello` runs hello without it being installed
- [ ] No errors in `journalctl`

**Done when:** Hardware modules and Nix tooling work, VM still boots cleanly.

#### Phase 4: Desktop core + Stylix (VM test)

- [ ] `modules/desktop/stylix.nix`:
  - `stylix.enable = true`
  - `stylix.polarity = "dark"`
  - `stylix.base16Scheme` set to Rosé Pine
  - `stylix.image` set to a placeholder wallpaper
  - Fonts: JetBrains Mono Nerd Font, Inter, Merriweather, Noto Color Emoji
  - Cursor: Bibata Modern Classic
  - Icons: Papirus
- [ ] `modules/desktop/hyprland.nix`: Hyprland enabled, Wayland session, XWayland
- [ ] `modules/desktop/xdg-portal.nix`: hyprland + gtk portals
- [ ] `modules/desktop/greetd.nix`: greetd + ReGreet
- [ ] `just vm`

**VM test:**
- [ ] Reach ReGreet login screen
- [ ] Hyprland session launches
- [ ] Stylix colours visible on greeter and Hyprland

**Done when:** ReGreet logs you into Hyprland in the VM with theming applied.

#### Phase 5: home-manager, applications, shell aliases (VM test)

##### Common home

- [ ] `home/ellen.nix`: imports common + desktop
- [ ] `home/common/default.nix`
- [ ] `home/common/shell.nix`: fish, starship, atuin, all aliases/abbreviations from spec §6
- [ ] `home/common/git.nix`: Shoumeiki identity, SSH signing, `init.defaultBranch = "main"`, `push.autoSetupRemote = true`
- [ ] `home/common/neovim.nix`: Neovim + LazyVim
- [ ] `home/common/direnv.nix`: direnv + nix-direnv
- [ ] `home/common/cli-tools.nix`: eza, bat, ripgrep, fd, fzf, zoxide, btop, tldr, dust, duf, procs, jq, yq, fastfetch

##### Desktop home

- [ ] `home/desktop/default.nix`
- [ ] `home/desktop/hyprland.nix`:
  - Monitors:
    - Gigabyte M32U: `monitor = DP-X, 3840x2160@144, 0x0, 1` (primary, left)
    - BenQ RD280UA: `monitor = DP-Y, 3840x2560@60, 3840x0, 1` (right)
    - Confirm exact connector names during real install
  - KVM fallback: `exec-once = hyprctl output create headless` plus fallback workspace binding
  - Keybinds, window rules, input settings, animations (colours from Stylix)
  - hyprlock, hypridle, hyprpaper (Stylix managed)
- [ ] `home/desktop/waybar.nix`
- [ ] `home/desktop/rofi.nix`
- [ ] `home/desktop/mako.nix`
- [ ] `home/desktop/hyprshade.nix`: blue light filter with sunset/sunrise schedule
- [ ] `home/desktop/terminals.nix`: foot + kitty
- [ ] `home/desktop/audio.nix`: default sink/source config
- [ ] `home/desktop/fun.nix`: cava, fastfetch on shell start
- [ ] Clipboard (wl-clipboard + cliphist) and screenshot (grim + slurp) keybinds in Hyprland config

##### Applications

- [ ] `home/desktop/browsers.nix`: Zen (default), Helium
- [ ] `home/desktop/apps.nix`: Zed, Thunar (+ plugins), yazi, Signal, Vesktop, OBS, virt-manager + QEMU/KVM, Krita, Tenacity, Obsidian, Zathura, LibreOffice, mpv, mpd + ncmpcpp, imv, Docker + Docker-Compose, OpenSSH client
- [ ] `modules/gaming/steam.nix`:
  - `programs.steam.enable = true`
  - `programs.steam.gamescopeSession.enable = true`
  - gamemode, MangoHud, Heroic, PrismLauncher
- [ ] `just vm`

**VM test:**
- [ ] Hyprland session with bar, launcher, notifications, consistent Stylix theming
- [ ] Foot or kitty opens
- [ ] Aliases work (`ls`, `, cowsay`, `rebuild --dry`)
- [ ] fastfetch displays on new shell
- [ ] direnv activates on `cd` into a project

**Done when:** Desktop is usable in the VM and shell environment behaves as expected.

#### Phase 6: First real install on unit-01

##### Pre-install

- [ ] Generate SSH key: `ssh-keygen -t ed25519 -C "shoumeiki@github"`
- [ ] Add public key to GitHub
- [ ] Write `docs/install-guide.md`:
  - Download NixOS minimal ISO, write to USB
  - Boot, connect to network (ethernet)
  - Clone `nix-entry-plug`
  - Run Disko to partition
  - `nixos-install --flake .#unit-01`
  - Reboot
- [ ] Write `docs/recovery.md`: "rebuild fails, now what":
  - Boot previous generation from Limine menu
  - Boot systemd-boot-fallback specialisation
  - When to boot from USB
  - How to roll back a single bad commit

##### Install

- [ ] Boot from NixOS minimal USB
- [ ] Follow install guide

##### Post-install validation

- [ ] Boots via Limine to ReGreet
- [ ] Hyprland session launches
- [ ] Monitor 1 (Gigabyte M32U): 3840x2160 @ 144Hz, left
- [ ] Monitor 2 (BenQ RD280UA): 3840x2560 @ 60Hz, right
- [ ] KVM test: switch input and back, workspaces stay sane (headless fallback works)
- [ ] Stylix theming consistent
- [ ] Audio: UMC22 headphones, motherboard speakers, switchable
- [ ] Bluetooth toggles via blueman
- [ ] Internet works
- [ ] Keybinds functional
- [ ] Apps launch
- [ ] Screen sharing works in Vesktop
- [ ] Gaming: Steam Proton game runs, gamemode + MangoHud work
- [ ] gamescope session selectable at login
- [ ] Hibernation: `systemctl hibernate` + clean resume
- [ ] Git: signed commit + push via SSH works
- [ ] systemd-boot-fallback specialisation present and bootable
- [ ] Commit working config, push to GitHub, mirror to Forgejo

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
- [ ] Rebuild, reboot, confirm login still works
- [ ] Commit (encrypted secrets are safe to commit)

**Done when:** Password is sops-managed and login still works after reboot.

#### Phase 8: Mullvad VPN (optional)

- [ ] `services.mullvad-vpn.enable = true`
- [ ] Rebuild
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

- [ ] nixosTests for any module that runs a service. Spin up a throwaway VM with assertions: service starts, port open, config sane.

#### Binary cache for personal builds

- [ ] Cachix or self-hosted Attic to cache custom builds (Quickshell configs, custom themes). Saves rebuild time once you're building a lot of custom stuff.

#### unit-04 (Home Assistant)

- [ ] Decide on NixOS vs HAOS. HAOS is much easier to maintain, but loses the declarative benefit.
