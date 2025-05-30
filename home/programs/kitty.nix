{
  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code Nerd Font";
      size = 10;
    };
    settings = {
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        hide_window_decorations = true;
        background_opacity = 0.8;
        window_padding_width = 10;
        confirm_os_window_close = 0;
    };
  };
}