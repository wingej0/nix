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

        foreground = "#CECDC3";
        background = "#100F0F";
        selection_foreground = "#CECDC3";
        selection_background = "#403E3C";
        cursor = "#CECDC3";

        # black
        color0 = "#100F0F";
        color8 = "#6F6E69";

        # red
        color1 = "#AF3029";
        color9 = "#D14D41";

        # green
        color2 = "#66800B";
        color10 = "#879A39";

        # yellow
        color3 = "#AD8301";
        color11 = "#D0A215";

        # blue
        color4 = "#205EA6";
        color12 = "#4385BE";

        # magenta
        color5 = "#A02F6F";
        color13 = "#CE5D97";

        # cyan
        color6 = "#24837B";
        color14 = "#3AA99F";

        # white
        color7 = "#878580";
        color15 = "#CECDC3";
    };
  };
}