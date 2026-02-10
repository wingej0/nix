{ config, pkgs, ... }:
{
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/http" = "zen-twilight.desktop";
            "x-scheme-handler/https" = "zen-twilight.desktop";
            "text/html" = "zen-twilight.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";
            "audio/mpeg" = "mpv.desktop";
            "video/mp4" = "mpv.desktop";
            "x-scheme-handler/video" = "mpv.desktop";
            "image/jpeg" = "org.gnome.Loupe.desktop";
            "image/png" = "org.gnome.Loupe.desktop";
            "image/*" = "org.gnome.Loupe.desktop";
            "x-scheme-handler/terminal" = "kitty.desktop";
        };
    };
}