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
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.extraSpecialArgs = { inherit stablePkgs; };
            home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
            home-manager.users.sernseek = import ./home.nix;
          }
        ];
      };
    };
}
