# NixOS configuration for mcpo - MCP-to-OpenAPI proxy server
# https://github.com/open-webui/mcpo
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
      description = "API key for authentication (leave empty to disable auth)";
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing API key (more secure than apiKey option)";
      example = "/run/secrets/mcpo-api-key";
    };

    rootPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Root path for serving under a subpath (e.g., /api/mcpo)";
      example = "/api/mcpo";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to config.json file for multiple MCP servers";
      example = "/etc/mcpo/config.json";
    };

    hotReload = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable hot-reload mode to watch config file for changes";
    };

    serverCommand = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "MCP server command to proxy (used when configFile is not set)";
      example = [ "uvx" "mcp-server-time" "--local-timezone=America/New_York" ];
    };

    serverType = lib.mkOption {
      type = lib.types.enum [ "stdio" "sse" "streamable-http" ];
      default = "stdio";
      description = "Type of MCP server to connect to";
    };

    serverHeaders = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Headers to send to SSE or HTTP MCP servers";
      example = { Authorization = "Bearer token"; X-Custom-Header = "value"; };
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

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python3Packages.buildPythonApplication {
        pname = "mcpo";
        version = "0.1.0";
        format = "pyproject";

        src = pkgs.fetchFromGitHub {
          owner = "open-webui";
          repo = "mcpo";
          rev = "main";
          sha256 = lib.fakeSha256; # You'll need to update this
        };

        nativeBuildInputs = with pkgs.python3Packages; [
          setuptools
          wheel
        ];

        propagatedBuildInputs = with pkgs.python3Packages; [
          fastapi
          uvicorn
          httpx
          pydantic
          python-multipart
        ];

        meta = with lib; {
          description = "A simple, secure MCP-to-OpenAPI proxy server";
          homepage = "https://github.com/open-webui/mcpo";
          license = licenses.mit;
          maintainers = [ ];
        };
      };
      description = "The mcpo package to use";
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

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/mcpo" ];
        
        # Environment
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

        headersArg = lib.optionalString (cfg.serverHeaders != null)
          "--header '${builtins.toJSON cfg.serverHeaders}'";

        serverTypeArg = lib.optionalString (cfg.serverType != "stdio")
          "--server-type ${cfg.serverType}";

        # Config file mode
        configMode = lib.optionalString (cfg.configFile != null)
          "--config ${cfg.configFile} ${hotReloadArg}";

        # Command mode
        commandMode = lib.optionalString (cfg.configFile == null && cfg.serverCommand != null)
          "${serverTypeArg} ${headersArg} -- ${lib.concatStringsSep " " (map lib.escapeShellArg cfg.serverCommand)}";

        mode = if cfg.configFile != null then configMode else commandMode;
      in ''
        ${cfg.package}/bin/mcpo \
          --port ${toString cfg.port} \
          ${apiKeyArg} \
          ${rootPathArg} \
          ${mode}
      '';
    };
  };
}