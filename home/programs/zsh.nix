{ config, pkgs, ... }:
{
    # zsh settings (powerlevel10k, wallust, fastfetch)
    programs.zsh = {
        enable = true;
        initContent = ''
            bindkey -e
            fastfetch
            export FZF_DEFAULT_OPTS="--layout reverse --border bold --border rounded --margin 3% --color dark"

            # Set up fzf key bindings and fuzzy completion
            source <(fzf --zsh)
            bindkey -s '^e' 'vim $(fzf)\n'

            # oh-my-posh
            eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
            cat ~/.cache/wallust/sequences
        '';
        shellAliases = {
            ls = "eza --icons";
            ll = "eza --icons -la";
            cat="bat";
            fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"; 
            nrs = "sudo nixos-rebuild switch --flake . --verbose --show-trace --specialisation";    
        };
    };
}
