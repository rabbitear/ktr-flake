{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "ort";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "grahamking";
    repo = "ort";
    # this rev commit should be before tests, its Oct27-2025.
    #rev = "ff8aed89a444bf809c5a73e05fe1ede8095a4d13";
    # this rev commit is of todays date Oct27, added doTest false below.
    rev = "adb6c615d47c7d48601beaa5bffbeca55f5abaec";
    #sha256 = "0000000000000000000000000000000000000000000000000000";
    sha256 = "sha256-CTXIH7qz/USrZ9C5/l/ODnSCu4oNrLrNnrDDfcZUNI8=";
  };

  # Use the Cargo.lock inside the fetched source to resolve dependency versions:
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkgs.pkg-config pkgs.clang ];
  buildInputs = [ pkgs.openssl pkgs.zlib ];

  #cargoBuildFlags = [ "--release" ];

  # don't run tests during the nix build (they require OPENROUTER_API_KEY)
  doCheck = false;

  meta = with pkgs.lib; {
    description = "ort from grahamking/ort";
    license = licenses.mit;
  };
}
