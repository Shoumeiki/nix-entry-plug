_: {
  # Provides the freedesktop secrets D-Bus service (libsecret) for Zed,
  # Electron apps, git-credential-libsecret, etc.
  # PAM integration unlocks the keyring on greetd login with the login password.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
