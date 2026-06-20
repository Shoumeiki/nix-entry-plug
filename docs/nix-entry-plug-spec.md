## nix-entry-plug: NixOS Migration — Spec

_"The entry plug is the pilot's interface to the Evangelion. This repository is your interface to your machines."_

**Repository:** nix-entry-plug
**Primary hosting:** GitHub (github.com/Shoumeiki/nix-entry-plug)
**Date created:** 2026-06-15

This document is the design and reference half of the migration. The actionable, phase-by-phase plan lives in [`nix-entry-plug-checklist.md`](./nix-entry-plug-checklist.md).

---

### Table of Contents

1. System Inventory
2. Configuration Decisions
3. Flake Inputs Reference
4. Users and Security
5. Repository Structure
6. Aliases and Shell Helpers
7. References

---

### 1. System Inventory

#### unit-01 (Desktop)

| Field | Value |
| --- | --- |
| Role | Primary desktop, gaming, and development |
| Hostname | unit-01 |
| Network | Ethernet + WiFi, DHCP (expected IP 192.168.1.200, DNS 192.168.1.100) |
| CPU | AMD Ryzen 7 7800X3D |
| GPU | AMD Radeon RX 7700 XT |
| RAM | 32GB DDR5 |
| Storage | 1TB NVMe SSD |
| Motherboard | MSI MAG B650M Mortar WIFI (AM5) |
| Bluetooth | Yes |
| Monitor 1 (primary) | Gigabyte M32U, 3840x2160 @ 144Hz, left |
| Monitor 2 | BenQ RD280UA, 3840x2560 @ 60Hz, right |
| Keyboard | Nuphy Air75 v3 (wired / 2.4GHz dongle) |
| Mouse | Keychron M5 8k (wired / 2.4GHz dongle) |
| Audio interface | Behringer UMC22 (USB, headphone output) |
| Speakers | Edifier MR4 (motherboard line out) |
| Other | Generic 2-in / 2-out KVM switch, no EDID emulation |

**Monitor layout:**

```
┌──────────────────┐ ┌──────────────────┐
│                  │ │                  │
│  Gigabyte M32U   │ │  BenQ RD280UA    │
│  3840x2160       │ │  3840x2560       │
│  144Hz           │ │  60Hz            │
│  (PRIMARY)       │ │                  │
│                  │ │                  │
└──────────────────┘ └──────────────────┘
```

#### Other Systems (placeholder, not in scope)

| Hostname | Role | IP | Status |
| --- | --- | --- | --- |
| unit-00 | Management server | 192.168.1.100 | Exists, configure later |
| unit-02 | Media server | 192.168.1.102 | Exists, configure later |
| unit-03 | NAS | TBD | Don't own yet |
| unit-12 | Router | 192.168.1.1 | Don't own yet |
| unit-04 | Home Assistant | TBD | Unlikely to be NixOS |

---

### 2. Configuration Decisions

#### Boot and Disk

| Setting | Choice |
| --- | --- |
| Bootloader (primary) | Limine (`boot.loader.limine.enable = true`) |
| Bootloader (fallback) | systemd-boot, available as a specialisation |
| Encryption | None, sops-nix handles secrets at the config layer |
| Disk tool | Disko (declarative partitioning) |
| Filesystem | BTRFS with subvolumes |
| Swap | 32GB swap partition, used for hibernation |
| Hibernation | `boot.resumeDevice` set to swap, `resume=` kernel param |

**Specialisations:** A specialisation called `systemd-boot-fallback` is included so the systemd-boot configuration is always present in the boot menu. If a Limine update breaks, pick the fallback at boot, fix Limine, switch back. The same mechanism can be reused later for things like a battery-saver or no-GPU mode.

**Disko partition layout:**

| Partition | Type | Size | Mount |
| --- | --- | --- | --- |
| ESP | vfat | 512MB | /boot |
| Swap | swap | 32GB | - |
| Root | BTRFS | Remainder | - |

**BTRFS subvolumes:**

| Subvolume | Mount | Purpose |
| --- | --- | --- |
| @ | / | Root filesystem |
| @home | /home | User data |
| @nix | /nix | Nix store |
| @log | /var/log | Persistent logs |
| @snapshots | /.snapshots | BTRFS snapshots |
| @persist | /persist | Reserved for Impermanence (future phase) |

The `@persist` subvolume is created from day one even though Impermanence isn't enabled yet. That way, when Impermanence is rolled in later, the layout is already correct and no repartitioning is needed.

#### System Core

| Setting | Choice |
| --- | --- |
| Kernel | `linuxPackages_zen` |
| AMD microcode | `hardware.cpu.amd.updateMicrocode = true` |
| GPU driver | AMDGPU (open source, in-kernel) |
| Graphics stack | `hardware.graphics.enable = true`, `hardware.graphics.enable32Bit = true` |
| Firmware | `hardware.enableRedistributableFirmware = true` |
| SSD maintenance | `services.fstrim.enable = true` |
| Networking | NetworkManager |
| Firewall | `networking.firewall.enable = true` |
| Bluetooth | BlueZ + blueman |
| Audio | PipeWire + WirePlumber + `security.rtkit.enable = true` |
| GTK app support | `programs.dconf.enable = true` |
| Binary compat | `programs.nix-ld.enable = true` |
| Command lookup | `programs.nix-index.enable = true` + comma (`,`) |
| Unfree handling | `nixpkgs.config.allowUnfreePredicate` with explicit allow-list |
| Locale | en_AU.UTF-8 |
| Timezone | Australia/Melbourne |

**Command lookup with comma:** `nix-index` builds a database of "which package provides this binary". The `,` (comma) tool uses that database to run any binary ephemerally without installing it. So `, cowsay hello` works without ever installing cowsay. Replaces `command-not-found`.

**Unfree handling:** Instead of blanket `allowUnfree = true`, use an explicit predicate listing each unfree package you accept (Steam, Discord, Obsidian, etc.). Catches accidental unfree additions during package experiments.

#### Desktop Environment

| Component | Choice |
| --- | --- |
| Compositor | Hyprland (Wayland) |
| Login manager | greetd + ReGreet (`programs.regreet.enable = true`, themed via Stylix) |
| Status bar | waybar _(placeholder, Quickshell later)_ |
| Launcher | rofi _(placeholder, Quickshell later)_ |
| Notifications | mako _(placeholder, Quickshell later)_ |
| Lock screen | hyprlock |
| Idle manager | hypridle |
| Wallpaper | hyprpaper (managed by Stylix) |
| Clipboard | wl-clipboard + cliphist |
| Screenshots | grim + slurp |
| Recording | gpu-screen-recorder |
| Blue light filter | hyprshade |
| Shell toolkit | Quickshell _(future, ref: celesrenata/end-4-flakes, end-4/dots-hyprland)_ |
| XDG portals | xdg-desktop-portal-hyprland + xdg-desktop-portal-gtk |

**KVM switch handling:** No EDID emulation on the KVM, so monitors disappear when input switches and Hyprland reshuffles workspaces. Workaround: create a headless output at startup with `hyprctl output create headless` and bind a fallback workspace to it. When real outputs drop, workspaces fall back to the headless output instead of being redistributed. Configured in the Hyprland exec-once block.

#### Theming (Stylix)

Stylix provides unified system-wide theming. `autoEnable = true` (default) applies it to all supported targets including Hyprland, hyprpaper, waybar, foot, kitty, mako, GTK, Qt, and more.

| Setting | Value |
| --- | --- |
| Framework | Stylix (github:nix-community/stylix) |
| Colour scheme | Rosé Pine base16 _(placeholder, custom theme later)_ |
| Polarity | dark |
| Monospace font | JetBrains Mono Nerd Font (`pkgs.nerd-fonts.jetbrains-mono`) |
| Sans-serif font | Inter (`pkgs.inter`) |
| Serif font | Merriweather (`pkgs.merriweather`) |
| Emoji font | Noto Color Emoji (`pkgs.noto-fonts-color-emoji`) |
| Cursor | Bibata Modern Classic (`pkgs.bibata-cursors`) |
| Icon theme | Papirus (`pkgs.papirus-icon-theme`) |
| Wallpaper | TBD |

**Note:** Confirm ReGreet appears in the current Stylix targets list before assuming it themes automatically. If not, theme it manually via `programs.regreet.settings`.

#### Applications

| Category | Application | Source |
| --- | --- | --- |
| Shell | fish + starship | nixpkgs |
| Shell history | atuin (synced across hosts) | nixpkgs |
| Terminal (light) | foot | nixpkgs (themed by Stylix) |
| Terminal (feature) | kitty | nixpkgs (themed by Stylix) |
| Editor (GUI) | Zed | nixpkgs |
| Editor (TUI) | Neovim + LazyVim _(stays for now, learning curve)_ | nixpkgs |
| Browser (primary) | Zen Browser | flake: github:0xc000022070/zen-browser-flake |
| Browser (Chromium) | Helium Browser | flake: github:oxcl/nix-flake-helium-browser |
| File manager (GUI) | Thunar | nixpkgs |
| File manager (TUI) | yazi | nixpkgs |
| Image viewer | imv | nixpkgs |
| Video player | mpv | nixpkgs |
| Music player | mpd + ncmpcpp | nixpkgs |
| Gaming | Steam + Proton experimental | nixpkgs (`programs.steam.enable`) |
| Gaming | Heroic Games Launcher | nixpkgs |
| Gaming | PrismLauncher (Minecraft) | nixpkgs |
| Gaming | Gamemode | nixpkgs |
| Gaming | Gamescope + `programs.steam.gamescopeSession.enable` | nixpkgs |
| Gaming | MangoHud | nixpkgs |
| Image editor | Krita | nixpkgs |
| Audio editor | Tenacity | nixpkgs |
| Communication | Signal Desktop | nixpkgs |
| Communication | Vesktop (Discord + Vencord) | nixpkgs |
| Notes | Obsidian | nixpkgs |
| PDF viewer | Zathura | nixpkgs |
| Office suite | LibreOffice | nixpkgs |
| Virtualisation | QEMU/KVM + virt-manager | nixpkgs |
| Containerisation | Docker + Docker-Compose | nixpkgs |
| Remote | OpenSSH client | nixpkgs |
| Dev shells | direnv + nix-direnv | nixpkgs |

#### CLI Tools

| Tool | Purpose |
| --- | --- |
| eza | Modern ls replacement |
| bat | Cat with syntax highlighting |
| ripgrep | Fast grep |
| fd | Fast find |
| fzf | Fuzzy finder |
| zoxide | Smart cd |
| btop | System monitor |
| tldr | Simplified man pages |
| dust | Disk usage visualiser |
| duf | Disk free utility |
| procs | Process viewer |
| jq | JSON processor |
| yq | YAML processor |
| fastfetch | System info at shell startup (neofetch replacement) |
| cava | Audio visualiser (because why not) |

#### Nix Workflow Tools

These replace and improve on the default `nixos-rebuild` workflow. Aliases in §6.

| Tool | Purpose |
| --- | --- |
| nh (`nix-helper`) | Wrapper around nixos-rebuild, auto-finds flake, integrates nom |
| nom (`nix-output-monitor`) | Readable build output instead of the wall of text |
| nvd | Diffs closures, shows what packages changed between generations |
| nix-index + comma | Run any binary without installing it |
| just | Task runner, central place for common commands (`just switch`, `just update`, `just check`) |

#### Code Quality

| Tool | Purpose |
| --- | --- |
| nixfmt-rfc-style | Official RFC 166 formatter (the nixpkgs standard) |
| statix | Lint for Nix anti-patterns |
| deadnix | Find unused bindings |
| treefmt-nix | Run all formatters/linters across the tree with one command |
| pre-commit-hooks.nix | Run statix, deadnix, treefmt on every commit |

#### Git Identity

| Setting | Value |
| --- | --- |
| GitHub account | github.com/Shoumeiki |
| Authentication | SSH (ed25519) |
| Commit signing | SSH key signing (`gpg.format = "ssh"`) |
| SSH agent | home-manager (`programs.ssh.enable`, `addKeysToAgent = "yes"`) |

SSH key generated imperatively (`ssh-keygen -t ed25519`) and added to GitHub. Git config and SSH agent declared in home-manager.

#### Management and Maintenance

| Setting | Choice |
| --- | --- |
| Config paradigm | Nix flakes |
| Module argument passing | `specialArgs` / `extraSpecialArgs` to pass `inputs`, `self`, helpers to every module |
| Custom options | Define `nerv.*` options for self-documenting toggles (e.g. `nerv.gaming.enable`) |
| Secrets | sops-nix (age keys), set up post-install |
| User config | home-manager (as NixOS flake module) |
| Dotfile management | Declarative via home-manager |
| Garbage collection | Automated (`nix.gc`) |
| Updates | Automated notifications, not auto-apply |
| Repo hosting | GitHub (primary) + Forgejo (backup) |

**Repo discipline:**
- Anything in `modules/` must work on any host. No host-specific assumptions.
- Anything host-specific lives in `hosts/`.
- Use `lib.mkIf` for conditional enablement, `lib.mkMerge` for combining attribute sets, `lib.mkForce` for overrides (e.g. inside specialisations).
- When patching packages, use `overlays/` rather than vendoring.

---

### 3. Flake Inputs Reference

| Input | Source | Purpose |
| --- | --- | --- |
| nixpkgs | github:NixOS/nixpkgs/nixos-unstable | Base packages and NixOS modules |
| home-manager | github:nix-community/home-manager | User-level config management |
| disko | github:nix-community/disko | Declarative disk partitioning |
| sops-nix | github:Mic92/sops-nix | Secrets management (post-install) |
| stylix | github:nix-community/stylix | Unified system-wide theming |
| zen-browser | github:0xc000022070/zen-browser-flake | Zen Browser with home-manager module |
| helium-browser | github:oxcl/nix-flake-helium-browser | Helium with NixOS + home-manager modules |
| git-hooks | github:cachix/git-hooks.nix | Git hook integration (formerly `cachix/pre-commit-hooks.nix`) |
| treefmt-nix | github:numtide/treefmt-nix | Multi-formatter runner |
| impermanence | github:nix-community/impermanence | Ephemeral root (future phase) |

**Important:** Inputs that depend on nixpkgs should follow yours. Both browser flakes' READMEs also recommend pinning their nixpkgs to yours (and zen-browser additionally pins home-manager):

```nix
inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
inputs.git-hooks.inputs.nixpkgs.follows = "nixpkgs";
inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
inputs.zen-browser.inputs.nixpkgs.follows = "nixpkgs";
inputs.zen-browser.inputs.home-manager.follows = "home-manager";
inputs.helium-browser.inputs.nixpkgs.follows = "nixpkgs";
```

---

### 4. Users and Security

#### Users

| User | Purpose | Groups | Sudo |
| --- | --- | --- | --- |
| ellen | Primary user | wheel, docker, video, audio | Yes |
| guest | Guest account | limited | No |

#### Authentication (initial)

- Use `initialHashedPassword` (generated with `mkpasswd -m sha-512`) committed to the repo for first boot. Avoids the sops-nix bootstrap chicken-and-egg.
- Migrate to sops-nix managed password in Phase 7.

#### Firewall

`networking.firewall.enable = true` with sensible defaults. Allow SSH inbound during install/setup, tighten later.

#### VPN (Mullvad)

- `services.mullvad-vpn.enable = true` (declared off by default, toggled when needed)
- Account login is imperative: `mullvad account login <number>`
- No declarative account option exists

---

### 5. Repository Structure

```
nix-entry-plug/
├── flake.nix                  # Inputs, overlays, host definitions, specialArgs
├── flake.lock                 # Pinned dependency versions
├── .sops.yaml                 # sops-nix config (added in Phase 7)
├── .envrc                     # direnv: `use flake`
├── justfile                   # Common commands (switch, update, check, fmt)
├── treefmt.nix                # Formatter config (nixfmt-rfc-style + others)
│
├── hosts/
│   └── unit-01/
│       ├── default.nix        # Host entry point
│       ├── hardware.nix       # Hardware config + tweaks
│       ├── disko.nix          # ESP + swap + BTRFS layout (includes @persist)
│       └── specialisations.nix # systemd-boot-fallback definition
│
├── modules/
│   ├── core/
│   │   ├── boot.nix           # Limine + hibernation + kernel
│   │   ├── nix-settings.nix   # Flakes, GC, substituters, allowUnfreePredicate
│   │   ├── locale.nix         # Locale, timezone, console
│   │   ├── networking.nix     # NetworkManager, firewall, hostname
│   │   ├── users.nix          # User accounts (initialHashedPassword first)
│   │   └── nix-tooling.nix    # nh, nom, nvd, nix-index, comma
│   ├── hardware/
│   │   ├── amd.nix            # CPU microcode, AMDGPU, graphics stack, firmware
│   │   ├── audio.nix          # PipeWire + WirePlumber + rtkit
│   │   ├── bluetooth.nix      # BlueZ + blueman
│   │   └── ssd.nix            # fstrim
│   ├── desktop/
│   │   ├── hyprland.nix       # Hyprland system-level
│   │   ├── greetd.nix         # greetd + ReGreet
│   │   ├── xdg-portal.nix     # XDG portals
│   │   ├── dconf.nix
│   │   ├── nix-ld.nix
│   │   └── stylix.nix         # Stylix system-level
│   ├── gaming/
│   │   └── steam.nix          # Steam, Proton, gamemode, gamescope, MangoHud
│   ├── options/
│   │   └── nerv.nix           # Custom `nerv.*` option definitions
│   └── secrets/
│       └── sops.nix           # sops-nix base (added in Phase 7)
│
├── home/
│   ├── common/
│   │   ├── default.nix
│   │   ├── shell.nix          # fish, starship, atuin, aliases, abbreviations
│   │   ├── git.nix            # Shoumeiki identity, SSH signing
│   │   ├── neovim.nix         # Neovim + LazyVim
│   │   ├── direnv.nix         # direnv + nix-direnv
│   │   └── cli-tools.nix      # eza, bat, ripgrep, fd, fzf, zoxide, btop, etc.
│   ├── desktop/
│   │   ├── default.nix
│   │   ├── hyprland.nix       # Monitors, keybinds, KVM headless workaround
│   │   ├── waybar.nix
│   │   ├── rofi.nix
│   │   ├── mako.nix
│   │   ├── hyprshade.nix      # Blue light filter schedule
│   │   ├── terminals.nix      # foot + kitty
│   │   ├── audio.nix          # PipeWire default sink/source
│   │   ├── browsers.nix       # Zen + Helium
│   │   ├── fun.nix            # cava, fastfetch
│   │   └── apps.nix           # Thunar, yazi, Signal, Vesktop, OBS, virt-manager
│   └── ellen.nix
│
├── overlays/                  # Custom package overlays (use as needed)
│
├── lib/                       # Helper functions (added as patterns emerge)
│
├── secrets/                   # Added in Phase 7
│   └── secrets.yaml
│
└── docs/
    ├── install-guide.md
    ├── aliases.md             # Generated reference (see §6)
    └── recovery.md            # "Rebuild fails, now what" guide
```

**Stylix placement note:** The NixOS module (`modules/desktop/stylix.nix`) sets the base config. Stylix auto-applies to home-manager targets when its home-manager module is imported in `flake.nix`.

---

### 6. Aliases and Shell Helpers

A central reference. All defined in `home/common/shell.nix` as fish abbreviations (which expand inline so you can see the real command) plus a few functions where logic is needed. Mirror to `docs/aliases.md` for quick reference.

#### Nix workflow

| Alias | Expands to | Purpose |
| --- | --- | --- |
| `rebuild` | `nh os switch` | Apply current flake to running system |
| `rebuild-boot` | `nh os boot` | Apply on next boot only |
| `rebuild-test` | `nh os test` | Apply without adding to boot menu |
| `dry` | `nh os switch --dry` | Show what would change |
| `update` | `nh os switch --update` | Update flake inputs and switch |
| `gen` | `sudo nix-env -p /nix/var/nix/profiles/system --list-generations` | List system generations |
| `gen-diff` | `nvd diff /run/current-system /run/booted-system` | What changed since boot |
| `clean` | `nh clean all --keep 5 --keep-since 7d` | Garbage collect, keep last 5 / 7 days |
| `search` | `nh search` | Search nixpkgs |
| `repl` | `nix repl --expr 'import <nixpkgs> {}'` | Interactive nix REPL |

#### Repo workflow (justfile targets, also aliased)

| Alias / target | Action |
| --- | --- |
| `just switch` | Format, lint, then `nh os switch` |
| `just test` | Build but don't add to boot menu |
| `just check` | `nix flake check` + statix + deadnix |
| `just fmt` | Format whole tree with treefmt |
| `just update` | Update flake inputs |
| `just vm` | Build and launch VM |
| `just gc` | Garbage collect old generations |

#### Filesystem / navigation

| Alias | Expands to |
| --- | --- |
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --git --group-directories-first` |
| `la` | `eza -la --icons --git --group-directories-first` |
| `tree` | `eza --tree --icons` |
| `cat` | `bat --paging=never` |
| `find` | `fd` (with bare `find` still available as `\find`) |
| `grep` | `rg` (with bare `grep` still available as `\grep`) |
| `cd` | `z` (zoxide) |
| `du` | `dust` |
| `df` | `duf` |
| `ps` | `procs` |
| `top` | `btop` |

#### Git

| Alias | Expands to |
| --- | --- |
| `gs` | `git status` |
| `gd` | `git diff` |
| `gc` | `git commit` |
| `gca` | `git commit --amend` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate` |
| `gco` | `git checkout` |
| `gsw` | `git switch` |

#### Hyprland / desktop

| Alias | Expands to |
| --- | --- |
| `monitors` | `hyprctl monitors` |
| `clients` | `hyprctl clients` |
| `reload-hypr` | `hyprctl reload` |

#### Fun / utility

| Alias | Expands to |
| --- | --- |
| `,` | comma (run binary without installing) |
| `weather` | `curl wttr.in/Melbourne` |
| `myip` | `curl ifconfig.me` |

Add more as patterns emerge. The rule: if you type a command more than three times, alias it.

---

### 7. References

#### General
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- NixOS Wiki: https://wiki.nixos.org/
- NixOS Search (packages and options): https://search.nixos.org/
- Nix Pills (deep dive): https://nixos.org/guides/nix-pills/

#### Flakes and tooling
- Flakes (wiki): https://wiki.nixos.org/wiki/Flakes
- home-manager: https://github.com/nix-community/home-manager
- home-manager options: https://nix-community.github.io/home-manager/
- Disko: https://github.com/nix-community/disko
- Disko examples: https://github.com/nix-community/disko/tree/master/example
- sops-nix: https://github.com/Mic92/sops-nix
- Impermanence: https://github.com/nix-community/impermanence

#### Workflow tools
- nh: https://github.com/viperML/nh
- nix-output-monitor (nom): https://github.com/maralorn/nix-output-monitor
- nvd: https://gitlab.com/khumba/nvd
- nix-index: https://github.com/nix-community/nix-index
- comma: https://github.com/nix-community/comma
- direnv + nix-direnv: https://github.com/nix-community/nix-direnv
- just: https://github.com/casey/just

#### Code quality
- nixfmt (RFC 166): https://github.com/NixOS/nixfmt
- statix: https://github.com/nerdypepper/statix
- deadnix: https://github.com/astro/deadnix
- treefmt-nix: https://github.com/numtide/treefmt-nix
- pre-commit-hooks.nix: https://github.com/cachix/pre-commit-hooks.nix

#### Desktop
- Hyprland Wiki: https://wiki.hypr.land/
- Hyprland NixOS wiki: https://wiki.nixos.org/wiki/Hyprland
- Stylix: https://github.com/nix-community/stylix
- Stylix docs: https://stylix.danth.me/
- greetd + ReGreet: https://github.com/rharish101/ReGreet
- hyprshade: https://github.com/loqusion/hyprshade

#### Hardware
- AMDGPU (wiki): https://wiki.nixos.org/wiki/AMD_GPU
- PipeWire (wiki): https://wiki.nixos.org/wiki/PipeWire
- BTRFS (wiki): https://wiki.nixos.org/wiki/Btrfs
- Hibernation (wiki): https://wiki.nixos.org/wiki/Hibernate

#### Boot
- Limine module: search `limine.nix` in https://github.com/NixOS/nixpkgs
- Specialisations: https://nixos.org/manual/nixos/stable/#sec-specialisation
- systemd-boot fallback: NixOS manual bootloader section

#### Gaming
- Steam (wiki): https://wiki.nixos.org/wiki/Steam
- Gamescope: https://github.com/ValveSoftware/gamescope

#### VPN
- Mullvad (wiki): https://wiki.nixos.org/wiki/Mullvad_VPN

#### AI
- Ollama (NixOS module options): https://search.nixos.org/options?query=services.ollama
- Open WebUI: https://github.com/open-webui/open-webui
- aider: https://aider.chat/
- mods: https://github.com/charmbracelet/mods
- continue.dev: https://www.continue.dev/

#### Reference repos
- end-4/dots-hyprland: https://github.com/end-4/dots-hyprland
- celesrenata/end-4-flakes: https://github.com/celesrenata/end-4-flakes
