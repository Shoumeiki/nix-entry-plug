{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Fun / decorative bits.
  #
  # fastfetch is already enabled in common/cli-tools.nix; here we wire it
  # into fish's interactive shell init so every new terminal greets you
  # with the system info banner.
  # ---------------------------------------------------------------------------

  home.packages = [ pkgs.cava ]; # audio visualiser

  programs.fish.interactiveShellInit = ''
    # Skip in non-interactive child shells (e.g. inside scripts, vim
    # :terminal, nested invocations) so we only print once per real
    # terminal window.
    if status is-interactive
      and not set -q FASTFETCH_SHOWN
        set -gx FASTFETCH_SHOWN 1
        fastfetch
    end
  '';
}
