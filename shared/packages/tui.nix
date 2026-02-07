{ pkgs, ... }:

{
  users.users.kreator.packages = with pkgs; [
    clipse
    helix
    helix-gpt
    nixd
    markdown-oxide
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
    ictree
    dmenu
    dmenu-bluetooth
    dmenu-wayland
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
    pass-wayland
    oath-toolkit
    zbar
    xkcdpass
    tmuxPlugins.pass
    # need to take these out put them in vms
    #nix-ai-tools.copilot-cli
    #nix-ai-tools.gemini-cli
    #nix-ai-tools.opencode
    wl-clipboard
    kitty
    kitty-img
    kitty-themes
    alacritty
    alacritty-graphics
    alacritty-theme
    foot
    lazygit
    virt-viewer
    mpv
    bc

    tldr
    iperf3

    diffnav
    ## We need some kind of tui music player
    cmus
    fum
    ytui-music
    termusic
  ];

  # Firefox
  programs.firefox.enable = true;
  programs.browserpass.enable = true;

  # Tmux
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
