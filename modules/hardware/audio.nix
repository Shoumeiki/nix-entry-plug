_: {
  # ---------------------------------------------------------------------------
  # PipeWire audio stack.
  #
  # PipeWire replaces both PulseAudio and JACK with a single low-latency
  # daemon. WirePlumber is the session/policy manager (which device routes
  # where, default sinks, etc.). ALSA compat keeps legacy apps working.
  # ---------------------------------------------------------------------------

  # PipeWire needs realtime scheduling permissions; rtkit grants them
  # without giving the audio daemon full CAP_SYS_NICE.
  security.rtkit.enable = true;

  # Make sure the legacy PulseAudio service is off — PipeWire provides
  # the pulse server itself via `pulse.enable` below, and running both
  # would fight over /run/user/.../pulse.
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # JACK support is off by default; flip when a JACK-only app actually
    # needs it.
  };
}
