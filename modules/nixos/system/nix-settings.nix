{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    # Resilience for flaky mirrors / proxy: if a cache is unreachable or a
    # substitute download fails, build from source instead of aborting.
    fallback = true;
    # Drop dead substituters fast (e.g. cachix SSL reset) instead of long retries.
    connect-timeout = 5;
    # Abandon a stalled substitute download after 10s of no progress, so a
    # flaky mirror (e.g. sjtu timing out) does not stall the whole rebuild.
    stalled-download-timeout = 10;
    # Do not retry the same dead URL 5x; fail fast and move to the next
    # substituter (or build from source via `fallback`).
    download-attempts = 1;
    # More parallel connections to speed up substitution from the mirrors.
    http-connections = 50;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      zstd
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      icu
      glib
      nss
      nspr
      expat
      fontconfig
      freetype
      libGL
      alsa-lib
    ];
  };
}
