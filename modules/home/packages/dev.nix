{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Development toolchains
    dotnet-sdk
    nodejs
    pnpm
    rustup
    gcc
    pkg-config
    deno
    python3
    jdk
    nixd
    android-tools

    # Development apps
    vscode
    claude-code
    codex
    jetbrains.datagrip
    zed-editor

    # devops
    azure-cli
  ];
}
