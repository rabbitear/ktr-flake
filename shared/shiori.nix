{ config, ... }:
{
  services.shiori = {
    enable = true;
    port = 3004;
    address = "0.0.0.0";
    #databaseUrl = "postgres:///shiori?host=/run/postgresql";  # default is null ""
    #environmentFile = "/path/to/environmentFile";  # for secrets (sops)
  };
}
