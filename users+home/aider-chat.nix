{ pkgs, ... }:
{
  programs.aider-chat = {
    enable = true;
    package = pkgs.aider-chat-full;
    settings = {
      architect = true;
      model = "openrouter/qwen/qwen3-coder";
      dark-mode = true;
    #   auto-accept-architect = false;
    #   cache-prompts = true;
    #   check-model-accepts-settings = false;
    #   dark-mode = true;
    #   dirty-commits = false;
    #   lint = true;
    #   show-model-warnings = true;
    #   verify-ssl = false;
    };
  };
}
