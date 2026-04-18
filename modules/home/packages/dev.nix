{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Development toolchains
    dotnet-sdk
    nodejs
    pnpm
    rustup
    deno
    python3
    jdk
    nixd

    # Development apps
    vscode
    claude-code
  ];
}
