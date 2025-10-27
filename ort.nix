{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "ort";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "grahamking";
    repo = "ort";
    rev = "master"; # replace with commit/tag for reproducible builds
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  cargoSha256 = "0000000000000000000000000000000000000000000000000000";

  nativeBuildInputs = [ pkgs.pkg-config pkgs.clang ];
  buildInputs = [ pkgs.openssl pkgs.zlib ];
  cargoBuildFlags = [ "--release" ];

  meta = with pkgs.lib; {
    description = "ort from grahamking/ort";
    license = licenses.mit;
  };
}