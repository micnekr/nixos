{ description = "NixOS config flake"; inputs = { # Faster than doing it without git protocol because of some bug nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim = {
      url = "path:./modules/nvim/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: maybe add https://github.com/wamserma/flake-programs-sqlite
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      mkSystem =
        host: system:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/configuration.nix # overall config
            ./hosts/${host}/configuration.nix # host-specific config
          ];
          # specialArgs passes these arguments into the modules, namely configuration.nix
          specialArgs = { inherit inputs; };
        };

      mkHomeManager =
        host: system:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./hosts/home.nix # overall config
            ./hosts/${host}/home.nix # host-specific config
          ];

          # extraSpecialArgs passes these arguments into the modules, namely home.nix
          extraSpecialArgs = {
	    inherit system;
	    localflakes = inputs;
          };
        };

    in
    {
      nixosConfigurations = {
        vm = mkSystem "vm" "x86_64-linux";
        laptop = mkSystem "laptop" "86_64-linux";
        desktop = mkSystem "desktop" "86_64-linux";
      };
      homeConfigurations = {
	"mic@vm" = mkHomeManager "vm" "x86_64-linux";
	"mic@laptop" = mkHomeManager "laptop" "x86_64-linux";
	"mic@desktop" = mkHomeManager "desktop" "x86_64-linux";
      };
    };
}
