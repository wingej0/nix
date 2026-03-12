{ config, pkgs, ... }:
{
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/http" = "app.zen_browser.zen.desktop";
            "x-scheme-handler/https" = "app.zen_browser.zen.desktop";
            "text/html" = "app.zen_browser.zen.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";
            "audio/mpeg" = "io.mpv.Mpv.desktop";
            "video/mp4" = "io.mpv.Mpv.desktop";
            "x-scheme-handler/video" = "io.mpv.Mpv.desktop";
            "image/jpeg" = "org.gnome.Loupe.desktop";
            "image/png" = "org.gnome.Loupe.desktop";
            "image/*" = "org.gnome.Loupe.desktop";
            "x-scheme-handler/terminal" = "kitty.desktop";
            "x-scheme-handler/mailto" = "eu.betterbird.Betterbird.desktop";
            "message/rfc822" = "eu.betterbird.Betterbird.desktop";
        };
    };
}