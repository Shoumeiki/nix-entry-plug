{ pkgs, ... }:
{
  # -------------------------------------------------------------------------
  # Fish shell
  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
  # Starship prompt (minimal: time + caret only)
  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
  # Zoxide (smart cd with frecency)
  # -------------------------------------------------------------------------
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # -------------------------------------------------------------------------
  # fzf (fuzzy finder with catppuccin colors)
  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
  # bat (cat replacement; catppuccin theme applied via catppuccin module)
  # -------------------------------------------------------------------------
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
      italic-text = "always";
    };
  };

  # -------------------------------------------------------------------------
  # eza (ls replacement)
  # -------------------------------------------------------------------------
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };

  # -------------------------------------------------------------------------
  # CLI tools
  # -------------------------------------------------------------------------
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
