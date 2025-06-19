{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    impermanence.url = "github:nix-community/impermanence";

    cosmic-ext-applet-clipboard-manager = {
      url = "github:cosmic-utils/clipboard-manager";
      flake = false;
    };

    qtile-flake = {
      url = "github:qtile/qtile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qtile-extras = {
      url = "github:elparaguayo/qtile-extras";
      flake = false;
    };

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... } @ inputs: 
  {
    nixosConfigurations = {
      # Personal laptop (System76 Darter-Pro)
      darter-pro = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "darter-pro";
        };
        modules = [
          ./hosts
        ];
      };
      # Holysheet Server
      the-holysheet = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "the-holysheet";
        };
        modules = [
          ./hosts
        ];
      };
      # Work laptop
      dis-winget = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "dis-winget";
        };
        modules = [
          ./hosts
        ];
      };
      # Virtual Machine
      nix-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "nix-vm";
        };
        modules = [
          ./hosts
        ];
      };
    };
  };
}
