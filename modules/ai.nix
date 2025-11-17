{ config, pkgs, username, ... }:
{
    # AI
    environment.systemPackages = with pkgs; [
        gemini-cli
        claude-code
    ];

    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".gemini"
                ".claude"
            ];
        };
    };
}