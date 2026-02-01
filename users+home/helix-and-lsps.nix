{ config, lib, pkgs, ... }:

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
    "markdown-oxide"
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
