final: prev: {
  bun = prev.stdenv.mkDerivation rec {
    pname = "bun-baseline";
    version = prev.bun.version; # Match current bun version

    src = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
      hash = "sha256-0728ag8ywpr59xlfmamn28avpsf1qr0pa4rizp97dyah7dbikg8q";
    };

    nativeBuildInputs = [ prev.unzip ];

    installPhase = ''
      mkdir -p $out/bin
      unzip -j $src bun -d $out/bin
      chmod +x $out/bin/bun
    '';

    dontStrip = true;
    dontPatchELF = true;
    dontPatchShebangs = true;
  };
}

