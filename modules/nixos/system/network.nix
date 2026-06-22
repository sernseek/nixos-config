{ ... }:
{
  networking = {
    hostName = "nixos-main";
    enableIPv6 = true;

    networkmanager = {
      enable = true;
      dns = "none";
    };

    # Fallback resolvers — mihomo TUN handles DNS in normal operation.
    # AliDNS + DNSPod only; 114DNS dropped (history of NXDOMAIN rewriting).
    nameservers = [
      "223.5.5.5"
      "119.29.29.29"
    ];

    firewall = {
      enable = true;
      # Steam dedicated-server / remote-play ports are opened by
      # programs.steam.{dedicatedServer,remotePlay,localNetworkGameTransfers}.openFirewall.
      allowedTCPPorts = [
        8080
        2233
        53317 # LocalSend
      ];
      allowedUDPPorts = [
        53317 # LocalSend multicast discovery
      ];
      # notify-bridge receiver — open only on the VMware NAT interface so the
      # Windows guest can reach it, never on tether/tailscale.
      interfaces."vmnet8".allowedTCPPorts = [ 8787 ];
    };
  };
}
