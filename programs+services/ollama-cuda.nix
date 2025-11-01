# this is the ollama service.

{...}:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    loadModels = [
      "llama3.2:3b"
      "deepseek-r1:1.5b"
    ];
    acceleration = "cuda";
    openFirewall = true;
  };
}
