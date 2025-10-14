{ config, pkgs, ... }:

{
  home = {
    username = "kreator";
    homeDirectory = "/home/kreator";
    stateVersion = "25.05";
  };
  programs.git = {
    enable = true;
    userName = "Jon Bradley";
    userEmail = "weatchu@gmail.com";

    extraConfig = {
      core.editor = "hx";
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  # Add stuff for your user as youe see fit:
  programs.helix = {
    enable = true;
    settings = {
      theme = "base16";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      p = "bat -np";
    };
    profileExtra = ''
      echo echo welcome to kreators bash shell on nix
      export EDITOR=hx
    '';
  };
}
