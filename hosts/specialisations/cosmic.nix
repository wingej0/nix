{ config, pkgs, inputs, username, ... }:
{
    specialisation = {

        cosmic-desktop.configuration = {
            services.displayManager.cosmic-greeter.enable = true;
            services.desktopManager.cosmic.enable = true;

            home-manager.users.${username} = {
            programs.zsh.initContent = ''
                bindkey -e
                fastfetch
                export FZF_DEFAULT_OPTS="--layout reverse --border bold --border rounded --margin 3% --color dark"

                # Set up fzf key bindings and fuzzy completion
                source <(fzf --zsh)
                bindkey -s '^e' 'vim $(fzf)\n'

                # oh-my-posh
                eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
            '';
            };
        };
    };
}