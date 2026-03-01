{
  description = "NixOS-WSL configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nixos-wsl, neovim-nightly-overlay, ... }: {
    nixosConfigurations = {
      "nixos-wsl" = let
        system = "x86_64-linux"; 
      in nixpkgs.lib.nixosSystem {
        inherit system; 
        specialArgs = {
          inherit inputs system; 
          unstable = nixpkgs-unstable.legacyPackages.${system};
        };
        modules = [
          nixos-wsl.nixosModules.wsl
          ({ config, lib, pkgs, inputs, unstable, ... }: {
            imports = [];

            wsl.enable = true;
            wsl.defaultUser = "pacjuvenile";
						system.stateVersion = "25.05";

            time.timeZone = "Asia/Shanghai";

            systemd.services.nix-daemon.environment = {
              http_proxy = "http://172.21.160.1:7890";
              https_proxy = "http://172.21.160.1:7890";
            };

            environment.systemPackages = with pkgs; [
              unzip gzip gnutar xclip git curl wget fd tree ripgrep opencv ffmpeg-full
              zsh fzf zellij yazi starship
              nodejs_24 deno yarn bun tree-sitter typescript-language-server
              gcc gnumake cmake rustup rbenv python313
              lua-language-server marksman pyright svls yaml-language-server ruby-lsp
            ];

            programs.neovim = {
              enable = true;
              package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
            };

            programs.zsh = { enable = true; };
            programs.direnv = { 
							enable = true; 
						};

						virtualisation.podman = {
							enable = true;
							dockerCompat = true;
							defaultNetwork.settings.dns_enabled = true;
						};

            nix = {
              package = pkgs.nix;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };

            users.users.pacjuvenile = {
              isNormalUser = true;
              home = "/home/pacjuvenile";
              extraGroups = [ "wheel" "networkmanager" ];
              shell = pkgs.zsh;
            };
          })
        ];
      };
    };
  };
}
