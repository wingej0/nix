{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager (for unstable)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager (for stable)
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    
    impermanence.url = "github:nix-community/impermanence";

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # Cosmic Applets
    cosmic-applets-collection.url = "github:wingej0/ext-cosmic-applets-flake";

    # Plasma Manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Qtile
    # qtile-flake = {
    #   url = "github:qtile/qtile";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Qtile Extras
    # qtile-extras-flake = {
    #   url = "github:elparaguayo/qtile-extras";
    #   flake = false;
    # };

    # Zen Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, ... } @ inputs: 
  {
    nixosConfigurations = {
      # Personal laptop (System76 Darter-Pro) - Using unstable
      darter-pro = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "darter-pro";
          stateVersion = "25.05";
          useStableBranch = false;
        };
        modules = [
          ./hosts
        ];
      };
      # Virtual machine - Using stable
      nix-vm = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "nix-vm";
          stateVersion = "25.05";
          useStableBranch = true;
        };
        modules = [
          ./hosts
        ];
      };
      # Using unstable
      dis-winget = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "jwinget";
          hostname = "dis-winget";
          stateVersion = "25.11";
          useStableBranch = false;
        };
        modules = [
          ./hosts
        ];
      };

      # Using stable
      the-holysheet = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "jwinget";
          hostname = "the-holysheet";
          stateVersion = "25.11";
          useStableBranch = true;
        };
        modules = [
          ./hosts
        ];
      };
    };
  };
}
