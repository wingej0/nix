{ config, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code Nerd Font";
      size = 10;
    };
    settings = {
        hide_window_decorations = true;
        background_opacity = 0.8;
        window_padding_width = 10;
        confirm_os_window_close = 0;
    };
    extraConfig = ''
      # DMS/matugen dynamic theme (wallpaper-matched colors + tabs)
      include ${config.home.homeDirectory}/.config/kitty/dank-theme.conf
      include ${config.home.homeDirectory}/.config/kitty/dank-tabs.conf
    '';
  };
}
