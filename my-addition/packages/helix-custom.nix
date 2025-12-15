{ pkgs, ... }:

pkgs.helix.overrideAttrs (oldAttrs: {
  # Override to use a specific commit or branch
  # src = pkgs.fetchFromGitHub {
  #   owner = "helix-editor";
  #   repo = "helix";
  #   rev = "your-commit-hash";  # Replace with specific commit
  #   sha256 = "sha256-hash";  # Run nix-prefetch-url on the tarball to get this
  # };

  # For local development, uncomment and adjust path
  # src = /path/to/your/helix/fork;

  # Add any custom patches or build modifications here
  # patches = [ ./my-helix-patch.patch ];
})