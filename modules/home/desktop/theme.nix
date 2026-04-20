{ pkgs, ... }:
{
  # adw-gtk3 follows the xdg-portal color-scheme signal, so Noctalia's
  # prefer-dark/prefer-light toggle is enough to flip GTK3 apps (Thunar,
  # etc.) between light and dark variants — no gtk-theme rewrite needed.
  # Adwaita icons provide the freedesktop standard names that noctalia-shell
  # and other Qt apps look up via gtk-icon-theme-name.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
