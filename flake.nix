{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prise = {
      url = "github:rockorager/prise";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, neovim-nightly-overlay, prise, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      myOverlay = final: prev: import ./overlays {
        pkgs = final;
        inherit inputs;
      };
    in
    {
      packages.${system} = {
        prise = (import nixpkgs {
          inherit system;
          overlays = [ myOverlay ];
        }).prise;
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          nixos-wsl.nixosModules.wsl
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              myOverlay
              neovim-nightly-overlay.overlays.default
            ];
          })
          ./hosts/wsl
        ];
      };
    };
}
