# this is the ollama service.

{pkgs, inputs, ...}:

{
 
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    package = pkgs.ollama-vulkan;
  };

  environment.systemPackages = [
    pkgs.ollama-vulkan
    pkgs.llama-cpp-vulkan
    pkgs.whisper-cpp-vulkan
  ];
}
