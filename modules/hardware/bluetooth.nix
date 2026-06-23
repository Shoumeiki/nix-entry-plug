_: {
  hardware.bluetooth = {
    enable = true;
    # Don't power the radio on at boot — let the user (or blueman) toggle
    # it on demand. Saves a few mW and avoids unexpected pairing prompts
    # on a freshly booted machine.
    powerOnBoot = false;
    settings.General = {
      # Required for audio sinks (A2DP) to work properly with PipeWire.
      Experimental = true;
    };
  };

  services.blueman.enable = true;
}
