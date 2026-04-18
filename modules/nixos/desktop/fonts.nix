{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    # 基础中文字体
    wqy_zenhei
    wqy_microhei
    source-han-sans
    source-han-serif
  ];
  fonts.fontconfig.enable = true;
}
