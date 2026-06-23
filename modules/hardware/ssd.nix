_: {
  services = {
    fstrim.enable = true;

    smartd = {
      enable = true;
      autodetect = true;
      notifications.wall.enable = true;
    };
  };
}
