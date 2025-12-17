{ config, pkgs, ... }:

{

  # Essential TUI applications configuration
  users.users.kreator.packages = with pkgs; [
    helix
    helix-gpt
    nixd
    marksman
    fzf
    bat
    glow
    nix-search-tv
    ripgrep
    rsync
    gh
    duf
    ncdu
    w3m
    lynx
    fd
    dmenu
    dmenu-bluetooth
    bemenu
    fuzzel
    duckdb
    abduco
    dvtm
    zip
    unzip
    gcc
    gnumake
    btop
    pass
    passExtensions.pass-otp
    nix-ai-tools.copilot-cli
    nix-ai-tools.gemini-cli
    nix-ai-tools.opencode
    wl-clipboard
    kitty
    kitty-img
    kitty-themes
    alacritty
    alacritty-graphics
    alacritty-theme
    foot
    tmux
    virt-viewer
    mpv
    bc


  ];

  # Install firefox.
  programs.firefox.enable = true;
  programs.browserpass.enable = true;

  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    escapeTime = 75;
    plugins = [
      pkgs.tmuxPlugins.cpu
      pkgs.tmuxPlugins.tokyo-night-tmux
      pkgs.tmuxPlugins.tmux-fzf
      pkgs.tmuxPlugins.fzf-tmux-url
      pkgs.tmuxPlugins.mode-indicator
      pkgs.tmuxPlugins.rose-pine
      pkgs.tmuxPlugins.sysstat
      pkgs.tmuxPlugins.weather
      pkgs.tmuxPlugins.better-mouse-mode
    ];
    terminal = "tmux-256color";
    baseIndex = 1;
    newSession = false;   
    extraConfig = "set -g mouse on";
  };
}
