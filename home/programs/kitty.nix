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

        active_tab_background = "#403E3C";
        active_tab_foreground = "#CECDC3";
        inactive_tab_background = "#282726";
        inactive_tab_foreground = "#878580";

        foreground = "#C4C4C4";
        background = "#1B1B1B";
        selection_foreground = "#CECDC3";
        selection_background = "#403E3C";
        cursor = "#C4C4C4";

        # black
        color0 = "#1B1B1B";
        color8 = "#808080";

        # red
        color1 = "#F16161";
        color9 = "#FF8985";

        # green
        color2 = "#7CB987";
        color10 = "#97D5A0";

        # yellow
        color3 = "#DDC74C";
        color11 = "#FAE365";

        # blue
        color4 = "#6296BE";
        color12 = "#7DB1DA";

        # magenta
        color5 = "#BE6DEE";
        color13 = "#D68EFF";

        # cyan
        color6 = "#49BAC8";
        color14 = "#49BAC8";

        # white
        color7 = "#BEBEBE";
        color15 = "#C4C4C4";
    };
  };
}