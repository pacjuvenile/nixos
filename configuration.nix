# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "pacjuvenile";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  time.timeZone = "Asia/Shanghai";

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
    ffmpeg
    # mpv

    # user
    neovim
    zsh
    fzf
    starship
    yazi

    # tool chain
    #js/ts
    nodejs_24
    deno
    yarn
    bun
    tree-sitter
    # c/cpp
    gcc
    gnumake
    cmake
    # rust
    rustup  # 含rustc、cargo、rust-analyzer、rustfmt等一系列工具
    # python
    python313Packages.python

    # language server    
    lua-language-server
    marksman
    pyright
  ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
    }))
  ];

  programs.zsh = {
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
