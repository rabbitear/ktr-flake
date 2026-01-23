{ config, pkgs, ... }:
{
  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "miniflux"
      miniflux-url "http://sasha:3003/"
      miniflux-login "kreator"
      miniflux-password "some-pass"
    '';
  };
}
