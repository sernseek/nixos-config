{
  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-unstable&shallow=1";
    nixpkgs-stable.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1";
    nixpkgs-ollama.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?rev=15f4ee454b1dce334612fa6843b3e05cf546efab&shallow=1";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    tinja-src = {
      url = "github:Hackmanit/TInjA";
      flake = false;
    };

    dirsearch-src = {
      url = "git+https://github.com/maurosoria/dirsearch.git?ref=master&shallow=1";
      flake = false;
    };

    # Source for the notify-bridge host receiver. Mirrors the submodule at
    # ./notify-bridge; flake builds from this input (submodule contents are not
    # visible to the flake). For local iteration:
    #   --override-input notify-bridge-src path:./notify-bridge
    notify-bridge-src = {
      url = "github:sernseek/notify-bridge";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-ollama,
      home-manager,
      nix-alien,
      disko,
      catppuccin,
      tinja-src,
      dirsearch-src,
      notify-bridge-src,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      stablePkgs = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      ollamaPkgs = import nixpkgs-ollama {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt;

      nixosConfigurations.nixos-main = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit dirsearch-src tinja-src; };
        modules = [
          disko.nixosModules.disko
          ./disko-config.nix
          ./hardware-configuration.nix
          ./configuration.nix
          catppuccin.nixosModules.catppuccin
          {
            nixpkgs.overlays = [
              nix-alien.overlays.default
              (_final: _prev: {
                ollama = ollamaPkgs.ollama;
                ollama-cuda = ollamaPkgs.ollama-cuda;
              })
              # Temporary: nixpkgs ships noctalia-qs v0.0.12 (tagged ~2026-04-02),
              # which predates the fork's PipeWire default-tracker crash fixes:
              #   2026-04-06 fix(pipewire): use QPointer to prevent use-after-free on node removal
              #   2026-04-16 fix(pipewire): avoid crash on device disconnect in default tracker
              # Without them, a Bluetooth audio sink change crashes noctalia-shell
              # (qs::service::pipewire::PwDefaultTracker::setDefaultConfiguredSink)
              # while the niri session is locked, leaving niri's red dead-lock fallback.
              # Pin a master rev that contains the fixes. The version guard makes this
              # self-disable: once nixpkgs bumps noctalia-qs to >= 0.0.13 (a release
              # carrying the fixes) the override evaluates to the stock package, so a
              # normal `nix flake update` switches back to the official build with no
              # manual edit. Delete this overlay entry once that has happened.
              (_final: prev: {
                noctalia-qs =
                  if prev.lib.versionOlder prev.noctalia-qs.version "0.0.13" then
                    prev.noctalia-qs.overrideAttrs (_old: {
                      version = "0.0.12-unstable-2026-06-21";
                      src = prev.fetchFromGitHub {
                        owner = "noctalia-dev";
                        repo = "noctalia-qs";
                        rev = "fc1bdab9adccd3f67fad09e7f6094707eb8c2bfc";
                        hash = "sha256-VKFj+Lt3jTg93ONWFLKieH/QQnXstsqs4hwpQj0nqZ0=";
                      };
                    })
                  else
                    prev.noctalia-qs;
              })
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.extraSpecialArgs = { inherit stablePkgs notify-bridge-src; };
            home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
            home-manager.users.sernseek = import ./home.nix;
          }
        ];
      };
    };
}
