{ ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        output.criteria = "eDP-1";
      }
     
      {
        profile.name = "tv";
        profile.outputs = [
          {
            criteria = "Technical Concepts Ltd 43S425 (HDMI-A-1)";
            mode = "1920x1080@60";
            position = "0,0";
          }
          {
            criteria = "GIGA-BYTE TECHNOLOGY CO., LTD. M27Q 21200B004026 (DP-3)";
            mode = "1280x720@119.878998";
          }
        ];
      }
      {
        profile.name = "no-tv";
        profile.outputs = [
          {
            criteria = "eDP-1";
            transform = "90";
          }
        ];
      }
    ];
  };
}

# { pkgs, ... }:
# {
#   # Make the kanshi binary available system‑wide
#   environment.systemPackages = [ pkgs.kanshi ];

#   services.kanshi = {
#     enable = true;

#     # ------------------------------------------------------------
#     #  Profiles (called “settings” in the NixOS module)
#     # ------------------------------------------------------------
#     settings = {
#       # “tv‑only” profile – used when a TV is connected on any HDMI
#       # output that matches the pattern “HDMI‑*”.  The profile is
#       # activated only when the output exists; otherwise kanshi falls
#       # back to the “desktop” profile.
#       profile = [
#         {
#           name = "tv";
#           # The output selector can be a simple string; kanshi will
#           # match it against the names reported by the compositor.
#           # Using the wildcard‑style pattern “HDMI‑*” works on every
#           # host even if the exact label differs (e.g. HDMI‑1‑A,
#           # HDMI‑A‑1, etc.).
#           output = [
#             {
#               criteria = "HDMI-*";
#               # You can pick the mode you want for the TV.  1920×1080
#               # at 60 Hz is a safe default for most TVs.
#               mode = "1920x1080@60";
#               # Optional: you can position the TV relative to other
#               # outputs (0,0 puts it at the origin).
#               position = "0,0";
#             }
#           ];
#         }

#         # --------------------------------------------------------
#         #  “desktop” (any‑and‑all) profile – used when no TV is
#         #  present, or when you just want the regular monitor(s).
#         # --------------------------------------------------------
#         {
#           name = "desktop";
#           # This profile is a fallback; it will be used whenever the
#           # “tv” profile’s selector does not match any output.
#           # We list the most common outputs; kanshi will simply ignore
#           # the ones that are not present on a given host.
#           output = [
#             {
#               criteria = "eDP-*";      # laptop screen
#               mode = "1920x1080@60";
#             }
#             {
#               criteria = "DP-*";       # DisplayPort monitor
#               mode = "2560x1440@60";
#             }
#             {
#               criteria = "HDMI-*";     # Any other HDMI monitor (not a TV)
#               mode = "1920x1080@60";
#             }
#           ];
#         }
#       ];
#     };
#   };
# }

# # hosts/yoshi/kanshi.nix
# { config, pkgs, ... }:

# {
#   # Enable the daemon
#   services.kanshi.enable = true;

#   # The profile that will be used on boot.
#   # You can change it later with `kanshi switch tv` etc.
#   # HALUCINATION!!!!
#   #services.kanshi.defaultProfile = "tv";

#   # -----------------------------------------------------------------
#   #  Profile definitions – one for each “setup” you want to switch to
#   # -----------------------------------------------------------------
#   services.kanshi.profiles = {
#     # -------------------------------------------------
#     #  TV (connected via HDMI‑A‑1)
#     # -------------------------------------------------
#     tv = {
#       # When this profile is active we want the TV to be the
#       # *only* output (the other monitor will be turned off).
#       outputs = [
#         {
#           # name must match the output name reported by `wlr-randr`
#           name = "HDMI-A-1";
#           mode = "3840x2160@30";   # 4K 30 Hz – the “preferred” mode
#           position = "0,0";
#           scale = 1;
#         }
#       ];
#     };

#     # -------------------------------------------------
#     #  Desktop monitor (DP‑3) – 2560×1440 @144 Hz
#     # -------------------------------------------------
#     monitor = {
#       outputs = [
#         {
#           name = "DP-3";
#           # Try the highest refresh first; if the driver refuses it,
#           # the next entry in the list will be used.
#           mode = "2560x1440@144";
#           # fallback – you can also keep a 120 Hz line if you like:
#           # mode = "2560x1440@120";
#           position = "0,0";
#           scale = 1;
#         }
#       ];
#     };
#   };
# }
