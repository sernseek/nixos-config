# AGENTS.md

This is the primary project guide for coding agents working in this repository.
`CLAUDE.md` is intentionally a thin reference to this file.

## Repository purpose

Personal NixOS configuration for host `nixos-main` and user `sernseek`.
The flake builds one `nixosConfigurations.nixos-main` system from NixOS,
home-manager, disko, Catppuccin, local modules, a small pinned Ollama
package set, and several security tools built from `flake = false` source
inputs. A second `nixpkgs-stable` (nixos-25.11) channel is imported as
`stablePkgs` for packages that are broken on unstable (currently `bottles`).

## Agent workflow

- Work from `/etc/nixos`.
- Prefer small, scoped module edits over broad rewrites.
- Preserve unrelated dirty work. The `nixos-secrets` submodule often has
  separate secret-bearing changes; do not include or summarize secrets unless
  explicitly asked.
- For library, framework, SDK, API, CLI, or cloud-service questions, use
  Context7 docs first: resolve the library ID, query the selected docs with the
  user's full question, then answer from those docs.
- In this flake repo, new source files must be truly tracked by Git before
  `nix build` or `nixos-rebuild` can evaluate them. `git add -N` may still
  produce `Path '...' is not tracked by Git`.

## Common commands

```fish
# Apply system + home config; home-manager is embedded as a NixOS module.
sudo nixos-rebuild switch --flake /etc/nixos#nixos-main

# Dry-run / validate without activating.
sudo nixos-rebuild dry-activate --flake /etc/nixos#nixos-main
nix flake check
nix --extra-experimental-features 'nix-command flakes' build \
  '/etc/nixos#nixosConfigurations."nixos-main".config.system.build.toplevel' \
  --no-link

# Update all flake inputs.
nix flake update

# Update only the pinned Ollama nixpkgs input after changing its rev.
nix flake lock --update-input nixpkgs-ollama

# Iterate on the notify-bridge host receiver against a local working copy
# instead of the pinned GitHub source.
sudo nixos-rebuild switch --flake /etc/nixos#nixos-main \
  --override-input notify-bridge-src path:/path/to/notify-bridge

# Format Nix files; formatter is pkgs.nixfmt from flake.nix.
nix fmt
```

If `nixos-rebuild switch` is blocked by a critical component restart check,
use `sudo nixos-rebuild boot --flake /etc/nixos#nixos-main` and reboot.
When home-manager refuses to overwrite a file, backups use the `.hm-bak`
extension configured in [flake.nix](flake.nix).

## Entry points

- [flake.nix](flake.nix) defines the single `nixosConfigurations.nixos-main`,
  imports nixpkgs from the NJU mirror, adds a `nixpkgs-stable` (nixos-25.11)
  channel exposed to home-manager as `stablePkgs`, pins `nixpkgs-ollama`,
  enables `nix-alien`, and wires home-manager with `useGlobalPkgs = true`.
  It also carries `flake = false` source inputs consumed by other modules:
  `tinja-src` and `dirsearch-src` (security tools built from source) and
  `notify-bridge-src` (the Windows-guest notification receiver). `stablePkgs`
  and `notify-bridge-src` are threaded into home-manager via
  `home-manager.extraSpecialArgs`.
- [configuration.nix](configuration.nix) imports [modules/nixos](modules/nixos/)
  and sets `system.stateVersion = "26.05"`.
- [home.nix](home.nix) imports [modules/home](modules/home/) and sets
  `home.stateVersion = "26.05"` for `sernseek`.
- [disko-config.nix](disko-config.nix) declares GPT + LUKS + btrfs subvolumes
  `root`, `home`, `nix`, and `swap`.
- [hardware-configuration.nix](hardware-configuration.nix) is generated
  machine-specific configuration.

## Module layout

Every directory under `modules/` has a `default.nix` that imports its leaves.
When adding a module, create the leaf in the right category and add it to that
category's `default.nix`; avoid adding leaves directly to `configuration.nix`
or `home.nix` unless introducing a new top-level category.

Current NixOS categories:

- [modules/nixos/system](modules/nixos/system/) - boot, locale, network,
  nix settings, users/shells, btrfs snapshots, base packages, numlock.
- [modules/nixos/hardware](modules/nixos/hardware/) - nvidia, bluetooth,
  controllers.
- [modules/nixos/desktop](modules/nixos/desktop/) - niri/greetd, desktop
  programs, services, fonts, input method.
- [modules/nixos/services](modules/nixos/services/) - mihomo, Docker, VMware,
  Ollama/Open WebUI, Tailscale.
- [modules/nixos/security-tools.nix](modules/nixos/security-tools.nix) -
  centralized security/pentest package set plus Wireshark enablement.

Current home-manager categories:

- [modules/home/packages](modules/home/packages/) - `dev.nix`,
  `desktop-apps.nix`, `cli-tools.nix`, and runtime `wrappers.nix`.
- [modules/home/desktop](modules/home/desktop/) - fcitx5, notify-bridge,
  programs, services (including the X11<->Wayland clipboard bridge), session
  variables, theme, xdg.
- [modules/home/niri](modules/home/niri/) - niri KDL links, wayland-session,
  Noctalia/fcitx/polkit user services.

## Niri desktop

- System side: [modules/nixos/desktop/niri.nix](modules/nixos/desktop/niri.nix)
  disables xserver/gdm/gnome and boots into `greetd + tuigreet`, which execs
  `$HOME/.wayland-session`.
- Home side: [modules/home/niri/default.nix](modules/home/niri/default.nix)
  writes `.wayland-session`, installs `xwayland-satellite`, and symlinks KDL
  config from `/etc/nixos/modules/home/niri/conf/` with
  `mkOutOfStoreSymlink`.
- The KDL files in [modules/home/niri/conf](modules/home/niri/conf/) are
  live-linked. Edits to `config.kdl`, `keybindings.kdl`,
  `noctalia-shell.kdl`, and `spawn-at-startup.kdl` take effect without a
  rebuild. `modules/home/niri/niri-hardware.kdl` holds machine-specific
  monitor/output config (e.g. the external `HDMI-A-1` pinned to
  1920x1080@100Hz).
- `noctalia-shell`, `fcitx5`, and the polkit agent run as user services wanted
  by `niri.service`, so debug them with `systemctl --user` / `journalctl --user`.

## Services and networking

- [modules/nixos/services/clash.nix](modules/nixos/services/clash.nix) enables
  `services.mihomo` in TUN mode with MetacubeXD and loads provider files from
  `nixos-secrets/providers` into `/var/lib/mihomo/providers` in an
  `ExecStartPre` hook.
- Keep `nixos-secrets/` locked down. It is a Git submodule and may contain
  provider URLs or credentials; do not relax permissions or move the paths that
  mihomo reads.
- NetworkManager DNS is disabled; fallback nameservers are AliDNS and DNSPod.
  Mihomo handles normal DNS/routing, so node-specific DNS behavior can differ.
- Tailscale is enabled with `--accept-dns=false` so it does not override local
  resolver behavior.
- Docker is in [modules/nixos/services/docker.nix](modules/nixos/services/docker.nix)
  with the Daocloud mirror, BuildKit, live-restore, and custom address pools
  `172.30.0.0/16` and `172.31.0.0/16`.
- VMware Workstation host support is in
  [modules/nixos/services/vmware.nix](modules/nixos/services/vmware.nix).
- Ollama uses the pinned `ollama-cuda` package from `nixpkgs-ollama`; Open WebUI
  listens on `127.0.0.1:52001`.
- [modules/home/desktop/notify-bridge.nix](modules/home/desktop/notify-bridge.nix)
  builds the Rust receiver from `notify-bridge-src` and runs it as a user
  service bound to `0.0.0.0:8787`, forwarding Windows VMware-guest notifications
  to the host desktop. The shared secret is read at runtime from
  `nixos-secrets/notify-bridge.env` (`NOTIFY_BRIDGE_TOKEN=`), same pattern as
  mihomo; the guest agent's `config.json` must carry the same token.
- [modules/home/desktop/services.nix](modules/home/desktop/services.nix) runs a
  text-only X11<->Wayland clipboard bridge with a shared-hash loop guard so it
  does not steal native Wayland selections (that guard is why paste into Brave
  from Wayland apps works); images/files are handled by Mod+Alt keybindings, not
  the bridge.

## Packages and wrappers

- General desktop apps live in
  [modules/home/packages/desktop-apps.nix](modules/home/packages/desktop-apps.nix).
  `bottles` is now installed from `stablePkgs` (nixos-25.11) with
  `removeWarningPopup = true`, which sidesteps the `openldap` test in the
  unstable Bottles FHS dependency chain; keep it on the stable channel unless
  that chain is fixed on unstable.
- Development tools live in
  [modules/home/packages/dev.nix](modules/home/packages/dev.nix); CLI tools live
  in [modules/home/packages/cli-tools.nix](modules/home/packages/cli-tools.nix).
- App launch fixes belong in
  [modules/home/packages/wrappers.nix](modules/home/packages/wrappers.nix), mostly
  as `lib.hiPrio` shell wrappers. Existing wrappers cover `code`, `wechat`,
  `obs`, `TeamSpeak`, `telegram-desktop`, `burpsuite`, and `appimage-run`, plus
  `codex-b`, `root-gui`, and `nix-ld-run` helpers. `brave` is handled as a
  package override (not a hiPrio wrapper) so the `.desktop` launcher also gets
  the native-Wayland flag.
- Burp Suite local behavior is managed in
  [modules/home/packages/wrappers.nix](modules/home/packages/wrappers.nix): the
  wrapper conditionally loads the private, ignored
  `/etc/nixos/assets/BurpAddon.jar`, applies Java UI scaling, and exposes a
  stable Jython jar at `$HOME/.local/share/burp/jython.jar` for Python BApps
  such as GAP.
- The security tool bundle belongs in
  [modules/nixos/security-tools.nix](modules/nixos/security-tools.nix). It also
  enables Wireshark and adds `sernseek` to the `wireshark` group. Several tools
  are built from source inside this module: `dirsearch` (from `dirsearch-src`),
  `tinja` (from `tinja-src`), plus `sliver` and `iox` (`buildGoModule`).

## Rebuild triage

- When a rebuild fails, identify the first failing derivation or test before
  explaining downstream `home-manager` or `nixos-system` failures.
- For Bottles-related failures, verify the dependency path with `nix why-depends`
  before changing package policy. The relevant chain has been
  `bottles -> bottles-bwrap -> bottles-fhsenv-rootfs -> openldap`, including the
  32-bit `pkgsi686Linux.openldap` path. The current workaround is pulling
  `bottles` from `stablePkgs` (nixos-25.11) rather than unstable; if it breaks,
  check the stable channel first, not just unstable.
- For DNS/browser issues, reproduce the exact hostname and proxy node. On this
  machine, mihomo TUN can make DNS behavior node-specific.
- For Niri/session issues, check `greetd`, `niri.service`, Noctalia, fcitx5, and
  portal/user-service logs before changing unrelated desktop modules.

## Conventions

- Run `nix fmt` after editing Nix files.
- Do not change `system.stateVersion` or `home.stateVersion` during routine
  nixpkgs upgrades.
- `allowUnfree = true` is set in both the top-level flake package imports and
  [modules/nixos/system/nix-settings.nix](modules/nixos/system/nix-settings.nix).
- The user shell is fish for normal users and root.
- Prefer exact paths and concrete error strings in notes, commits, and final
  explanations.
