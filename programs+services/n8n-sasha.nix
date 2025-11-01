{
  services.n8n = {
    enable = true;
    # settings = JSON value {} ?? what is that ??
    # <https://mynixos.com/nixpkgs/option/services.n8n.settings>
    # I guess this is usually port 5678
    # Then we can env N8N_TEMPLATES_ENABLED="false" ?
    openFirewall = true;
    settings = {
      N8N_PROTOCOL = "https";
      N8N_HOST = "0.0.0.0";
      N8N_PORT = "5678";
      # N8N_SECURE_COOKIE = "false";
      # any other env vars as strings:
      WEBHOOK_URL = "http://sasha.pufferfish-pound.ts.net:5678/";
      # DB_TYPE = "postgresdb";
      # DB_POSTGRESDB_HOST = "db.example";
      # DB_POSTGRESDB_DATABASE = "n8n";
      # DB_POSTGRESDB_USER = "n8n";
      # DB_POSTGRESDB_PASSWORD = "secret";
    };
  };
}
