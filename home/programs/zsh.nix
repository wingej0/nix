{ config, pkgs, ... }:
{
    # zsh settings (powerlevel10k, wallust, fastfetch)
    programs.zsh = {
        enable = true;
        initContent = ''
            source ~/.p10k.zsh
            bindkey -e
            fastfetch
            export FZF_DEFAULT_OPTS="--layout reverse --border bold --border rounded --margin 3% --color dark"

            # Set up fzf key bindings and fuzzy completion
            source <(fzf --zsh)
            bindkey -s '^e' 'vim $(fzf)\n'
        '';
        plugins = [   
            {                                                                                   
                name = "powerlevel10k";                                                           
                src = pkgs.zsh-powerlevel10k;                                                     
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";                         
            }
        ];
        shellAliases = {
            ls = "eza --icons";
            ll = "eza --icons -la";
            cat="bat";
            fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";     
        };
    };
}