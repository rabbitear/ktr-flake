{ pkgs ? import <nixpkgs> {} }:

let
  # Prefer fetchFromGitHub (easier to pin); replace rev and sha256 with a real commit/tag and hash.
  src = pkgs.fetchFromGitHub {
    owner = "grahamking";
    repo = "ort";
    rev = "master"; # replace with a commit hash or tag for reproducible builds
    sha256 = "0000000000000000000000000000000000000000000000000000"; # replace after first build
  };
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "ort";
  version = "0.0.1";

  inherit src;

  # cargoSha256 is required to build crates. Run `nix-build` once to get the right value (nix will
  # print the expected hash). Then paste it here.
  cargoSha256 = "0000000000000000000000000000000000000000000000000000";

  # Additional build-time and run-time deps:
  nativeBuildInputs = [ pkgs.pkg-config pkgs.clang ]; # pkg-config often helps with native deps
  buildInputs = [ pkgs.openssl pkgs.zlib ]; # add any native dependencies ort needs

  # build flags (optional)
  cargoBuildFlags = [ "--release" ];

  meta = with pkgs.lib; {
    description = "ort - openrouter command line client, an honest one";
    license = licenses.mit;
    #maintainers = with maintainers; [ ];
  };
}
