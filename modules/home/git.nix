{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Shoumeiki";
    # Git email should be sourced via sops-nix secret after setup.
    #userEmail = "config.sops.secrets."users/ellen/git";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
