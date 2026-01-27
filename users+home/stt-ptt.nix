{pkgs, ...}: {
  imports = [ m3ta-nixpkgs.homeManagerModules.default ];

  cli.stt-ptt = {
    enable = true;
    model = "ggml-large-v3-turbo";
    language = "en";
    whisperPackage = pkgs.whisper-cpp-vulkan;
    notifyTimeout = 3000;
  };
}
