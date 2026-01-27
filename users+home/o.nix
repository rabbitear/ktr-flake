# o - a large language model interface
{pkgs, ...}:
let
  o = pkgs.writeShellApplication {
    name = "o";
    text = ''
      #!/usr/bin/env bash
      # model2 is not used at all
      #model_a_goodie_one=''${1:-"tngtech/tng-r1t-chimera:free"}
      model=''${1:-"z-ai/glm-4.5-air:free"}
      outdir="$HOME"/.journal/o
      [[ ! -d "$outdir" ]] && mkdir "$outdir"
      # Check if input is from pipe/redirection
      outputfile="$outdir"/"$(date +%F_%H_%M_%S)"_output.md
      inputfile="$outdir"/"$(date +%F_%H_%M_%S)"_input.md
      if [[ -t 0 ]]; then
        # Interactive mode (terminal input)
        echo -e "\e[0m 🦉📥 \e[0;31m**$model:** \e[1;31mEnter \e[0;33mText \e[1;31mHere\e[0m 📡📝" >&2
        (tee -p "$inputfile"; echo -e "\n 🦆🔍 \e[0;35m][\e[0;32mSeARchiNg\e[0;35m][ 🦜✨\e[0;36m\n" >&2) | ort -m "$model" | tee "$outputfile"
      else
        # Pipe/redirection mode
        echo -e "\e[0;32mPlease \e[0;35mWait\e[0;34m... 🕰️ ⌛️ 🚥\e[0m" >&2
        ort -m "$model" | tee -p "$outputfile"
      fi
      echo
      echo -e "\e[0m$(basename "$outputfile") \e[0;34m(\e[0;36m$(stat --printf="%s\n" "$outputfile")\e[0;34m) \e[0;35mbytes"
      echo -e "\e[0m$(basename "$inputfile") \e[0;34m(\e[0;36m$(stat --printf="%s\n" "$inputfile")\e[0;34m) \e[0;35mbytes"
      echo -e "\n\e[0m\e[1;31mTODO: \e[0m"
      echo "go over spacing again"
      echo -en "\e[0m"
    '';   
  };
in
{
  home.packages = [
    o
  ];
}
