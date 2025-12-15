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
    build.exec = "cd helix && cargo build --release";
    run.exec = "cd helix && ./target/release/hx --version";
    test.exec = "cd helix && cargo test";
    custom-hx.exec = "cd helix && ./target/release/hx";
    test-ai.exec = ''
      echo "Testing AI setup..."
      echo "HANDLER: $HANDLER"
      echo "COPILOT_API_KEY set: $(if [ -n "$COPILOT_API_KEY" ]; then echo "Yes"; else echo "No"; fi)"
      echo "helix-gpt available: $(which helix-gpt)"
      echo "To test in Helix: run 'custom-hx test.rs', type inside {}, check for AI completions"
    '';
  };

  # If you want to include source, uncomment and adjust
  # enterShell = ''
  #   echo "Helix development environment"
  #   echo "Source code should be in ./helix/ or adjust path"
  #   echo "Run 'build' to compile, 'run' to test"
  # '';

  # For direnv integration
  dotenv.enable = true;
}