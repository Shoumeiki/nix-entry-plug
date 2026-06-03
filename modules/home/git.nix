{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Shoumeiki";
    userEmail = "example@email.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
