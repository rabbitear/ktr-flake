{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    ed
    wget
    tree
    file
    curl
    jq
    yq
    git
    findutils
    gnupg
    gnupg1
    sops
    age

    git-filter-repo

    bluez-experimental
    blueman

    # Networking tools
    mtr
    iperf3
    dnsutils
    ldns
    socat
    nmap
    aria2
    ipcalc

    # System call monitoring
    strace
    ltrace
    lsof

    # VM tools
    cloud-utils

    # Wayland power management
    wlopm

    # Misc tools
    xdg-utils
    espeak-ng

    drm_info
    libdrm
    radeontop
    pavucontrol

    sway-audio-idle-inhibit
    bemenu
    wf-recorder

    zmap
    rsstail-py
    delta
    tig
  ];
}
