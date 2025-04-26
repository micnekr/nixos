{
  description = "NixOS config flake";

  inputs = {

    # Faster than doing it without git protocol because of some bug
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    # pkgs = import nixpkgs {
    #   inherit system;
    #   config = {
    #     # allowUnfree = true;
    #   };
    # };

  in
  {
    nixosConfigurations = {
    vm=nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/vm/configuration.nix
        # you can move this into folders for organisation someday
      ];
      # specialArgs passes these arguments into the modules, namely configuration.nix
      specialArgs = {inherit inputs;};
    };

    homeConfigurations.mic = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
      ];

      # extraSpecialArgs passes these arguments into the modules, namely home.nix
      extraSpecialArgs = {
      };
    };
    };
  };
}
