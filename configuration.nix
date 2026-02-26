# edit this configuration file to define what should be installed on
# your system. help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the nixos manual (`nixos-help`).

# nixos-wsl specific options are documented on the nixos-wsl repository:
# https://github.com/nix-community/nixos-wsl

{ config, lib, pkgs, ... }:

let 
  unstable = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  }) {
    system = pkgs.system;
  };
in {
	imports = [
		# include nixos-wsl modules
		<nixos-wsl/modules>
	];

	wsl.enable = true;
	wsl.defaultUser = "pacjuvenile";

	# this value determines the nixos release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. it's perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "25.05"; # did you read the comment?

	time.timeZone = "asia/shanghai";

	systemd.services.nix-daemon.environment = {
		http_proxy = "http://172.21.160.1:7890";
		https_proxy = "http://172.21.160.1:7890";
	};

	environment.systemPackages = with pkgs; [
		# system
		unzip
		gzip
		gnutar
		xclip
		git
		curl
		wget
		fd
		tree
		ripgrep
		opencv
		ffmpeg-full

		# user
		neovim
		zsh
		fzf
		zellij
		yazi
		unstable.codex
		starship

		# tool chain
		#js/ts
		nodejs_24
		deno
		yarn
		bun
		tree-sitter
		typescript-language-server
		# c/cpp
		gcc
		gnumake
		cmake
		# rust
		rustup  # 含rustc、cargo、rust-analyzer、rustfmt等一系列工具
		# ruby
		rbenv
		# python
		python313

		# language server    
		lua-language-server
		marksman
		pyright
		svls
		yaml-language-server
		ruby-lsp
	];

	nixpkgs.overlays = [
		(import (builtins.fetchTarball {
			url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
		}))
	];

	programs.zsh = {
		enable = true;
	};

	programs.direnv = {
		enable = true;
	};

	users.users.pacjuvenile = {
		isNormalUser = true;
		home = "/home/pacjuvenile";
		extraGroups = [
			"wheel"
			"networkmanager"
		];
		shell = pkgs.zsh;
	};
}
