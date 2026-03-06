{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Games
        # scid-vs-pc
        stockfish
        lc0
    ];

    # environment.persistence."/persist" = {
    #     users.${username} = {
    #         directories = [
    #             ".scidvspc"
    #         ];
    #     };
    # };
}
