{ config, lib, pkgs, ... }:
{
  config = {
    sops = {
      #enable = true;
      defaultSopsFile = ./crypt/cipher.yaml;
      #gnupg.home = "/home/kreator/.gnupg";
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/kreator/.config/sops/age/keys.txt";

      secrets = {
        "kreator" = {
          neededForUsers = true;
        };
        "github_ssh_key" = {
          mode = "0600";
          owner = "kreator";
          path = "/home/kreator/.ssh/theshack";
        };
        "openrouter_api_key" = {
          owner = "kreator";
        };
        "huggingface1_api_key" = {
          owner = "kreator";
        };
        # "muttwords" = {
        #   owner = "kreator";
        # };
      };
    };
  };
}
