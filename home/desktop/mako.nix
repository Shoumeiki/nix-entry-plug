_: {
  # Stylix handles theming via stylix.targets.mako. This file sets behaviour only.

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
