{ config, pkgs, ... }:
{
    # zsh settings (powerlevel10k, wallust, fastfetch)
    programs.zsh = {
        enable = true;
        shellAliases = {
            ls = "eza --icons";
            ll = "eza --icons -la";
            cat="bat";
            fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";     
        };
    };
}
