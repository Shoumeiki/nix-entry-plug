_: {
  # ---------------------------------------------------------------------------
  # greetd + ReGreet: minimal Wayland greeter.
  #
  # `programs.regreet.enable` wires up the full stack:
  #   - enables greetd
  #   - sets greetd's default session to launch ReGreet inside cage
  #     (a single-app Wayland kiosk)
  #   - exposes `programs.regreet.settings` for ReGreet config
  #
  # ReGreet should be themed automatically by Stylix's regreet target
  # (autoEnable = true in stylix.nix). If theming doesn't apply on the
  # first real boot, manually set `programs.regreet.settings.background`
  # and friends here.
  # ---------------------------------------------------------------------------

  programs.regreet.enable = true;
}
