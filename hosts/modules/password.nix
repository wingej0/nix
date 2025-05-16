{ config, pkgs, lib, ... }
{
    options = with lib; with types; {
        hashedPassword = mkOption { type = str; };
    }
    config = {
        hashedPassword = "Insert Hash";
    }
}