# Host receiver for Windows guest notifications (see /etc/nixos/notify-bridge).
# Builds the Rust binary from the in-repo subtree and runs it as a user service
# bound to the VMware vmnet8 gateway, so only NAT guests can reach it.
{ pkgs, notify-bridge-src, ... }:
let
  notifyBridgeHost = pkgs.callPackage "${notify-bridge-src}/nix/package.nix" {
    source = "${notify-bridge-src}/host";
  };
in
{
  imports = [ "${notify-bridge-src}/nix/home-module.nix" ];

  services.notify-bridge = {
    enable = true;
    package = notifyBridgeHost;
    # Listen on all interfaces so the VMware NAT subnet can change without
    # editing this; the guest auto-discovers the host by scanning for /health.
    # Exposure on tailscale/tether is gated by the required token below.
    bind = "0.0.0.0:8787";
    # Shared secret read at runtime (same pattern as mihomo). The file holds
    # NOTIFY_BRIDGE_TOKEN=<secret>; the Windows agent's config.json must carry
    # the same token. Bound to vmnet8 it is already guest-only, so this is
    # belt-and-suspenders.
    tokenFile = "/etc/nixos/nixos-secrets/notify-bridge.env";
  };
}
