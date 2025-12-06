{pkgs, ...}:
{
  environment.systemPackages = [
    pkgs.kdePackages.flatpak-kcm
  ];
}
