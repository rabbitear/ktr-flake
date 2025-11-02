# NixOS configuration for mcpo - MCP-to-OpenAPI proxy server
# https://github.com/open-webui/mcpo
{ pkgs, lib, config, ... }:

let
  cfg = config.services.mcpo;
  
  # Package the MCP Python SDK first
  mcpPackage = pkgs.python3Packages.buildPythonPackage rec {
    pname = "mcp";
    version = "1.17.0";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "modelcontextprotocol";
      repo = "python-sdk";
      rev = "202af49857e452cdb8b55aa23310df8154e5b292";
      sha256 = "sha256-woP9D7Ev2lxOFpuNSXpjN9OkQ/A6AMzQpjQD2CFb3e8=";
    };

    build-system = with pkgs.python3Packages; [
      hatchling
    ];

    dependencies = with pkgs.python3Packages; [
      anyio
      httpx
      httpx-sse
      pydantic
      starlette
      python-multipart
      sse-starlette
      pydantic-settings
      uvicorn
      jsonschema
      pyjwt
      cryptography  # Required by pyjwt[crypto]
    ];

    # Patch pyproject.toml to remove uv-dynamic-versioning and use static version
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace 'dynamic = ["version"]' 'version = "${version}"' \
        --replace 'requires = ["hatchling", "uv-dynamic-versioning"]' 'requires = ["hatchling"]'
      
      # Remove the uv-dynamic-versioning configuration sections
      sed -i '/\[tool\.hatch\.version\]/,/^$/d' pyproject.toml
      sed -i '/\[tool\.uv-dynamic-versioning\]/,/^$/d' pyproject.toml
    '';

    # Skip tests
    doCheck = false;

    pythonImportsCheck = [ "mcp" ];

    meta = with lib; {
      description = "Python implementation of the Model Context Protocol";
      homepage = "https://github.com/modelcontextprotocol/python-sdk";
      license = licenses.mit;
    };
  };

  # Now package mcpo with the MCP dependency
  mcpoPackage = pkgs.python3Packages.buildPythonApplication {
    pname = "mcpo";
    version = "0.0.19";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "open-webui";
      repo = "mcpo";
      rev = "91e8f94da7ea07f0f19db7f8f0d9cfc9839d859a";
      sha256 = "sha256-BoiHd+TJ4EfSPfU4SUfIV6FRf39FG4WWj+veS6CDgd0=";
    };

    build-system = with pkgs.python3Packages; [
      hatchling
    ];

    dependencies = with pkgs.python3Packages; [
      click
      fastapi
      mcpPackage  # Our custom MCP package
      passlib
      bcrypt  # Required by passlib[bcrypt]
      pydantic
      pyjwt
      cryptography  # Required by pyjwt[crypto]
      python-dotenv
      typer
      uvicorn
      watchdog
    ];

    # Skip tests if they exist
    doCheck = false;

    meta = with lib; {
      description = "A simple, secure MCP-to-OpenAPI proxy server";
      homepage = "https://github.com/open-webui/mcpo";
      license = licenses.mit;
      maintainers = [ ];
    };
  };

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
      default = mcpoPackage;
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

      # Add nodejs and other tools to PATH if needed by MCP servers
      path = with pkgs; [ nodejs ];

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
