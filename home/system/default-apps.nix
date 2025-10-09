{ config, pkgs, ... }:
{
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/http" = "app.zen_browser.zen.desktop";
            "x-scheme-handler/https" = "app.zen_browser.zen.desktop";
            "text/html" = "app.zen_browser.zen.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";
            "audio/mpeg" = "mpv.desktop";
            "video/mp4" = "mpv.desktop";
            "x-scheme-handler/video" = "mpv.desktop";
            "image/jpg" = "org.gnome.Loupe.desktop";
            "image/png" = "org.gnome.Loupe.desktop";
            "image/*" = "org.gnome.Loupe.desktop";
            "x-scheme-handler/terminal" = "kitty.desktop";
        };
    };
}