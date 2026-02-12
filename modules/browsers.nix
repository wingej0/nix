{ config, pkgs, inputs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Browsers
        (google-chrome.override {
            commandLineArgs = [
                "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder"
                "--ozone-platform-hint=auto"
            ];
        })
        brave
        inputs.zen-browser.packages.${pkgs.system}.twilight
    ];

    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".config/google-chrome"
                ".config/BraveSoftware"
                ".zen"
            ];
        };
    };
}