{ config, pkgs, ... }:
{
    # AI
    environment.systemPackages = with pkgs; [
        gemini-cli
        claude-code
    ];

    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                ".gemini"
                ".claude"
            ];
        };
    };
}