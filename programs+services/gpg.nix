{ pkgs, ... }:
{
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-curses
    pinentry-gtk2
  ];

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
