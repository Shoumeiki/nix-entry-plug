_: {
  # ---------------------------------------------------------------------------
  # mako: Wayland notification daemon.
  #
  # Stylix themes via stylix.targets.mako. This file only sets behaviour
  # (timeouts, anchor, history).
  # ---------------------------------------------------------------------------

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      default-timeout = 5000;
      ignore-timeout = false;
      max-history = 50;
      layer = "overlay";
      margin = 10;
      padding = 12;
    };
  };
}
