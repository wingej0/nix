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
            "x-scheme-handler/mailto" = "com.getmailspring.Mailspring.desktop";
            "x-scheme-handler/mailspring" = "com.getmailspring.Mailspring.desktop";
        };
    };

    # Override Mailspring desktop entry to pass --password-store=gnome-libsecret,
    # required for keyring access on non-GNOME desktops (e.g. Niri).
    xdg.desktopEntries."com.getmailspring.Mailspring" = {
        name = "Mailspring";
        comment = "The best email app for people and teams at work";
        genericName = "Mail Client";
        exec = "flatpak run --branch=stable --arch=x86_64 --command=mailspring com.getmailspring.Mailspring --password-store=gnome-libsecret %U";
        icon = "com.getmailspring.Mailspring";
        categories = [ "Network" "Email" ];
        mimeType = [ "x-scheme-handler/mailto" "x-scheme-handler/mailspring" ];
        startupNotify = true;
        settings = {
            StartupWMClass = "Mailspring";
            X-Flatpak = "com.getmailspring.Mailspring";
        };
    };
}