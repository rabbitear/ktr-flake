{config, pkgs, lib, ...}:
{
  services.n8n = {
    enable = true;
    # settings = JSON value {} ?? what is that ??
    # <https://mynixos.com/nixpkgs/option/services.n8n.settings>
    # I guess this is usually port 5678
    # Then we can env N8N_TEMPLATES_ENABLED="false" ?
    openFirewall = true;
  }
}
