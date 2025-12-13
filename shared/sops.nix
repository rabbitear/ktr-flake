# Sops for all hosts
{ ... }: {
  config = {
    sops = {
      #enable = true;
      defaultSopsFile = ../crypt/cipher.yaml;
      #gnupg.home = "/home/kreator/.gnupg";
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/kreator/.config/sops/age/keys.txt";

      secrets = {
        "kreator" = {
          sopsFile = ../crypt/cipher.yaml;
          owner = "kreator";
          group = "wheel";
          mode = "0400";
          neededForUsers = true;
        };
        "github_ssh_key" = {
          sopsFile = ../crypt/cipher.yaml;
          mode = "0600";
          owner = "kreator";
          group = "nogroup";
          path = "/home/kreator/.ssh/theshack";
        };
        "openrouter_api_key" = {
          sopsFile = ../crypt/cipher.yaml;
          owner = "kreator";
          group = "nogroup";
          mode = "0600";
        };
        "huggingface1_api_key" = {
          sopsFile = ../crypt/cipher.yaml;
          owner = "kreator";
          group = "nogroup";
          mode = "0600";
        };
        "gemini_api_key" = {
          sopsFile = ../crypt/cipher.yaml;
          owner = "kreator";
          group = "nogroup";
          mode = "0600";
        };
        "context7_api_key" = {
          sopsFile = ../crypt/cipher.yaml;
          owner = "kreator";
          group = "nogroup";
          mode = "0600";
        };
        "muttwords" = {
          sopsFile = ../crypt/words.yaml;
          owner = "kreator";
          group = "nogroup";
          mode = "0600";
        };
        "gpg_private_keys" = {
          sopsFile = ../crypt/gpgs.yaml;
          path = "/run/secrets/gpg_private_keys";
          owner = "kreator";
          group = "nogroup";
          mode = "0400";
          #restartUnits = [ "gpg-import.service" ];
        };
        "searx" = {
          sopsFile = ../crypt/local-config.yaml;
          owner = "searx";
          group = "nogroup";
          mode = "0600";
        };
      };
    };
  };
}
