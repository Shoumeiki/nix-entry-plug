{ ... }:
{
  # ---------------------------------------------------------------------------
  # XDG MIME defaults for remote desktop / VM console protocols
  # ---------------------------------------------------------------------------
  xdg.mimeApps.defaultApplications = {
    # RDP files (e.g. downloaded from a Windows server or Azure)
    "application/x-rdp"        = "org.remmina.Remmina.desktop";
    "x-scheme-handler/rdp"     = "org.remmina.Remmina.desktop";

    # SPICE (virt-manager console links)
    "x-scheme-handler/spice"   = "org.remmina.Remmina.desktop";
    "x-scheme-handler/spice+tls" = "org.remmina.Remmina.desktop";

    # VNC
    "x-scheme-handler/vnc"     = "org.remmina.Remmina.desktop";
    "x-scheme-handler/vncviewer" = "org.remmina.Remmina.desktop";
  };
}
