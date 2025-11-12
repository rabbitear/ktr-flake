{ config, lib, pkgs, ... }:
{
  programs.ssh.startAgent = false;

  environment.systemPackages = with pkgs; [
    gnupg
  ];

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
