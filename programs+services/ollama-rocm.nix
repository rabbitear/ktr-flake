# this is the ollama service.

{pkgs, lib, ...}:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    loadModels = [
      "deepseek-r1:1.5b"
    ];
    acceleration = "rocm";
    openFirewall = true;
  };
}
