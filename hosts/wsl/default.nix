{ config, lib, pkgs, inputs, ... }:

{
  imports = [];

  # WSL 基础配置
  wsl = {
    enable = true;
    defaultUser = "pacjuvenile";
  };

  system.stateVersion = "25.05";
  time.timeZone = "Asia/Shanghai";

  # Nix 配置
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # 代理设置
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://172.21.160.1:7890";
    https_proxy = "http://172.21.160.1:7890";
  };

  # 系统包
  environment.systemPackages = with pkgs; [
    # 基础工具
    unzip gzip gnutar xclip git curl wget fd tree ripgrep
    opencv ffmpeg-full

    # Shell & 终端
    zsh fzf zellij tmux yazi starship

    # Node.js 生态
    nodejs_24 deno yarn bun tree-sitter typescript-language-server

    # 开发工具
    gcc gnumake cmake rbenv python313

    # LSP
    lua-language-server marksman pyright svls yaml-language-server ruby-lsp

    # 系统工具
    kmod util-linux ddrescue testdisk
  ];

  # 程序配置
  programs = {
    neovim = {
      enable = true;
      package = pkgs.neovim;
    };

    zsh.enable = true;
    direnv.enable = true;
  };

  # 虚拟化
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # 用户配置
  users.users.pacjuvenile = {
    isNormalUser = true;
    home = "/home/pacjuvenile";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
}
