# Helix AI Autocomplete Setup for NixOS Flake

This document contains everything needed to integrate Helix editor with AI autocompletion (via helix-gpt) into your NixOS flake.

## 1. Module File: helix-and-lsps.nix

Copy this entire file to your flake's directory (e.g., next to configuration.nix).

```{ config, lib, pkgs, ... }:

with lib;

let
  # Categorized Helix-supported LSP servers available in nixpkgs
  # Based on https://docs.helix-editor.com/lang-support.html
  # Note: Some LSPs may not be packaged or have different names; adjust as needed

  popularLsps = [
    # Very popular languages: Rust, Python, JS/TS, Go, C/C++, etc.
    "rust-analyzer"
    "typescript-language-server"
    "gopls"
    "clangd"
    "pylsp"
    "jedi-language-server"
    "ruff"
    "ty"
    "vscode-json-language-server"
    "bash-language-server"
    "lua-language-server"
    "yaml-language-server"
    "vscode-css-language-server"
    "texlab"
    "docker-langserver"
    "terraform-ls"
    "nil"
    "nixd"
    "taplo"
    "marksman"
    "helix-gpt"  # AI completions
  ];

  mediumLsps = [
    # Medium popularity: Haskell, Elixir, Java, etc.
    "haskell-language-server-wrapper"
    "elixir-ls"
    "kotlin-language-server"
    "metals"
    "ruby-lsp"
    "solargraph"
    "ocamllsp"
    "nimlangserver"
    "dart"
    "elm-language-server"
    "clojure-lsp"
    "fortran"
    "julia"
    "R"
    "cmake-language-server"
    "neocmakelsp"
    "mesonlsp"
    "zls"
    "gleam"
    "rescript-language-server"
    "purescript-language-server"
    "graphql-lsp"
    "jsonnet-language-server"
    "helm_ls"
    "templ"
    "tinymist"
    "slint-lsp"
    "svelteserver"
    "vue-language-server"
  ];

  otherLsps = [
    # Less popular or niche languages
    "ada_language_server"
    "amber-lsp"
    "astro-ls"
    "awk-language-server"
    "bass"
    "beancount-language-server"
    "bicep-langserver"
    "bitbake-language-server"
    "blueprint-compiler"
    "cairo-language-server"
    "circom-lsp"
    "clarinet"
    "codeql"
    "cl-lsp"
    "crystalline"
    "ameba-ls"
    "cuelsp"
    "serve-d"
    "dts-lsp"
    "dhall-lsp-server"
    "docker-compose-langserver"
    "dot-language-server"
    "earthlyls"
    "elvish"
    "fish-lsp"
    "forth-lsp"
    "fortls"
    "fsautocomplete"
    "asm-lsp"
    "vscode-eslint-language-server"
    "ember-language-server"
    "glsl_analyzer"
    "golangci-lint-langserver"
    "idris2-lsp"
    "jq-lsp"
    "just-lsp"
    "koka"
    "koto-ls"
    "lean"
    "luau-lsp"
    "markdoc-ls"
    "markdown-oxide"
    "pixi"
    "nu"
    "ols"
    "openscad-lsp"
    "pasls"
    "perlnavigator"
    "pest-language-server"
    "intelephense"
    "termux-language-server"
    "pkl-lsp"
    "swipl"
    "buf"
    "pb"
    "protols"
    "qmlls"
    "racket"
    "regols"
    "slangd"
    "cs"
    "solc"
    "sourcepawn-studio"
    "spade-language-server"
    "starpls"
    "forc"
    "sourcekit-lsp"
    "systemd-lsp"
    "tombi"
    "ts_query_ls"
    "tsp-server"
    "v-analyzer"
    "vala-language-server"
    "svlangserver"
    "vhdl_ls"
    "wat_server"
    "wgsl-analyzer"
    "ansible-language-server"
    "yls"
  ];
in
{
  options.services.helix-lsps = {
    enablePopular = mkOption {
      type = types.bool;
      default = true;
      description = "Install popular Helix LSP servers";
    };
    enableMedium = mkEnableOption "Install medium-popularity Helix LSP servers";
    enableOther = mkEnableOption "Install other/niche Helix LSP servers";
    extraLsps = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional LSP packages to install";
    };
  };

  config = {
    environment.systemPackages = [
      pkgs.helix
      pkgs.helix-gpt
    ] ++ map (name: 
      if builtins.hasAttr name pkgs then pkgs.${name} else null
    ) (
      (optionals config.services.helix-lsps.enablePopular popularLsps) ++
      (optionals config.services.helix-lsps.enableMedium mediumLsps) ++
      (optionals config.services.helix-lsps.enableOther otherLsps) ++
      config.services.helix-lsps.extraLsps
    );
  };
}
```

## 2. Integration Instructions

1. **Copy the module**: Place `helix-and-lsps.nix` in your flake directory.

2. **Import in configuration.nix** (or equivalent):
   ```
   imports = [
     ./helix-and-lsps.nix
     # ... other imports
   ];
   ```

3. **Enable options** (optional, since enablePopular defaults to true):
   ```
   services.helix-lsps.enableMedium = true;  # For medium-popularity LSPs
   services.helix-lsps.enableOther = false;   # Disable if not needed
   ```

4. **Rebuild NixOS**:
   ```
   sudo nixos-rebuild switch
   ```

5. **Verify**:
   - `helix --version` should work.
   - `helix-gpt --help` should work.
   - LSPs like `rust-analyzer --version` should be available.

## 3. API Key Setup for helix-gpt

Choose one backend:

- **Copilot (Recommended)**:
  ```
  helix-gpt --authCopilot  # Run once to authenticate
  export COPILOT_API_KEY=your_token  # Add to ~/.bashrc or use direnv
  ```

- **OpenAI**:
  ```
  export OPENAI_API_KEY=your_key
  ```

- **Other**: Set HANDLER env var (e.g., `export HANDLER=copilot`).

## 4. Per-Project Helix Configuration

For testing in a project (e.g., hx-ai-autocomplete), create `.helix/languages.toml` in the project root:

```
[language-server.gpt]
command = "helix-gpt"
# Optional: Add args like --handler copilot
# Relies on env vars for keys

[[language]]
name = "rust"
language-servers = ["rust-analyzer", "gpt"]

[[language]]
name = "python"
language-servers = ["pylsp", "gpt"]
```

- This overrides global config for the project.
- Test: Open a file in Helix, type `{` or press Ctrl+X for completions.

## 5. Testing Steps

1. Open Helix in a project with `.helix/languages.toml`.
2. Edit a file (e.g., .rs or .py).
3. Trigger completions: Auto on `{`, `(`, ` `, or manual Ctrl+X.
4. Check logs: `tail -f ~/.cache/helix/helix.log` and helix-gpt logs.
5. Code actions: Space + A in Helix for AI actions like refactor.

## 6. Troubleshooting

- If LSP not found: Check `hx --health` for language support.
- API issues: Ensure keys are set and valid.
- Performance: AI calls may be slow; debounce is built-in.

This should get you fully set up. Copy this file to your flake and let me know when you're ready to proceed there!</content>
<parameter name="filePath">AGENT2.md