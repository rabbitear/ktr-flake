# Simpler alternative using uvx
{ pkgs, lib, config, ... }:

let
  cfg = config.services.mcpo;
in
{
  options.services.mcpo = {
    enable = lib.mkEnableOption "mcpo MCP-to-OpenAPI proxy server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port to listen on";
    };

    apiKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "API key for authentication";
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing API key";
    };

    rootPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Root path for serving under a subpath";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to config.json file for multiple MCP servers";
    };

    hotReload = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable hot-reload mode";
    };

    serverCommand = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "MCP server command to proxy";
    };

    serverType = lib.mkOption {
      type = lib.types.enum [ "stdio" "sse" "streamable-http" ];
      default = "stdio";
      description = "Type of MCP server";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "mcpo";
      description = "User account under which mcpo runs";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "mcpo";
      description = "Group under which mcpo runs";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = lib.mkIf (cfg.user == "mcpo") {
      isSystemUser = true;
      group = cfg.group;
      description = "mcpo service user";
      home = "/var/lib/mcpo";
      createHome = true;
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == "mcpo") { };

    systemd.services.mcpo = {
      description = "mcpo MCP-to-OpenAPI Proxy Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ uv nodejs ]; # Add any tools your MCP servers need

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";
        
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/mcpo" ];
        
        WorkingDirectory = "/var/lib/mcpo";
      };

      script = let
        apiKeyArg = 
          if cfg.apiKeyFile != null then
            "--api-key $(cat ${cfg.apiKeyFile})"
          else if cfg.apiKey != "" then
            "--api-key ${lib.escapeShellArg cfg.apiKey}"
          else
            "";

        rootPathArg = lib.optionalString (cfg.rootPath != "") 
          "--root-path ${lib.escapeShellArg cfg.rootPath}";

        hotReloadArg = lib.optionalString cfg.hotReload "--hot-reload";

        serverTypeArg = lib.optionalString (cfg.serverType != "stdio")
          "--server-type ${cfg.serverType}";

        configMode = lib.optionalString (cfg.configFile != null)
          "--config ${cfg.configFile} ${hotReloadArg}";

        commandMode = lib.optionalString (cfg.configFile == null && cfg.serverCommand != null)
          "${serverTypeArg} -- ${lib.concatStringsSep " " (map lib.escapeShellArg cfg.serverCommand)}";

        mode = if cfg.configFile != null then configMode else commandMode;
      in ''
        ${pkgs.uv}/bin/uvx mcpo \
          --port ${toString cfg.port} \
          ${apiKeyArg} \
          ${rootPathArg} \
          ${mode}
      '';
    };
  };
}