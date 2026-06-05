{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      # File listing (eza)
      ls  = "eza --icons=auto";
      ll  = "eza -l --icons=auto --git";
      la  = "eza -la --icons=auto --git";
      lt  = "eza --tree --icons=auto --level=2";
      lta = "eza --tree --icons=auto --level=2 -a";

      # Better cat
      cat = "bat";

      # Better find/grep
      grep = "rg";
      find = "fd";

      # System monitor
      top  = "btop";
      htop = "btop";

      # Disk usage
      du = "dust";
      df = "duf";

      # Process viewer
      ps = "procs";

      # Git shortcuts
      g   = "git";
      gs  = "git status";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gl  = "git lg";
      gco = "git checkout";
    };

    interactiveShellInit = ''
      # Silence the greeting
      set fish_greeting ""

      # Smart cd (zoxide replaces cd; use 'zi' for interactive picker)
      zoxide init fish | source

      # fzf key bindings (Ctrl+R history, Ctrl+T files, Alt+C dirs)
      fzf --fish | source
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$time$character";
      add_newline = false;

      character = {
        success_symbol = "[>](green)";
        error_symbol = "[>](red)";
        vimcmd_symbol = "[<](blue)";
      };

      time = {
        disabled = false;
        format = "[$time]($style) ";
        style = "dimmed white";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--border=rounded"
      "--info=inline"
      "--prompt=  "
      "--pointer= "
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
      italic-text = "always";
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    btop
    tldr
    dust
    duf
    procs
    jq
    yq-go
    yazi
  ];
}
