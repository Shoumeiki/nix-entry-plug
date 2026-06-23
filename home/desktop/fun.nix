{ pkgs, ... }:
{
  # fastfetch is installed in common/cli-tools.nix; this wires it into the
  # interactive shell so each new terminal prints the system info banner.

  home.packages = [ pkgs.cava ];

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
