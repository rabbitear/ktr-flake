{ pkgs, ... }:

{
  # Helix development environment
  packages = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy

    # Additional tools
    git
    gcc
    pkg-config
    openssl.dev

    # For testing
    helix  # The stable version for comparison
    helix-gpt  # AI completions LSP
  ];

  # Environment variables
  env = {
    RUST_BACKTRACE = "1";
    HANDLER = "copilot";  # For helix-gpt
  };

  # Optional: Pre-commit hooks or scripts
  scripts = {
    build.exec = "export PKG_CONFIG_PATH=/nix/store/ccilc0vq8a5qvmjgp6qyg1jrfgjkrff4-openssl-3.6.0-dev/lib/pkgconfig:$PKG_CONFIG_PATH && cd helix && cargo build --release";
    run.exec = "cd helix && ./target/release/hx --version";
    test.exec = "cd helix && cargo test";
    test-ai.exec = ''
      echo "Testing AI setup..."
      echo "HANDLER: $HANDLER"
      echo "COPILOT_API_KEY set: $(if [ -n "$COPILOT_API_KEY" ]; then echo "Yes"; else echo "No"; fi)"
      echo "helix-gpt available: $(which helix-gpt)"
      echo "To test in Helix: run 'custom-hx test.rs', type inside {}, check for AI completions"
      echo "Ollama test: :ai-generate hello world"
    '';
  };

  enterShell = ''
    alias custom-hx="./helix/target/release/hx"
    echo "Custom Helix available as 'custom-hx'"
  '';

  # If you want to include source, uncomment and adjust
  # enterShell = ''
  #   echo "Helix development environment"
  #   echo "Source code should be in ./helix/ or adjust path"
  #   echo "Run 'build' to compile, 'run' to test"
  # '';

  # For direnv integration
  dotenv.enable = true;
}