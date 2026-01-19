{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "ostt";
  version = "0.0.5";

  src = pkgs.fetchurl {
    url = "https://github.com/kristoferlund/ostt/archive/v${version}.tar.gz";
    hash = "sha256-0N7TjF+kkvqrVJWYeYs8slvBfx5ZNObnF5fNzeeihhI=";
  };

  cargoHash = "sha256-yvSso+Qs34QOAMHE6Eomlk5uUD/LqOtfLaPOrM2fTwA=";

  nativeBuildInputs = with pkgs; [
    pkg-config
    makeWrapper
  ];

  buildInputs = with pkgs; [
    ffmpeg
    alsa-lib
    openssl
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    pkgs.darwin.apple_sdk.frameworks.AudioToolbox
    pkgs.darwin.apple_sdk.frameworks.Security
  ];

  postInstall = ''
    wrapProgram $out/bin/ostt \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg ]}
  '';

  meta = with pkgs.lib; {
    description = "Open Speech-to-Text recording tool with real-time volume metering and transcription";
    homepage = "https://github.com/kristoferlund/ostt";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
