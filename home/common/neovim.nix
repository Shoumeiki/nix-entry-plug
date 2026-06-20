_: {
  # ---------------------------------------------------------------------------
  # Neovim.
  #
  # Bare neovim from nixpkgs; LazyVim itself is bootstrapped imperatively
  # from the LazyVim/starter template on first run. Going imperative for
  # plugins keeps the editor config a single git repo at ~/.config/nvim
  # that LazyVim's own update flow (`:Lazy update`) manages, instead of
  # forcing a rebuild for every plugin tweak.
  #
  # To bootstrap on a fresh install:
  #   git clone https://github.com/LazyVim/starter ~/.config/nvim
  #   rm -rf ~/.config/nvim/.git    # drop the starter's git history
  #   nvim                          # Lazy.nvim auto-installs plugins on first launch
  #
  # If/when we want fully declarative plugin management, swap this module
  # for nix-community/nixvim with its LazyVim preset.
  # ---------------------------------------------------------------------------

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
}
