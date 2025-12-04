# this is the ollama service.

{pkgs, ...}:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    #loadModels = [
    #  "deepseek-r1:1.5b"
    #];
    acceleration = "rocm";
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.ollama-rocm
    pkgs.llama-cpp-rocm
  ];
}
