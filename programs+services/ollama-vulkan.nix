# this is the ollama service.

{pkgs, ...}:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    acceleration = "vulkan";
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.ollama-vulkan
    pkgs.llama-cpp-vulkan
    pkgs.whisper-cpp-vulkan
  ];
}
