# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal NixOS system configuration for host `nixos-main`, user `sernseek`. Built as a flake that composes NixOS + home-manager + disko into a single `nixosConfigurations.nixos-main`.

## Common commands

```fish
# Apply system + home config (combined via home-manager NixOS module)
sudo nixos-rebuild switch --flake /etc/nixos#nixos-main

# Dry-run / validate without activating
sudo nixos-rebuild dry-activate --flake /etc/nixos#nixos-main
nix flake check

# Update all inputs (nixpkgs, home-manager, disko, niri, catppuccin, nix-alien)
nix flake update

# Format Nix files (formatter declared in flake.nix → nixfmt)
nix fmt

# Rebuild only home-manager without touching system (rarely needed — home is embedded)
# Prefer full nixos-rebuild switch; there is no standalone HM profile.
```

When home-manager refuses to overwrite a file, backups land with extension `.hm-bak` (configured in [flake.nix](flake.nix)).

## Architecture

### Entry points
- [flake.nix](flake.nix) — single `nixosConfigurations.nixos-main`. Pulls nixpkgs from the NJU mirror (`mirrors.nju.edu.cn`). Injects `nix-alien` as an overlay and wires home-manager with `useGlobalPkgs = true`.
- [configuration.nix](configuration.nix) — thin aggregator: imports [modules/nixos](modules/nixos/). Sets `system.stateVersion`.
- [home.nix](home.nix) — home-manager root for `sernseek`. Imports [modules/home](modules/home/).
- [disko-config.nix](disko-config.nix) — declarative partitioning: GPT + LUKS + btrfs with subvolumes `root`, `home`, `nix`, `swap` (32 GiB swapfile, zstd:3 compression).
- [hardware-configuration.nix](hardware-configuration.nix) — generated, machine-specific.

### Module layout rule
Every directory under `modules/` has a `default.nix` that `imports = [ … ];` its leaf files (or sub-aggregators). When adding a module: create the leaf in the category that fits its concern, then add it to that directory's `default.nix`. Do not add entries to `configuration.nix`/`home.nix` directly unless introducing a genuinely new top-level category.

Categories under [modules/nixos/](modules/nixos/):

- [system/](modules/nixos/system/) — boot, locale, network, nix-settings, users-shell, btrfs-snapshots, packages (system-wide).
- [hardware/](modules/nixos/hardware/) — nvidia, bluetooth.
- [desktop/](modules/nixos/desktop/) — niri, programs, services (desktop-facing), fonts, input-method.
- [services/](modules/nixos/services/) — clash (mihomo), virtualization (docker + libvirtd).

Categories under [modules/home/](modules/home/):

- [packages/](modules/home/packages/) — splits into `dev.nix`, `desktop-apps.nix`, `cli-tools.nix`, `wrappers.nix`.
- [desktop/](modules/home/desktop/) — programs, services, session, theme, xdg.
- [niri/](modules/home/niri/) — niri KDL configs + wayland-session wiring (see below).

### Niri desktop (the non-obvious part)
- System side: [modules/nixos/desktop/niri.nix](modules/nixos/desktop/niri.nix) disables xserver/gdm/gnome and boots into **greetd + tuigreet**, which execs `$HOME/.wayland-session`.
- Home side: [modules/home/niri/default.nix](modules/home/niri/default.nix) writes `.wayland-session` and symlinks the KDL configs (`config.kdl`, `keybindings.kdl`, `noctalia-shell.kdl`, `spawn-at-startup.kdl`) via `mkOutOfStoreSymlink` to `/etc/nixos/modules/home/niri/conf/`. **Edits to those KDL files take effect without rebuilding** — they're live-linked, not copied into the Nix store. Only `niri-hardware.kdl` is store-managed.
- A `noctalia-ipc` wrapper script is generated in the same file; it locates the currently-running `noctalia-shell` binary and forwards IPC calls. Swayidle user service uses it for auto-lock.

### Secrets
- Git submodule `nixos-secrets` → `https://github.com/sernseek/nixos-secrets.git`, mounted at `nixos-secrets/`.
- Consumed directly from `/etc/nixos/nixos-secrets/` at activation time — e.g. [clash.nix](modules/nixos/services/clash.nix) reads `mihomo-config.yaml` and installs provider files into `/var/lib/mihomo/providers` via a `preStart` hook. Do not move or rename this directory; the path is hard-coded.

### Networking quirks (China-specific)
- IPv6 disabled; DNS pinned to AliDNS / DNSPod / 114.
- Nix substituters list [modules/nixos/system/nix-settings.nix](modules/nixos/system/nix-settings.nix) prioritizes USTC / SJTU / Tsinghua mirrors before `cache.nixos.org`.
- Mihomo runs in **TUN mode** ([clash.nix](modules/nixos/services/clash.nix)) — system-wide proxy. When debugging network issues, check `systemctl status mihomo` before assuming DNS/firewall problems.

### Storage / snapshots

- [btrfs-snapshots.nix](modules/nixos/system/btrfs-snapshots.nix) runs an activation script that creates `/.snapshots` and `/home/.snapshots` subvolumes if missing, then configures snapper with hourly timeline snapshots. `sernseek` is in `ALLOW_USERS` for both configs.

### Virtualization
[services/virtualization.nix](modules/nixos/services/virtualization.nix) enables Docker (with daocloud mirror and custom address pools `172.30/31.0.0/16` to avoid home-network conflicts), libvirtd with swtpm, and overrides `virt-secret-init-encryption` to pre-create `/var/lib/libvirt/secrets` with mode 0700.

### Wrapper binaries
[modules/home/packages/wrappers.nix](modules/home/packages/wrappers.nix) uses `lib.hiPrio` to shadow upstream packages with shell-script wrappers that inject env vars (e.g. `code` → Wayland/Ozone flags + gnome-libsecret; `wechat` → fcitx env; `appimage-run` → WebKit workarounds). When a GUI app misbehaves with IME or Wayland, add a wrapper here rather than patching the package.

## Conventions

- Formatter is `nixfmt` (declared as `formatter.${system}` in flake). Run `nix fmt` before committing.
- `system.stateVersion` / `home.stateVersion` = `"26.05"` — do **not** change these when upgrading nixpkgs.
- `allowUnfree = true` is set both in the flake's top-level `pkgs` import and in [nix-settings.nix](modules/nixos/base/nix-settings.nix).
- Shell for all users (including root) is `fish`.
