{ config, pkgs, lib, ... }:

let
  user = "kreator"; 
in
{
  options = { };

  config = {
    # Add mutt to the system environment
    environment.systemPackages = (config.environment.systemPackages or []) ++ [
      pkgs.mutt
    ];

    # Configure home-manager for the user to install mutt and place .muttrc
    # This requires you are already using home-manager as a NixOS module
    home-manager.users.${user} = {
      # ensure mutt is available in the user's profile too
      home.packages = with pkgs; [ mutt ];

      # Replace the contents below with the full contents of your existing ~/.muttrc
      home.file.".muttrc".text = ''
# --- start of .muttrc content: paste your .muttrc here ---

# Example lines — replace everything between these markers with your real file
set from = "you@example.org"
set realname = "Your Name"







# --- end of .muttrc content ---
'';
    };
  };
}
