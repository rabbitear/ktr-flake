{ config, ... }:
{
  sops.secrets.miniflux-admin = {
    sopsFile = ../../crypt/miniflux.yaml;
  };
  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    #config.LISTEN_ADDR = "127.0.0.1:8080, 127.0.0.1:8081";
    config.LISTEN_ADDR = "0.0.0.0:3003";
    adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
  };
}
