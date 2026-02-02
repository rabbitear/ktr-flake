# All my Gnome3 settings.  Even if I don't use Gnome3 desktop, these are
# good to have for other gnome applications sometimes.
{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
let
  cfgDir = "${config.home.homeDirectory}/.config";
  wallpaper = ./wallpaper.png;
  wallpaper-dark = ./wallpaper-dark.png;
in
{
  xdg.configFile."wallpapers/wallpaper.png".source = wallpaper;
  xdg.configFile."wallpapers/wallpaper-dark.png".source = wallpaper-dark;
  # TODO:
  # - Super-Q to close window
  # - Super-Return open an xterm 
  #     - display something useful 
  home.packages = with pkgs; [
    gnomeExtensions.no-overview
    gnomeExtensions.appindicator
    gnomeExtensions.ddterm 
    gjs
    cheese
    iagno   # go game
    hitori  # sudoku game
    gnome-characters
    flameshot
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        no-overview.extensionUuid
        ddterm.extensionUuid
        appindicator.extensionUuid
      ];
    };
    "org/gnome/desktop/interface" = {
      accent-color = "green";
      #text-scaling-factor = 2.0;
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
	  "org/gnome/mutter".dynamic-workspaces = false;
    "org/gnome/desktop/wm/preferences".num-workspaces = "4";
    "org/gnome/desktop/background" = {
      primary-color = "#02023c3c8888";
      picture-uri = "file://${cfgDir}/wallpapers/wallpaper.png";
      picture-dark-uri = "file://${cfgDir}/wallpapers/wallpaper-dark.png";
      picture-options = "zoom";  # or "scaled" or "stretched", ..
    };
    "org/gnome/desktop/wm/keybindings" = {
  	  switch-to-workspace-1 = [ "F1" ];
      switch-to-workspace-2 = [ "F2" ];
      switch-to-workspace-3 = [ "F3" ];
      switch-to-workspace-4 = [ "F4" ];
	    move-to-workspace-1 = [ "<Shift>F1" ];
      move-to-workspace-2 = [ "<Shift>F2" ];
      move-to-workspace-3 = [ "<Shift>F3" ];
      move-to-workspace-4 = [ "<Shift>F4" ];
	    toggle-fullscreen = [ "<Super>F" ];
	    close = [ "<Super>q" ];
      activate-window-menu = [ "<Shift><Super>M" ];
	  };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybinding/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybinding/custom1/"
      ];
      magnifier = [ "<Super>Z" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybinding/custom0" = {
      binding = "<Super>Return";
      #command = "xterm +sb -sl 3000 -fn xft:Noto:size=17 -g 80x12 -fg lightyellow -bg grey16 -bd black -cr yellow -bc -hm -selbg grey90 -selfg grey60";
      command = "foot";
      name = "FastTerm";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybinding/custom1" = {
      binding = "<Super>y";
      command = "flameshot gui";
      name = "FlameShot";
    };
    "org/gnome/desktop/screensaver".lock-enabled = false;
    "org/gnome/desktop/interface".clock-show-weekday = true;

    "com/github/amezin/ddterm" = {
      custom-font = "M PLUS 1 Code 20";
      ddterm-toggle-hotkey = [ "<Alt>space" ];
      hide-animation = "ease-in-expo";
      hide-animation-duration = 0.28;
      hide-when-focus-lost = true;
      shortcut-background-opacity-dec = [ "<Primary><Alt>o" ];
      shortcut-background-opacity-inc = [ "<Primary><Alt>i" ];
      shortcut-next-tab = [ "<Alt>Right" ];
      shortcut-prev-tab = [ "<Alt>Left" ];
      shortcut-window-size-dec = [ "<Alt>Down" ];
      shortcut-window-size-inc = [ "<Alt>Up" ];
      use-system-font = false;
      window-monitor = "focus";
      window-position = "bottom";
    };
  };   
}
