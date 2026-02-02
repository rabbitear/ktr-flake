{ pkgs, config, ... }:
{
  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "miniflux"
      miniflux-url "http://sasha:3003/"
      miniflux-login "kreator"
      miniflux-password "some-pass"
      #browser "${pkgs.w3m}/bin/w3m -o 'config_qq 0'" "%u"
      browser "${pkgs.w3m}/bin/w3m -o 'config qq'"

      # unbind keys
      #unbind-key ENTER
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K
      unbind-key l
      unbind-key h
      
      # bind keys - vim style
      bind-key j down
      bind-key k up
      bind-key l open
      bind-key h quit
      
      # solarized
      color background         default   default
      color listnormal         default   default
      color listnormal_unread  default   default
      color listfocus          black     cyan
      color listfocus_unread   black     cyan
      color info               default   black
      color article            default   default
      
      # highlights
      highlight article "^(Title):.*$" blue default
      highlight article "https?://[^ ]+" red default
      highlight article "\\[image\\ [0-9]+\\]" green default

      # Experimental (to me) settings
      download-full-page yes
    '';
  };
  home.shellAliases.news = "newsboat";
}
