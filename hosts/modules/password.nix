{ config, pkgs, lib, ... }:
{
    options = with lib; with types; {
        hashedPassword = mkOption { type = str; };
    }
    config = {
        hashedPassword = "$6$DC6usdc/o.Svf2X3$yyl4T3lbOjCUVma/io5nEWjaUxbl5ly//R39sr6tBHpLQQORaOVluRWfqOwfwSzBSA1/cwJANsEcsDAr1bDIn1";
    }
}