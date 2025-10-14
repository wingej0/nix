{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    impermanence.url = "github:nix-community/impermanence";

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # qtile-flake = {
    #   url = "github:qtile/qtile";
    #   # url = "github:mooncubes/qtile/z-layer-management";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # qtile-extras-flake = {
    #   url = "github:elparaguayo/qtile-extras";
    #   flake = false;
    # };

    # Add the COSMIC nightly flake
    # cosmic-nightly.url = "github:busyboredom/cosmic-nightly-flake";

    cosmic-applets-collection.url = "github:wingej0/ext-cosmic-applets-flake";
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
