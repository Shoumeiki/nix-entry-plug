{ pkgs, ... }:
let
  # wl-paste calls this script once per clipboard change, piping the new
  # content on stdin. We inspect the advertised MIME types *before* passing
  # anything to `cliphist store`.
  #
  # The x-kde-passwordManagerHint sentinel is set by KeePassXC and other
  # KDE-aware password managers to signal "this is a secret — do not store".
  # Bitwarden (browser extension and desktop) does NOT set this type; it
  # writes plain text/plain with no hint. For Bitwarden, enable the
  # "Clear Clipboard" option in Bitwarden → Settings → Security so the
  # entry is purged from the active clipboard after a short timeout.
  filter = pkgs.writeShellScript "cliphist-filter" ''
    mime_types=$(${pkgs.wl-clipboard}/bin/wl-paste --list-types 2>/dev/null) || true
    case "$mime_types" in
      *x-kde-passwordManagerHint*)
        # Password-manager sentinel present — skip this entry.
        exit 0 ;;
    esac
    exec ${pkgs.cliphist}/bin/cliphist store
  '';
in
{
  # Replaces the default `services.cliphist` systemd unit (removed from
  # hyprland.nix) so we can swap in the filter script as ExecStart.
  # cliphist and wl-clipboard binaries come from home.packages in hyprland.nix.
  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history daemon (password-aware)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${filter}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
